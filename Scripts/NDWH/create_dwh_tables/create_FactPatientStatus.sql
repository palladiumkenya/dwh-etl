--FactPatientStatus
CREATE TABLE [dbo].FactPatientStatus(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[DateExitKey] [int] NULL,
	[DateARTStopKey] [int] NULL,
	[DateTOKey] [int] NULL,
	[DateLTFUKey] [int] NULL,
	[DateDeadKey] [int] NULL
)
GO
