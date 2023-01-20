IF OBJECT_ID(N'[NDWH].[Dbo].[FactArt]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[Dbo].[FactArt];
BEGIN
	with MFL_partner_agency_combination as (
		select 
			distinct MFL_Code,
			SDP,
			[SDP_Agency] collate Latin1_General_CI_AS as Agency
		from ODS.dbo.All_EMRSites 
	),

	   Patient As ( Select    
     
		  Patient.PatientID,
		  Patient.PatientPK,
		  cast (Patient.SiteCode as nvarchar) As SiteCode,
		  DATEDIFF(yy,Patient.DOB,Patient.RegistrationAtCCC) AgeAtEnrol,
		  DATEDIFF(yy,Patient.DOB,ART.StartARTDate) AgeAtARTStart,
		  ART.StartARTAtThisfacility,
		  ART.PreviousARTStartDate,
		  ART.PreviousARTRegimen,
		  StartARTDate,
		  LastARTDate,
	  CASE WHEN [DateConfirmedHIVPositive] IS NOT NULL AND ART.StartARTDate IS NOT NULL
					 THEN CASE WHEN DateConfirmedHIVPositive<= ART.StartARTDate THEN DATEDIFF(DAY,DateConfirmedHIVPositive,ART.StartARTDate)
						ELSE NULL END
					ELSE NULL END AS TimetoARTDiagnosis,
		CASE WHEN Patient.RegistrationAtCCC IS NOT NULL AND ART.StartARTDate IS NOT NULL
					THEN CASE WHEN Patient.RegistrationAtCCC<=ART.StartARTDate  THEN DATEDIFF(DAY,Patient.[RegistrationAtCCC],ART.StartARTDate)
					ELSE NULL END
					ELSE NULL END AS TimetoARTEnrollment,
			Pre.PregnantARTStart,
			Pre.PregnantAtEnrol,
			las.LastEncounterDate As LastVisitDate,
			las.NextAppointmentDate,
			datediff(yy, patient.DOB, las.LastEncounterDate) as AgeLastVisit,
			lastRegimen,
			StartRegimen,
			lastRegimenline,
			StartRegimenline
       
	from 
	ODS.dbo.CT_Patient(NoLock) Patient
	left join ODS.dbo.CT_ARTPatients(NoLock) ART on ART.PatientPK=Patient.Patientpk and ART.SiteCode=Patient.SiteCode
	left join ODS.dbo.PregnancyAsATInitiation(NoLock)   Pre on Pre.Patientpk= Patient.PatientPK and Pre.SiteCode=Patient.SiteCode
	left join ODS.dbo.Intermediate_LastPatientEncounter(NoLock) las on las.PatientPK collate Latin1_General_CI_AS=Patient.PatientPK collate Latin1_General_CI_AS and las.SiteCode collate Latin1_General_CI_AS=Patient.SiteCode collate Latin1_General_CI_AS
	   )

	   Select 
				Factkey = IDENTITY(INT, 1, 1),
				pat.PatientKey,
				fac.FacilityKey,
				partner.PartnerKey,
				agency.AgencyKey,
				age_group.AgeGroupKey,
				StartARTDate.Date As StartARTDateKey,
				LastARTDate.DateKey  as LastARTDateKey,
				lastreg.RegimenKey As CurrentRegimen,
				lastregline.RegimenLineKey As CurrentRegimenLine,
				firstreg.RegimenKey As StartRegimen,
				firstregline.RegimenLineKey As StartRegimenLine,
				AgeAtEnrol,
				AgeAtARTStart,
				AgeLastVisit,
				TimetoARTDiagnosis,
				TimetoARTEnrollment,
				PregnantARTStart,
				PregnantAtEnrol,
				LastEncounterDate As LastVisitDate,
				Patient.NextAppointmentDate,
				StartARTAtThisfacility,
				PreviousARTStartDate,
				PreviousARTRegimen,
				outcome.ARTOutcome,
				cast(getdate() as date) as LoadDate

	 INTO [NDWH].[Dbo].[FactArt]
	   from  Patient
	left join NDWH.dbo.DimPatient(NoLock) as Pat on pat.PatientPK=Patient.PatientPk
	left join NDWH.dbo.Dimfacility(NoLock) fac on fac.MFLCode=Patient.SiteCode
	left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = Patient.SiteCode
	left join NDWH.dbo.DimPartner(NoLock) as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
	left join NDWH.dbo.DimAgeGroup(NoLock) as age_group on age_group.Age = Patient.AgeLastVisit
	left join NDWH.dbo.DimDate(NoLock) as StartARTDate on StartARTDate.Date= Patient.StartARTDate
	left join NDWH.dbo.DimDate(NoLock) as LastARTDate on  LastARTDate.Date=Patient.LastARTDate
	left join NDWH.dbo.DimRegimen(NoLock) lastreg on lastreg.Regimen=Patient.LastRegimen
	left join NDWH.dbo.DimRegimen(NoLock) firstreg on firstreg.Regimen=Patient.StartRegimen
	left join NDWH.dbo.DimRegimenLine(NoLock) lastregline on lastregline.RegimenLine=Patient.LastRegimenLine
	left join NDWH.dbo.DimRegimenLine(NoLock) firstregline on firstregline.RegimenLine=Patient.StartRegimenLine
	left join NDWH.dbo.DimAgency(NoLock) as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
	left join ODS.dbo.Intermediate_ARTOutcomes(NoLock)  outcome on outcome.PatientPK=Patient.PatientPK and outcome.SiteCode=Patient.SiteCode
 
	alter table [NDWH].[Dbo].[FactArt] add primary key(FactKey);
END

