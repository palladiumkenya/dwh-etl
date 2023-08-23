MERGE [NDWH].[dbo].[DimFamilyPlanning] AS a
	USING(SELECT 
		DISTINCT FamilyPlanningMethod AS FamilyPlanning
FROM ODS.dbo.CT_PatientVisits
WHERE FamilyPlanningMethod <> 'NULL' and FamilyPlanningMethod <>''
) AS b 
						ON(
						a.[FamilyPlanning] = b.FamilyPlanning
						  )
						  
		WHEN NOT MATCHED THEN 
						INSERT([FamilyPlanning],LoadDate) 
						VALUES(FamilyPlanning,GetDate())
		WHEN MATCHED THEN
						UPDATE SET 						
						a.FamilyPlanning =b.FamilyPlanning;
