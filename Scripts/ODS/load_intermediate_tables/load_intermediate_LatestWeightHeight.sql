with source_LatestWeightHeight as (
	select  
		row_number() over (partition by PatientID ,SiteCode,PatientPK order by VisitDate desc) as rank,
		VisitDate,
		PatientID ,
		SiteCode,
		PatientPK,
		VisitID,
		Weight,
		Height,
		VisitBy
	from ODS.dbo.CT_PatientVisits
	where Weight is not null 
)
select 
	source_LatestWeightHeight.*,
	cast(getdate() as date) as LoadDate
into Intermediate_LastestWeightHeight
from source_LatestWeightHeight
where rank = 1
