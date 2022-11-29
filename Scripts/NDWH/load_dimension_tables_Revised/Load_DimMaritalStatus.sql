MERGE [NDWH].[dbo].[DimMaritalStatus] AS a
	USING(SELECT DISTINCT Target_MaritalStatus AS maritalstatusDescription FROM  [ODS].[dbo].[lkp_MaritalStatus]) AS b 
	ON(a.maritalstatusDescription=b.maritalstatusDescription)
	WHEN NOT MATCHED THEN 
		INSERT(MaritalStatusDescription) VALUES(maritalstatusDescription)
	WHEN MATCHED THEN
    UPDATE SET 
    a.maritalstatusDescription = B.[maritalstatusDescription];
