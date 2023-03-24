IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastOVCVisit]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastOVCVisit];
BEGIN
	with source_LasttOVCVisit as (
		select 
			row_number() over (partition by SiteCode, PatientPK, EMR order by VisitDate desc) as rank,
			VisitDate, 
			PatientID ,
			SiteCode,
			PatientPK, 
			EMR, 
			VisitID, 
			OVCEnrollmentDate,
			RelationshipToClient,
			EnrolledinCPIMS,
			CPIMSUniqueIdentifier,
			PartnerOfferingOVCServices,
			OVCExitReason,
			ExitDate
		from ODS.dbo.CT_Ovc
	)
	select         
		VisitDate as LatestVisitDate, 
		PatientID ,
		SiteCode,
		PatientPK, 
		cast( '' as nvarchar(100)) PatientIDHash,
		cast( '' as nvarchar(100)) PatientPKHash,
		EMR, 
		VisitDate,
		VisitID, 
		OVCEnrollmentDate,
		RelationshipToClient,
		EnrolledinCPIMS,
		CPIMSUniqueIdentifier,
		PartnerOfferingOVCServices,
		OVCExitReason,
		ExitDate,
		cast(getdate() as date) as LoadDate
	into [ODS].[dbo].[Intermediate_LastOVCVisit]
	from source_LasttOVCVisit
	where rank = 1
END