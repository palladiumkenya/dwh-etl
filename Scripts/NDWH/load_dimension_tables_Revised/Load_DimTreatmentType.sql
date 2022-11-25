	MERGE [NDWH].[dbo].[DimTreatmentType] AS a
	USING(SELECT DISTINCT
			  CASE 
					WHEN TreatmentType IN ('ARV','HIV Treatment') THEN 'ART'
					WHEN TreatmentType='Hepatitis B' THEN 'Non-ART'
					ELSE TreatmentType 
			  END AS TreatmentType
		FROM ODS.dbo.CT_PatientPharmacy(NoLock) WHERE TreatmentType IS NOT NULL) AS b 
	ON(a.TreatmentType=b.TreatmentType)
	WHEN MATCHED THEN
    UPDATE SET 
    a.TreatmentType = B.TreatmentType
	WHEN NOT MATCHED THEN 
	INSERT(TreatmentType,LoadDate) VALUES(TreatmentType,GETDATE());

	UPDATE [NDWH].[dbo].[DimTreatmentType] 
	SET TreatmentType = UPPER(TreatmentType)