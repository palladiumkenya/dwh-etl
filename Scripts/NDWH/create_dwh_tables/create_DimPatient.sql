-- DimPatient
CREATE TABLE [dbo].DimPatient(
	[PatientKey] [int] IDENTITY(1,1) NOT NULL,
	[PatientID] [nvarchar] (100) NULL,
	[PatientPK]  [nvarchar](100) NULL,
	[SiteCode] [int] NULL,
	[Gender] [varchar](10) NULL,
	[DOB] [date] NULL,
	[MaritalStatus] [varchar](50) NULL,
	[Nupi] [varchar](50) NULL,
	[PatientType] [varchar](50) NULL,
	[PatientSource] [varchar] (100) NULL,
	[EnrollmentWHOKey] [varchar] (50) NULL,
	[DateEnrollmentWHOKey] [int] NULL,
	[BaseLineWHOKey] [varchar] (50) NULL,
	[DateBaselineWHOKey][int] NULL,
	[LoadDate] [date] NULL
) 
GO