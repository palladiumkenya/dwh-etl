--DimFamilyPlanning
CREATE TABLE [dbo].DimFamilyPlanning(
	[FamilyPlanningKey] [int] IDENTITY(1,1) NOT NULL,
	[FamilyPlanningName] [varchar](100) NULL,
	[LoadDate] [date] NULL
) 
GO
