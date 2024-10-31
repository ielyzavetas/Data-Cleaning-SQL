WITH RankedStudents AS (
    SELECT 
         dsd.STUDENT_ID
        ,dpd.STUDENT_SSN
        ,dpd.STUDENT_FULL_NAME
        ,dsd.ENROLLMENT_SEQUENCE_NUMBER
        ,dsd.FINANCIAL_AID_STATUS_CODE
        ,CAST(dsd.START_DATE AS DATE) AS START_DATE
        ,CAST(dsd.ENROLLMENT_DATE AS DATE) AS ENROLLMENT_DATE
        ,dcd.CAMPUS_NAME
        ,sth.REP_FULL_NAME
        ,dsthv.SALES_DIVISION_CODE
        ,CASE WHEN dsthv.SALES_FORCE_CODE = 'Field' THEN 'High School'
              WHEN dsthv.SALES_FORCE_CODE = 'Campus' THEN 'Adult'
              ELSE dsthv.SALES_FORCE_CODE 
         END AS SALES_CHANNEL
        ,dpd.PRIMARY_EMAIL_ADDRESS
        ,dpd.PERMANENT_PHONE
        ,dsd.CASH_ONLY_FLAG
        ,CASE WHEN dsd.FINANCIAL_AID_STATUS_CODE LIKE '%200%' THEN '1'
              ELSE '0'
         END AS VA_FLAG
        ,ROW_NUMBER() OVER (
            PARTITION BY dsd.STUDENT_ID 
            ORDER BY 
                CASE WHEN dsthv.SALES_DIVISION_CODE IS NOT NULL THEN 1 ELSE 2 END, 
                CASE WHEN dsthv.SALES_FORCE_CODE IS NOT NULL THEN 1 ELSE 2 END,
                dsd.ENROLLMENT_SEQUENCE_NUMBER DESC
        ) AS rn
    FROM 
        edw.dbo.DW_STUDENT_D dsd 
        LEFT JOIN edw.dbo.DW_STUDENT_COUNT_F dscf ON dsd.STUDENT_KEY = dscf.STUDENT_KEY                                 
        LEFT JOIN edw.dbo.DW_PERSON_D dpd ON dsd.PERSON_ID = dpd.PERSON_ID 
		                                  AND dpd.CURR_REC_IND = 'Y'
        LEFT JOIN edw.dbo.DW_CAMPUS_D dcd ON dsd.CAMPUS_CODE = dcd.CAMPUS_CODE 
		                                  AND dcd.CURR_REC_IND = 'Y'
        LEFT JOIN edw.dbo.DW_SALES_TEAM_HIER_VW sth ON dsd.STUDENT_SALES_REP_CODE = sth.SALES_REP_CODE 
		                                  AND sth.CURR_REC_IND = 'Y'
        LEFT JOIN EDW.dbo.DW_SALES_REP_HIER dsthv ON dscf.Sales_TEAM_HIER_KEY = dsthv.SALES_TEAM_HIER_KEY  
		                                  AND sth.CURR_REC_IND = 'Y'
    WHERE 
        dsd.curr_rec_ind = 'Y'
        AND dsd.STUDENT_ID IS NOT NULL
        AND (dpd.STUDENT_SSN IS NULL OR dpd.STUDENT_SSN = ' ')
        AND dsd.START_DATE > SYSDATETIME()
        AND NOT (dsd.STUDENT_STATUS_CODE = 0 AND dsd.STUDENT_STATUS_REASON_CODE = 3)
)
SELECT * 
FROM RankedStudents
WHERE rn = 1;