	with cte AS (
	Select
	SiteCode,
	DateRecieved,
	 ROW_NUMBER() OVER (PARTITION BY SiteCode,DateRecieved ORDER BY
	SiteCode,DateRecieved) Row_Num
	FROM [DWAPICentral].[dbo].[FacilityManifest]
	)
delete from cte 
	Where Row_Num >1