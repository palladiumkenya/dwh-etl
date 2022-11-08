-- DimVaccinationStatus
CREATE TABLE [dbo].DimVaccinationStatus(
	[VaccinationStatusKey] [int] IDENTITY(1,1) NOT NULL,
	[VaccinationStatus] [varchar](50) NULL,
	[LoadDate] [date] NULL
) 
GO