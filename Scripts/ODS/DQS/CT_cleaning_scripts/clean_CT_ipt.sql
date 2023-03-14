-- clean TBScreening
UPDATE [ODS].[DBO].[CT_Ipt]
    SET TBScreening = CASE
                                WHEN IndicationForIPT = '1' THEN 'Screened'
                                WHEN IndicationForIPT IN ('TB Screening not done', '0') THEN  'Not Screened'
                            END
WHERE TBScreening IN ('1', 'Screening not done', '0')

GO


-- clean IndicationForIPT
UPDATE [ODS].[DBO].[CT_Ipt]
    SET IndicationForIPT = CASE 
                                WHEN IndicationForIPT IN ('Adherence Issues', 'Poor adherence') THEN 'Adherence Issues'
                                WHEN IndicationForIPT = 'Client Traced back a' THEN 'Client Traced back'
                                WHEN IndicationForIPT IN ('No more drug Interru', 'Toxicity Resolved', 'Other patient decisi', 'Pregnancy', 'Patient declined', 'Other', 'High CD4', 'Education', 'Client Discharged fr') THEN 'OTHER'
                            END
WHERE IndicationForIPT IN ('Adherence Issues', 'Poor adherence', 'Client Traced back a', 'No more drug Interru', 'Toxicity Resolved', 'Other patient decisi', 'Pregnancy', 
                            'Patient declined', 'Other', 'High CD4', 'Education', 'Client Discharged fr') 

GO



