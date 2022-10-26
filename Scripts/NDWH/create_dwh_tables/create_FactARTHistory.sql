--FactARTHistory
CREATE TABLE [dbo].FactARTHistory(
	 [FactKey] [int] IDENTITY(1,1) NOT NULL,
	 [FacilityKey] [int] NULL,
	 [PartnerKey] [int] NULL,
	 [AgencyKey] [int] NULL,
	 [PatientKey] [int] NULL,
	 [AsOfDateKey] [int] NULL,
	 [IsTXCurr] [bit] NOT NULL,
	 [ARTOutcomeKey] [int] NOT NULL,
	 --[DateNextAppointment] [int] NULL,
	 --[DateLastVisitKey] [int] NULL,
	 --[AgeLastVisit] [int] NULL,
	 [LoadDate] [date] NULL
)
GO