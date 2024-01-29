BEGIN
	INSERT INTO [NDWH].[dbo].[FactARTHistory]([FacilityKey],[PartnerKey],[AgencyKey],[PatientKey],[AsOfDateKey],[IsTXCurr],
												[ARTOutcomeKey],[NextAppointmentDate],[LastEncounterDate],[LoadDate],DateTimeStamp)
	SELECT [FacilityKey],[PartnerKey],[AgencyKey],[PatientKey],[AsOfDateKey] [AsOfDateKey],
		 ARTOutcomeKey,
		
		[ARTOutcomeKey],[NextAppointmentDate],LastVisitDate,[LoadDate],
		Getdate() As DateTimeStamp
	FROM [NDWH].[dbo].[FactART]
END