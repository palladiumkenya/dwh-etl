	MERGE [NDWH].[dbo].[DimDifferentiatedCare] AS a
	USING(SELECT DISTINCT DifferentiatedCare as DifferentiatedCare
		  FROM ODS.dbo.CT_PatientVisits
		  where DifferentiatedCare <> 'NULL' and DifferentiatedCare <>'') AS b 
	ON(a.DifferentiatedCare=b.DifferentiatedCare)
	WHEN MATCHED THEN
    UPDATE SET 
    a.DifferentiatedCare = B.DifferentiatedCare
	WHEN NOT MATCHED THEN 
	INSERT(DifferentiatedCare) VALUES(DifferentiatedCare);

	UPDATE [NDWH].[dbo].[DimDifferentiatedCare]
	SET DifferentiatedCare =UPPER(DifferentiatedCare)