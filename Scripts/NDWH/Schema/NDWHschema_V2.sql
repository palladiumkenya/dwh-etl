USE [NDWH]
GO
/****** Object:  Table [dbo].[DimAdverseEvent]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAdverseEvent](
	[AdverseEventKey] [int] IDENTITY(1,1) NOT NULL,
	[AdverseEventID] [nvarchar](3200) NULL,
	[AdverseEvent] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimAdverseEventActionTaken]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAdverseEventActionTaken](
	[AdverseEventActionTakenKey] [int] IDENTITY(1,1) NOT NULL,
	[AdverseEventActionTakenID] [nvarchar](3200) NULL,
	[AdverseEventActionTaken] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimAdverseEventCause]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAdverseEventCause](
	[AdverseEventCauseKey] [int] IDENTITY(1,1) NOT NULL,
	[AdverseEventCauseID] [nvarchar](3200) NULL,
	[AdverseEventCause] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimAdverseEventRegimen]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAdverseEventRegimen](
	[AdverseEventRegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[AdverseEventRegimenID] [nvarchar](3200) NULL,
	[AdverseEventRegimen] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimAgeGroup]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAgeGroup](
	[AgeGroupKey] [int] IDENTITY(1,1) NOT NULL,
	[Age] [int] NOT NULL,
	[MOHAgeGroup] [varchar](8) NULL,
	[DATIMAgeGroup] [varchar](8) NULL,
PRIMARY KEY CLUSTERED 
(
	[AgeGroupKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimAgency]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimAgency](
	[AgencyKey] [int] IDENTITY(1,1) NOT NULL,
	[AgencyName] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimArtDaysBand]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimArtDaysBand](
	[ArtDaysBandKey] [int] IDENTITY(1,1) NOT NULL,
	[LowerLimit] [nvarchar](320) NULL,
	[UpperLimit] [nvarchar](320) NULL,
	[ArtDaysBand] [nvarchar](1600) NULL,
	[Row_Count] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimARTOutcome]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimARTOutcome](
	[ARTOutcomeKey] [int] IDENTITY(1,1) NOT NULL,
	[ARTOutcomeID] [nvarchar](640) NULL,
	[ARTOutcomeName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimBooster]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimBooster](
	[BoosterKey] [int] IDENTITY(1,1) NOT NULL,
	[BoosterDescription] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimCovidPatient]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimCovidPatient](
	[CovidPatientKey] [int] IDENTITY(1,1) NOT NULL,
	[CovidPatientID] [nvarchar](1600) NULL,
	[CovidPatientName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimDate]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDate](
	[DateKey] [int] NOT NULL,
	[Date] [date] NOT NULL,
	[DayNumberOfWeek] [tinyint] NULL,
	[DayNameOfWeek] [nvarchar](9) NULL,
	[DayNumberOfMonth] [smallint] NULL,
	[DayOfMonth] [nvarchar](2) NULL,
	[DayNumberOfYear] [smallint] NULL,
	[DayOfYear] [nvarchar](3) NULL,
	[WeekNumberOfMonth] [tinyint] NULL,
	[ISOWeekNumberOfYear] [tinyint] NULL,
	[ISOWeekOfYear] [nvarchar](2) NULL,
	[WeekNumberOfYear] [tinyint] NULL,
	[WeekOfYear] [nvarchar](2) NULL,
	[MonthName] [nvarchar](9) NULL,
	[MonthNumberOfYear] [tinyint] NULL,
	[MonthOfYear] [nvarchar](2) NULL,
	[CalendarQuarter] [tinyint] NULL,
	[CalendarQuarterName] [nvarchar](2) NULL,
	[CalendarSemester] [tinyint] NULL,
	[CalendarSemesterName] [nvarchar](2) NULL,
	[CalendarYear] [smallint] NULL,
	[FiscalQuarter] [tinyint] NULL,
	[FiscalQuarterName] [nvarchar](2) NULL,
	[FiscalSemester] [tinyint] NULL,
	[FiscalSemesterName] [nvarchar](2) NULL,
	[FiscalYear] [smallint] NULL,
	[EffectiveDate] [datetime] NULL,
	[LastUpdateDate] [datetime] NULL,
	[AllowAutoUpdateBitFlag] [bit] NULL,
	[WorkDay] [varchar](8) NULL,
	[IsWorkDay] [bit] NULL,
	[EOMONTHDATE] [date] NULL,
	[workingDays] [int] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimDifferentiatedCare]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDifferentiatedCare](
	[DifferentiatedCareKey] [int] IDENTITY(1,1) NOT NULL,
	[DifferentiatedCare] [nvarchar](3200) NULL,
PRIMARY KEY CLUSTERED 
(
	[DifferentiatedCareKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimDrug]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimDrug](
	[DrugKey] [int] IDENTITY(1,1) NOT NULL,
	[Drug] [varchar](250) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[DrugKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimEMR]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimEMR](
	[EMRKey] [int] IDENTITY(1,1) NOT NULL,
	[EMRID] [nvarchar](3200) NULL,
	[EMRDesription] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimExitReason]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimExitReason](
	[ExitReasonKey] [int] IDENTITY(1,1) NOT NULL,
	[ExitReasonID] [nvarchar](3200) NULL,
	[ExitReason] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimFacility]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimFacility](
	[FacilityKey] [int] IDENTITY(1,1) NOT NULL,
	[MFLCode] [nvarchar](30) NULL,
	[FacilityName] [varchar](250) NULL,
	[SubCounty] [varchar](250) NULL,
	[County] [varchar](250) NULL,
	[EMR] [varchar](50) NULL,
	[Project] [varchar](100) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude] [varchar](50) NULL,
	[DateSiteAbstractionKey] [int] NULL,
	[LatestDateUploadedKey] [int] NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[FacilityKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimFamilyPlanning]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimFamilyPlanning](
	[FamilyPlanningKey] [int] IDENTITY(1,1) NOT NULL,
	[FamilyPlanning] [varchar](150) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[FamilyPlanningKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimFirstDoseVaccineAdministered]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimFirstDoseVaccineAdministered](
	[FirstDoseVaccineAdministeredKey] [int] IDENTITY(1,1) NOT NULL,
	[FirstDoseVaccineAdministered] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimFirstVL]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimFirstVL](
	[FirstVLKey] [int] IDENTITY(1,1) NOT NULL,
	[FirstVL] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimGender]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimGender](
	[GenderKey] [int] IDENTITY(1,1) NOT NULL,
	[GenderID] [nvarchar](160) NULL,
	[GenderDesription] [nvarchar](320) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsBoosterGiven]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsBoosterGiven](
	[IsBoosterGivenKey] [int] IDENTITY(1,1) NOT NULL,
	[IsBoosterGivenDesription] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsFullyVaccinated]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsFullyVaccinated](
	[IsFullyVaccinatedKey] [int] IDENTITY(1,1) NOT NULL,
	[IsFullyVaccinatedDesription] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsOnIpt]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsOnIpt](
	[IsOnIptKey] [int] IDENTITY(1,1) NOT NULL,
	[IsOnIptID] [nvarchar](320) NULL,
	[IsOnIpt] [nvarchar](320) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimISOnTBDrugs]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimISOnTBDrugs](
	[ISOnTBDrugsKey] [int] IDENTITY(1,1) NOT NULL,
	[ISOnTBDrugsID] [nvarchar](320) NULL,
	[ISOnTBDrugs] [nvarchar](320) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsPartiallyVaccinated]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsPartiallyVaccinated](
	[IsPartiallyVaccinatedKey] [int] IDENTITY(1,1) NOT NULL,
	[IsPartiallyVaccinatedDesription] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsScreenedForCovid]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsScreenedForCovid](
	[IsScreenedForCovidKey] [int] IDENTITY(1,1) NOT NULL,
	[IsScreenedForCovidDesription] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsVaccinated]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsVaccinated](
	[IsVaccinatedKey] [int] IDENTITY(1,1) NOT NULL,
	[IsVaccinatedID] [nvarchar](160) NULL,
	[IsVaccinatedDescription] [nvarchar](320) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimIsVaccineVerified]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimIsVaccineVerified](
	[IsVaccineVerifiedKey] [int] IDENTITY(1,1) NOT NULL,
	[IsVaccineVerifiedID] [nvarchar](160) NULL,
	[IsVaccineVerified] [nvarchar](320) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimKeyPopulationType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimKeyPopulationType](
	[KeyPopulationTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[KeyPopulationType] [varchar](250) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[KeyPopulationTypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimLastRegimen]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLastRegimen](
	[LastRegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[LastRegimenID] [nvarchar](4000) NULL,
	[LastRegimen] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimLastRegimenLine]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLastRegimenLine](
	[LastRegimenLineKey] [int] IDENTITY(1,1) NOT NULL,
	[LastRegimenLineID] [nvarchar](4000) NULL,
	[LastRegimenLine] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimLastVL]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimLastVL](
	[LastVLKey] [int] IDENTITY(1,1) NOT NULL,
	[LastVL] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimMaritalStatus]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimMaritalStatus](
	[MaritalStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[MaritalStatusDescription] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPartner]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPartner](
	[PartnerKey] [int] IDENTITY(1,1) NOT NULL,
	[PartnerName] [nvarchar](100) NULL,
	[LoadDate] [date] NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPartnerAndAgencyBridge]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPartnerAndAgencyBridge](
	[PartnerKey] [int] NULL,
	[CountyKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PartnerID] [nvarchar](3200) NULL,
	[PartnerName] [nvarchar](3200) NULL,
	[CountyName] [nvarchar](3200) NULL,
	[AgencyName] [nvarchar](640) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPatient]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPatient](
	[PatientKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [nvarchar](64) NULL,
	[PatientPK] [nvarchar](64) NULL,
	[SiteCode] [varchar](50) NULL,
	[Gender] [varchar](250) NULL,
	[DOB] [date] NULL,
	[MaritalStatus] [varchar](250) NULL,
	[Nupi] [nvarchar](100) NULL,
	[PatientType] [varchar](250) NULL,
	[PatientSource] [varchar](250) NULL,
	[EnrollmentWHOKey] [varchar](50) NULL,
	[DateEnrollmentWHOKey] [int] NULL,
	[BaseLineWHOKey] [varchar](50) NULL,
	[DateBaselineWHOKey] [int] NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[PatientKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPatientSource]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPatientSource](
	[PatientSourceKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientSourceID] [nvarchar](1600) NULL,
	[PatientSourceName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPatientType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPatientType](
	[PatientTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientTypeID] [nvarchar](640) NULL,
	[PatientTypeName] [nvarchar](640) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPopulationType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPopulationType](
	[PopulationTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[PopulationType] [varchar](250) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[PopulationTypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimPreviousARTRegimen]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimPreviousARTRegimen](
	[PreviousARTRegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[PreviousARTRegimenID] [nvarchar](4000) NULL,
	[PreviousARTRegimen] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimProject]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimProject](
	[ProjectKey] [int] IDENTITY(1,1) NOT NULL,
	[ProjectID] [nvarchar](640) NULL,
	[ProjectName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimProphylaxisType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimProphylaxisType](
	[ProphylaxisTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[ProphylaxisTypeID] [nvarchar](3200) NULL,
	[ProphylaxisType] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimRegimen]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRegimen](
	[RegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[RegimenID] [nvarchar](4000) NULL,
	[Regimen] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimRegimenLine]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRegimenLine](
	[RegimenLineKey] [int] IDENTITY(1,1) NOT NULL,
	[RegimenLine] [varchar](250) NULL,
	[RegimenLineCategory] [varchar](11) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[RegimenLineKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimRegion]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRegion](
	[RegionKey] [int] IDENTITY(1,1) NOT NULL,
	[SubCountyKey] [int] NULL,
	[RegionID] [nvarchar](640) NULL,
	[RegionName] [nvarchar](640) NULL,
	[SubCounty] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimRelationshipWithPatient]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimRelationshipWithPatient](
	[RelationshipWithPatientKey] [int] IDENTITY(1,1) NOT NULL,
	[RelationshipWithPatient] [nvarchar](4000) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[RelationshipWithPatientKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimSecondDoseVaccineAdministered]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSecondDoseVaccineAdministered](
	[SecondDoseVaccineAdministeredKey] [int] IDENTITY(1,1) NOT NULL,
	[SecondDoseVaccineAdministered] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimSevereEvent]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSevereEvent](
	[SevereEventKey] [int] IDENTITY(1,1) NOT NULL,
	[SevereEventID] [nvarchar](3200) NULL,
	[SevereEvent] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimStabilityAssessment]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStabilityAssessment](
	[StabilityAssessmentKey] [int] IDENTITY(1,1) NOT NULL,
	[StabilityAssessmentID] [nvarchar](3200) NULL,
	[StabilityAssessment] [nvarchar](3200) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimStartRegimen]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStartRegimen](
	[StartRegimenKey] [int] IDENTITY(1,1) NOT NULL,
	[StartRegimenID] [nvarchar](4000) NULL,
	[StartRegimen] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimStartRegimenLine]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimStartRegimenLine](
	[StartRegimenLineKey] [int] IDENTITY(1,1) NOT NULL,
	[StartRegimenLineID] [nvarchar](4000) NULL,
	[StartRegimenLine] [nvarchar](4000) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimSubCounty]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimSubCounty](
	[SubCountyKey] [int] IDENTITY(1,1) NOT NULL,
	[RegionKey] [int] NULL,
	[County] [nvarchar](1600) NULL,
	[SubCountyID] [nvarchar](1600) NULL,
	[SubCountyName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimTBScreening]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTBScreening](
	[TBScreeningKey] [int] IDENTITY(1,1) NOT NULL,
	[TBScreeningID] [nvarchar](1600) NULL,
	[TBScreening] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimTreatmentType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimTreatmentType](
	[TreatmentTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[TreatmentType] [varchar](20) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[TreatmentTypeKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimVaccinationStatus]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimVaccinationStatus](
	[VaccinationStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[VaccinationStatus] [nvarchar](4000) NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[VaccinationStatusKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimVaccineDoseType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimVaccineDoseType](
	[VaccineDoseTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[VaccineDoseTypeID] [nvarchar](640) NULL,
	[VaccineName] [nvarchar](640) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimVillage]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimVillage](
	[VillageKey] [int] IDENTITY(1,1) NOT NULL,
	[VillageID] [nvarchar](1600) NULL,
	[VillageName] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DimvisitType]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DimvisitType](
	[visitTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[visitTypeID] [nvarchar](1600) NULL,
	[visitTypeDesription] [nvarchar](1600) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactARTHistory]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactARTHistory](
	[FactARTHistoryKey] [int] IDENTITY(1,1) NOT NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[PatientKey] [int] NULL,
	[AsOfDateKey] [int] NULL,
	[IsTXCurr] [int] NOT NULL,
	[ARTOutcomeKey] [int] NULL,
	[LoadDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[FactARTHistoryKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactLatestObs]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactLatestObs](
	[Factkey] [int] IDENTITY(1,1) NOT NULL,
	[PatientKey] [int] NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[DifferentiatedCareKey] [int] NULL,
	[LatestHeight] [varchar](150) NULL,
	[LatestWeight] [varchar](150) NULL,
	[AgeLastVisit] [int] NULL,
	[Adherence] [varchar](150) NULL,
	[DifferentiatedCare] [nvarchar](300) NULL,
	[onMMD] [int] NULL,
	[StabilityAssessment] [nvarchar](300) NULL,
	[Pregnant] [varchar](150) NULL,
PRIMARY KEY CLUSTERED 
(
	[Factkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactOTZ]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOTZ](
	[Factkey] [int] IDENTITY(1,1) NOT NULL,
	[PatientKey] [int] NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[OTZEnrollmentDateKey] [int] NULL,
	[LastVisitDateKey] [int] NULL,
	[TransferInStatus] [nvarchar](300) NULL,
	[ModulesPreviouslyCovered] [nvarchar](300) NULL,
	[ModulesCompletedToday_OTZ_Orientation] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_Participation] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_Leadership] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_MakingDecisions] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_Transition] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_TreatmentLiteracy] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_SRH] [int] NOT NULL,
	[ModulesCompletedToday_OTZ_Beyond] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Factkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[FactOVC]    Script Date: 11/30/2022 4:03:39 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[FactOVC](
	[Factkey] [int] IDENTITY(1,1) NOT NULL,
	[PatientKey] [int] NULL,
	[FacilityKey] [int] NULL,
	[PartnerKey] [int] NULL,
	[AgencyKey] [int] NULL,
	[AgeGroupKey] [int] NULL,
	[OVCEnrollmentDateKey] [int] NULL,
	[RelationshipWithPatientKey] [int] NULL,
	[EnrolledinCPIMS] [nvarchar](300) NULL,
	[CPIMSUniqueIdentifier] [nvarchar](300) NULL,
	[PartnerOfferingOVCServices] [nvarchar](300) NULL,
	[OVCExitReason] [nvarchar](300) NULL,
	[OVCExitDateKey] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[Factkey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
