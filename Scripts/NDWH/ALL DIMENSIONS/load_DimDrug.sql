MERGE [NDWH].[dbo].[DimDrug] AS a
		USING	(	SELECT DISTINCT Drug as Drug
					FROM ODS.dbo.CT_PatientPharmacy
					WHERE Drug <> 'NULL' AND Drug <>'' AND TreatmentType='ARV'
				) AS b 
						ON(
							a.Drug = b.Drug
						  )
		WHEN NOT MATCHED THEN 
						INSERT(Drug,LoadDate) 
						VALUES(Drug,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.Drug =b.Drug;
						 

