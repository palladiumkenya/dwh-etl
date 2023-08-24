MERGE [NDWH].[dbo].[DimVaccinationStatus] AS a
		USING(SELECT DISTINCT VaccinationStatus
				FROM ODS.dbo.CT_Covid
				WHERE VaccinationStatus <> '' AND VaccinationStatus IS NOT NULL) AS b 
						ON(
						a.VaccinationStatus = b.VaccinationStatus
						  )
		WHEN NOT MATCHED THEN 
						INSERT(VaccinationStatus,LoadDate) 
						VALUES(VaccinationStatus,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.VaccinationStatus =b.VaccinationStatus;
