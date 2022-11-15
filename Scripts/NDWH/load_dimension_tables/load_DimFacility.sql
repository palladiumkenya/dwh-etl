---DimFacility Load
with source_facility as (
	select
		cast(MFL_Code as nvarchar) as MFLCode,
		[Facility Name] as [FacilityName],
		SubCounty,
		County,
		EMR,
		Project,
		Longitude,
		Latitude		
	from HIS_Implementation.dbo.All_EMRSites
),
site_abstraction as (
	select
		SiteCode,
		max(VisitDate) as DateSiteAbstraction
	from All_Staging.dbo.stg_PatientVisits
	group by SiteCode
),
latest_upload as (
	select  
			SiteCode,
			max(cast([DateRecieved] as date)) as LatestDateUploaded
	from [DWAPICentral].[dbo].[FacilityManifest](NoLock) 
	group by SiteCode
)
select 
	FacilityKey = IDENTITY(INT, 1, 1),
	source_facility.*,
	cast(format(site_abstraction.DateSiteAbstraction,'yyyyMMdd') as int) as DateSiteAbstractionKey,
	cast(format(latest_upload.LatestDateUploaded, 'yyyyMMdd') as int) as LatestDateUploadedKey,
	cast(getdate() as date) as LoadDate
into dbo.DimFacility
from source_facility
left join site_abstraction on site_abstraction.SiteCode = source_facility.MFLCode
left join latest_upload on latest_upload.SiteCode = source_facility.MFLCode;
ALTER TABLE dbo.DimFacility ADD PRIMARY KEY(FacilityKey);