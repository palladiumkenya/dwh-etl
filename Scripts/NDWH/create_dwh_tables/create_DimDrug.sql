--DimDrug
CREATE TABLE [dbo].DimAgDrug(
	[DrugKey] [int] IDENTITY(1,1) NOT NULL,
	[Drug] [varchar](200) NULL,
	[TreatmentType] [varchar](200) NULL,
	[LoadDate] [date] NULL
) 
GO