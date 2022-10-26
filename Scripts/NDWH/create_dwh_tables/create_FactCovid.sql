-- FactCovid
CREATE TABLE [dbo].FactCovid(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[VaccinationStatusKey] [int] NULL,
	[DateGivenFirstDoseKey] [int] NULL
)
GO