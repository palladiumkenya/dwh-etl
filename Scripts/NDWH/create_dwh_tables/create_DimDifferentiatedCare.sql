--DimDifferentiatedCare
CREATE TABLE [dbo].DimDifferentiatedCare(
	[DifferentiatedCareKey] [int] IDENTITY(1,1) NOT NULL,
	[DifferentiatedCareName] [varchar](100) NULL,
	[LoadDate] [date] NULL

) 
GO