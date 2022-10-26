-- DimFacility
CREATE TABLE [dbo].[DimFacility](
	[FacilityKey] [int] IDENTITY(1,1) NOT NULL,
	[MFLCode] [nvarchar](50) NULL,
	[FacilityName] [varchar](100) NULL,
	[SubCounty] [varchar](100) NULL,
	[County] [varchar](100) NULL,
	[EMR] [varchar](50) NULL,
	[Project] [varchar](50) NULL,
	[Longitude] [varchar](50) NULL,
	[Latitude][varchar](50) NULL,
	[DateLastUploadedKey] [int] NULL,
	[DateSiteAbstractionKey] [int] NULL,
	[LoadDate] [date] NULL
) 
GO
