-- DimPartner
CREATE TABLE [dbo].[DimPartner](
	[PartnerKey] [int] IDENTITY(1,1) NOT NULL,
	[PartnerName] [varchar](200) NULL,
	[LoadDate] [date] NULL
) 
GO