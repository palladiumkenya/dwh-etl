MERGE [NDWH].[dbo].[DimDrug] AS a
	USING(SELECT DISTINCT Drug 
		  FROM [ODS].[dbo].[CT_PatientPharmacy]
		  where Drug <> 'NULL' and Drug <>'' and TreatmentType='ARV'
		) AS b 
	ON(a.[Drug]=b.Drug)
	WHEN MATCHED THEN
    UPDATE SET 
    a.Drug = B.Drug
	WHEN NOT MATCHED THEN 
	INSERT([Drug],LoadDate) VALUES(Drug,Getdate());