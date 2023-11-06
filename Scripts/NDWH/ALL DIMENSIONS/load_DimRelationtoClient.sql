
MERGE [NDWH].[dbo].[DimRelationshipWithPatient] AS a
		USING	(	SELECT DISTINCT RelationshipWithPatient
					FROM ODS.dbo.CT_ContactListing 
				) AS b 
						ON(
							a.RelationshipWithPatient = b.RelationshipWithPatient
						  )
		WHEN NOT MATCHED THEN 
						INSERT(RelationshipWithPatient,LoadDate) 
						VALUES(RelationshipWithPatient,GetDate())
		WHEN MATCHED THEN
						UPDATE  						
							SET a.RelationshipWithPatient =b.RelationshipWithPatient;