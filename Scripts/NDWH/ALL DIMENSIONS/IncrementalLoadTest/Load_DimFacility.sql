

MERGE [NDWH].[dbo].[DimFacility] AS a
		USING	(	SELECT
							DISTINCT cast(MFL_Code as nvarchar) as MFLCode,
							Facility_Name as [FacilityName],
							SubCounty,
							County,
							EMRSites.EMR,		
							EMRSites.Project,
							Longitude,
							Latitude,
							Implementation,
							CAST(FORMAT(MAX(VisitDate),'yyyyMMdd') AS INT) AS DateSiteAbstractionKey,
							CAST(FORMAT(MAX([DateRecieved]),'yyyyMMdd') AS INT) AS LatestDateUploadedKey,
							CASE 
								WHEN [Implementation] LIKE '%CT%' THEN 1 
								ELSE 0 
							END AS isCT,
							CASE 
								WHEN [Implementation] LIKE '%CT%' THEN 1 
								ELSE 0 
							END AS isPKV,
							CASE 
								WHEN [Implementation] LIKE '%HTS%' THEN 1 
								ELSE 0 
							END AS isHTS,
							GETDATE() AS LoadDate
					FROM ODS.dbo.All_EMRSites EMRSites
						LEFT JOIN ODS.dbo.CT_PatientVisits Visits
							ON EMRSites.MFL_Code = Visits.SiteCode
						LEFT JOIN [ODS].[dbo].[CT_FacilityManifest] FacilityManifest
							ON EMRSites.MFL_Code = FacilityManifest.SiteCode 
					GROUP BY 	EMRSites.MFL_Code,Facility_Name,
								SubCounty,
								County,
								EMRSites.EMR,
								EMRSites.Project,
								Longitude,
								Latitude,
								Implementation
				) AS b 
						ON(
							a.MFLCode = b.MFLCode
						  )
		WHEN NOT MATCHED THEN 
						INSERT(MFLCode,FacilityName,SubCounty,County,EMR,Project,Longitude,Latitude,Implementation,DateSiteAbstractionKey,LatestDateUploadedKey,isCT,isPKV,isHTS,LoadDate) 
						VALUES(MFLCode,FacilityName,SubCounty,County,EMR,Project,Longitude,Latitude,Implementation,DateSiteAbstractionKey,LatestDateUploadedKey,isCT,isPKV,isHTS,LoadDate)
		WHEN MATCHED THEN
						UPDATE SET 						
						a.FacilityName =b.FacilityName,
						a.SubCounty  = b.SubCounty,
						a.County  = b.County,
						a.Longitude = b.Longitude,
						a.Latitude  = b.Latitude,
						a.Implementation = b.Implementation;



