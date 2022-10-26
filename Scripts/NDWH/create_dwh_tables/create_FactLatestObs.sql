--FactLatestObs
CREATE TABLE [dbo].FactLatestObs(
	[FactKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[PopulationTypeKey] [int] NULL,
	[KeyPopulationTypeKey] [int] NULL,
	[LatestWeight] [int] NULL,
	[LatestHeight] [int] NULL,
	[Adherence] [varchar] (20) NULL,
	[DifferentiatedCareKey] [int] NULL,
	[IsOnMMD] [bit] NULL,
	[StabilityAssessment] [bit] NULL,
	[LatestPregnancy] [varchar] (10) NULL,
	[LatestFPMethodKey] [int] NULL
)
GO