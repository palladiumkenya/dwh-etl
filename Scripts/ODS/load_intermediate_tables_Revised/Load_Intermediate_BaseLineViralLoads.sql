IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_BaseLineViralLoads]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_BaseLineViralLoads];
BEGIN
	with source_BaseLineViralLoads as (
		select
			row_number() over(partition by PatientID, SiteCode, PatientPK order by OrderedbyDate asc) as rank, 
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
		from ODS.dbo.CT_PatientLabs(NoLock)
		where TestName = 'Viral Load'
				and TestName <>'CholesterolLDL (mmol/L)' and TestName <> 'Hepatitis C viral load' 
				and TestResult is not null
	)
	select 
 		source_BaseLineViralLoads.*,
		cast(getdate() as date) as LoadDate
	into [ODS].[dbo].[Intermediate_BaseLineViralLoads]
	from source_BaseLineViralLoads
	where rank = 1
END