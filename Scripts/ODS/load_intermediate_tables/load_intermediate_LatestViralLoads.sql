IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LatestViralLoads]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LatestViralLoads];
BEGIN
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
 		source_LatestViralLoads.*,					convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2) PatientPKHash,
		convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)PatientIDHash,
		cast(getdate() as date) as LoadDate
	into [ODS].[dbo].[Intermediate_LatestViralLoads]
	from source_LatestViralLoads
	where rank = 1
END
	

