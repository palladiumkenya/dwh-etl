
	MERGE [NDWH].[dbo].[DimFacility] AS a
	USING(SELECT DISTINCT MFL_Code,[Facility Name],County,SubCounty,[owner],SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]
	FROM [ODS].[dbo].[All_EMRSites] WHERE MFL_Code !='') AS b 
	ON(a.FacilityCode =b.MFL_Code)
	--WHEN MATCHED THEN
 --   UPDATE SET 
 --   a.FacilityName = B.[Facility Name]
	WHEN NOT MATCHED THEN 
	INSERT(FacilityCode,FacilityName,County,District,owner,SDP,[SDP_Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]) 
	VALUES(MFL_Code,[Facility Name],County,SubCounty,[owner],SDP,[SDP Agency],Implementation,EMR,[EMR Status],[HTS Use],[Project]);
