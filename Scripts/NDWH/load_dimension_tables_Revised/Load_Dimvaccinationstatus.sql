	MERGE [NDWH].[dbo].[Dimvaccinationstatus] AS a
	USING(SELECT
				DISTINCT VaccinationStatus
		  FROM ODS.dbo.CT_Covid (NoLock)
		  WHERE VaccinationStatus <> '' AND VaccinationStatus IS NOT NULL) AS b 
		ON(a.VaccinationStatus=b.VaccinationStatus)
		WHEN MATCHED THEN
			UPDATE SET 
			a.VaccinationStatus = B.VaccinationStatus
		WHEN NOT MATCHED THEN 
			INSERT(VaccinationStatus,loadDate) VALUES(VaccinationStatus,GETDATE());

	UPDATE [NDWH].[dbo].[Dimvaccinationstatus]
	SET VaccinationStatus =UPPER(VaccinationStatus)
