-- DimAgeGroup
CREATE TABLE [dbo].DimAgeGroup(
	[AgeGroupKey] [int] IDENTITY(1,1) NOT NULL,
	[Age] [int] NULL,
	[DATIMAgeGroup] [varchar](200) NULL,
	[MOHAgeGroup] [varchar](200) NULL,
	[LoadDate] [date] NULL
) 
GO
