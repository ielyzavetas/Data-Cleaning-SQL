SELECT 
     dsd.PERSON_ID
    ,dsd.STUDENT_ID
    ,dpd.PERSON_FULL_NAME
    ,CAST(dsd.START_DATE AS DATE) AS START_DATE
    ,dcd.CAMPUS_NAME
    ,CAST(dsd.GRADUATION_DATE AS DATE) AS GRADUATION_DATE
    ,dsf.fund_source
	,dsf.sfu_fund_source_count
    ,dsf.student_packaged_amount
    ,dsf.student_release_amount
    ,dsf.student_refund_amount
    ,dsf.student_packaged_amount - dsf.student_refund_amount AS amt_after_refund
    ,CAST(a.fin_date AS DATE) AS Rel_date
    ,CAST(b.fin_date AS DATE) AS Pkg_date
    ,CAST(c.fin_date AS DATE) AS Prc_date
    ,CAST(d.fin_date AS DATE) AS Sub_date
    ,CAST(e.fin_date AS DATE) AS Rec_date
FROM 
    ebw.dbo.DW_STUDENT_D dsd
    LEFT JOIN ebw.dbo.DW_PERSON_D dpd ON dsd.PERSON_ID = dpd.PERSON_ID
                                       AND dpd.CURR_REC_IND = 'Y'
    LEFT JOIN ebw.dbo.DW_CAMPUS_D dcd ON dsd.CAMPUS_CODE = dcd.CAMPUS_CODE 
                                       AND dcd.CURR_REC_IND = 'Y'
    LEFT JOIN Rub.dbo.student_funding dsf ON dsd.STUDENT_ID = dsf.student_id
	JOIN EBW.dbo.DW_DATE_D_VW dddv3										
		  ON dddv3.ORD_CAL_DT = CAST(dsd.start_date AS DATE)
    LEFT JOIN (
        SELECT funding#, student_status_code, fin_date, ROW_NUMBER() OVER (PARTITION BY funding# ORDER BY fin_date DESC) AS rn
        FROM rub.dbo.student_funding_history
        WHERE student_status_code = 'Rel'
    ) a ON dsf.funding# = a.funding#
       AND a.rn = 1
    LEFT JOIN (
        SELECT funding#, student_status_code, fin_date, ROW_NUMBER() OVER (PARTITION BY funding# ORDER BY fin_date DESC) AS rn
        FROM rub.dbo.student_funding_history
        WHERE student_status_code = 'Pkg'
    ) b ON dsf.funding# = b.funding#
       AND b.rn = 1
    LEFT JOIN (
        SELECT funding#, student_status_code, fin_date, ROW_NUMBER() OVER (PARTITION BY funding# ORDER BY fin_date DESC) AS rn
        FROM rub.dbo.student_funding_history
        WHERE student_status_code = 'Prc'
    ) c ON dsf.funding# = c.funding#
       AND c.rn = 1
    LEFT JOIN (
        SELECT funding#, student_status_code, fin_date, ROW_NUMBER() OVER (PARTITION BY funding# ORDER BY fin_date DESC) AS rn
        FROM rub.dbo.student_funding_history
        WHERE student_status_code = 'Sub'
    ) d ON dsf.funding# = d.funding#
       AND d.rn = 1
    LEFT JOIN (
        SELECT funding#, stuents_status_code, fin_date, ROW_NUMBER() OVER (PARTITION BY funding# ORDER BY fin_date DESC) AS rn
        FROM rub.dbo.student_funding_history
        WHERE sfh_status_code = 'Rec'
    ) e ON dsf.funding# = e.funding#
       AND e.rn = 1
WHERE 
    1=1
    AND dsd.curr_rec_ind = 'Y'
    AND dsd.PERSON_ID IS NOT NULL
    AND dsf.fund_source IN ('ALT1', 'ALT2')
	AND dsf.funding_status_code NOT IN ('RFN', 'DND', 'CNC', 'REJ')	
	AND dddv3.FSCL_YR_NBR IN ('2023')
	


