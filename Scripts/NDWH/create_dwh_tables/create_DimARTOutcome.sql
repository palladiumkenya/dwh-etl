--DimARTOutcome
CREATE TABLE [dbo].DimARTOutcome(
	[ARTOutcomeKey] [int] IDENTITY(1,1) NOT NULL,
	[ARTOutcome] [varchar](20) NULL,
	[ARTOutcomeDescription] [varchar](20) NULL,
	[LoadDate] [date] NULL

) 
GO
