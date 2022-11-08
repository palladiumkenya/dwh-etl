--FactOTZ
CREATE TABLE [dbo].FactOTZ(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[ModulesPreviouslyCovered] [varchar] (250) NULL,
	[OTZ_Orientation] [varchar] (50) NULL,
	[OTZ_Participation] [varchar] (50) NULL,
	[OTZ_Leadership] [varchar] (50) NULL,
	[OTZ_MakingDecisions] [varchar] (50) NULL,
	[OTZ_Transition] [varchar] (50) NULL,
	[OTZ_TreatmentLiteracy] [varchar] (50) NULL,
	[OTZ_SRH] [varchar] (50) NULL,	 
	[OTZ_Beyond] [varchar] (50) NULL,		 
	[SupportGroupInvolvement] [varchar] (20) NULL,
	[Remarks] [varchar] (250) NULL,		 
	[TransitionAttritionReason] [varchar] (250) NULL,
	[DateOutcomeKey] [int] NULL,
	[DateOTZEnrollmentKey] [int] NULL,
	[TransferInStatus] [varchar] (20) NULL
)
GO