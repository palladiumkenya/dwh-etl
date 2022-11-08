--DimKeyPopulationType
CREATE TABLE [dbo].DimKeyPopulationType(
	[KeyPopulationTypeKey] [int] IDENTITY(1,1) NOT NULL,
	[KeyPopulationType] [varchar](100) NULL,
	[LoadDate] [date] NULL
) 
GO
