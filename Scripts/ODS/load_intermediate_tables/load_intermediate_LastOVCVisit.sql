IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_LastOVCVisit]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_LastOVCVisit];
BEGIN
	with source_LasttOVCVisit as (
		select 
			row_number() over (partition by PatientID, SiteCode, PatientPK, EMR order by VisitDate desc) as rank,
			VisitDate, 
			PatientID ,
			SiteCode,
			PatientPK, 
			convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPK  as nvarchar(36))), 2) PatientPKHash,
			convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2)PatientIDHash,
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