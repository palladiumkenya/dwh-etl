--DimDate
CREATE TABLE [dbo].DimDate(
	[DateKey] [int] PRIMARY KEY NOT NULL,
	[Date] [date] NULL,
	[Year]  [int] NULL,
	[Month] [int] NULL,
	[CalendarQuarter] [varchar](20) NULL,
	[CDCFinancialQuarter] [varchar](20) NULL,
	[LoadDate] [date] NULL
) 
GO