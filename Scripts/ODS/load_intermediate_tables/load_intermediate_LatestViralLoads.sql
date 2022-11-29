with source_LatestViralLoads as (
	select
		row_number() over(partition by PatientID, SiteCode, PatientPK order by OrderedbyDate desc) as rank, 
		PatientID,
		SiteCode,
		PatientPK,
		VisitID,
		[OrderedbyDate],
		[ReportedbyDate],
		[TestName],
		TestResult,
		[Emr],
		[Project],
		Reason
	from ODS.dbo.CT_PatientLabs
	where TestName = 'Viral Load'
			and TestName <>'CholesterolLDL (mmol/L)' and TestName <> 'Hepatitis C viral load' 
			and TestResult is not null
)
select 
 	source_LatestViralLoads.*,
	cast(getdate() as date) as LoadDate
into dbo.Intermediate_LatestViralLoads
from source_LatestViralLoads
where rank = 1
	

