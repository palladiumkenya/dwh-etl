--FactTPT
CREATE TABLE [dbo].FactTPT(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[DateStartIPTKey] [int] NULL,
	[DateTBDiagKey] [int] NULL,
	[DateStartTBTxKey] [int] NULL,
	[IsOnIPT] [bit] NULL,
	[HasTB] [bit] NULL
)
GO