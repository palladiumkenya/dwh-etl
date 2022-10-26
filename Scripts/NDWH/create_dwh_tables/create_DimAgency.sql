-- DimAgency
CREATE TABLE [dbo].[DimAgency](
	[AgencyKey] [int] IDENTITY(1,1) NOT NULL,
	[AgencyName] [varchar](200) NULL,
	[LoadDate] [date] NULL
) 
GO