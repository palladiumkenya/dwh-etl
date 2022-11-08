--DimRelationtoClient
CREATE TABLE [dbo].DimRelationtoClient(
	[DimRelationtoClientKey] [int] IDENTITY(1,1) NOT NULL,
	[DimRelationtoClient] [varchar](100) NULL,
	[LoadDate] [date] NULL
) 
GO