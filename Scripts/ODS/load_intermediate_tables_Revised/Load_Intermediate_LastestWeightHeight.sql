IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastestWeightHeight]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastestWeightHeight];
BEGIN
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
		from ODS.dbo.CT_PatientVisits(NoLock)
		where Weight is not null 
	)
	SELECT 
		source_LatestWeightHeight.*,
		cast(getdate() as date) as LoadDate
	INTO [ODS].[dbo].[Intermediate_LastestWeightHeight]
	FROM source_LatestWeightHeight
	where rank = 1
END
