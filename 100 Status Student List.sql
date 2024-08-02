-- Selecting all the future students in 100 status (those that need additional documents for their funding) between 08/02/2024 and 12/01/2024 start dates.

SELECT DISTINCT dsd.PERSON_ID, 
dpd.PERSON_FULL_NAME,
dcd.CAMPUS_NAME, 
CAST(dsd.START_DATE AS DATE) START_DATE,
dsd.PROGRAM_CODE, 
dsd.FINANCIAL_AID_STATUS_CODE
FROM EDW.dbo.DW_STUDENT_D dsd
LEFT JOIN EDW.dbo.DW_STUDENT_STATUS_D dssd ON dsd.STUDENT_STATUS_CODE = dssd.STUDENT_STATUS_CODE 
                                 AND dssd.CURR_REC_IND = 'Y'
LEFT JOIN EDW.dbo.DW_PERSON_D dpd ON dsd.PERSON_ID = dpd.PERSON_ID
								 AND dpd.CURR_REC_IND = 'Y'
LEFT JOIN EDW.dbo.DW_CAMPUS_D dcd ON dsd.CAMPUS_CODE = dcd.CAMPUS_CODE 
                                 AND dcd.CURR_REC_IND = 'Y'
INNER JOIN EDW.dbo.DW_STUDENT_COUNT_F dscf ON dscf.STUDENT_KEY = dsd.STUDENT_KEY
                                 AND dcd.CURR_REC_IND = 'Y'
WHERE 1=1
AND dsd.curr_rec_ind = 'Y'
AND dsd.PERSON_ID IS NOT NULL
AND dsd.STUDENT_STATUS_CODE = 0
AND dsd.FINANCIAL_AID_STATUS_CODE LIKE '%100%'
AND dsd.START_DATE BETWEEN '2024-08-02 00:00:00.000' AND '2024-12-01 00:00:00.000'
AND dscf.ENROLLED_FLAG = 1




