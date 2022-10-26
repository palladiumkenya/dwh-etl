--FactCD4
CREATE TABLE [dbo].FactCD4(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[CD4atEnrollment] [int] NULL,
	[DateCD4atEnrollmentKey] [int] NULL,
	[LastCD4] [int] NULL,
	[DatelastCD4Key] [int] NULL
)
GO