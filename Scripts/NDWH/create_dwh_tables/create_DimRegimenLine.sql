--DimRegimenLine
CREATE TABLE [dbo].DimRegimenLine(
	[RegimenLineKey] [int] IDENTITY(1,1) NOT NULL,
	[RegimenLine] [varchar](50) NULL,
	[LoadDate] [date] NULL
) 
GO
