--FactOVC
CREATE TABLE [dbo].FactOVC(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[DateOVCEnrollmentKey] [int] NULL,
	[RelationshipToClientKey] [int] NULL,
	[IsEnrolledinCPIMS] [varchar] (10) NULL,
	[CPIMSUniqueIdentifier] [varchar] (200) NULL,
	[PartnerOfferingOVCServices] [varchar] (200) NULL,
	[OVCExitReason] [varchar] (100) NULL,
	[DateOVCExitKey] [int] NULL
)
GO