BEGIN 
MERGE [ODS].[dbo].[CT_CancerScreening] AS a USING(
	SELECT  DISTINCT F.Code AS SiteCode
		,P.patientPID AS PatientPK
		,P.PatientcccNumber AS PatientID
		,CSE.Emr
		,CSE.Project
		,CSE.Voided
		,CSE.Id
		,F.[name] AS FacilityName
		,VisitType
		,VisitID
		,VisitDate
		,SmokesCigarette
		,NumberYearsSmoked
		,NumberCigarettesPerDay
		,OtherFormTobacco
		,TakesAlcohol
		,HIVStatus
		,FamilyHistoryOfCa
		,PreviousCaTreatment
		,SymptomsCa
		,CancerType
		,FecalOccultBloodTest
		,TreatmentOccultBlood
		,Colonoscopy
		,TreatmentColonoscopy
		,EUA
		,TreatmentRetinoblastoma
		,RetinoblastomaGene
		,TreatmentEUA
		,DRE
		,TreatmentDRE
		,PSA
		,TreatmentPSA
		,VisualExamination
		,TreatmentVE
		,Cytology
		,TreatmentCytology
		,Imaging
		,TreatmentImaging
		,Biopsy
		,TreatmentBiopsy
		,PostTreatmentComplicationCause
		,OtherPostTreatmentComplication
		,ReferralReason
		,ScreeningMethod
		,TreatmentToday
		,ReferredOut
		,NextAppointmentDate
		,ScreeningType
		,HPVScreeningResult
		,TreatmentHPV
		,VIAScreeningResult
		,VIAVILIScreeningResult
		,VIATreatmentOptions
		,PAPSmearScreeningResult
		,TreatmentPapSmear
		,ReferalOrdered
		,Colposcopy
		,TreatmentColposcopy
		,BiopsyCINIIandAbove
		,BiopsyCINIIandBelow
		,BiopsyNotAvailable
		,CBE
		,TreatmentCBE
		,Ultrasound
		,TreatmentUltraSound
		,IfTissueDiagnosis
		,DateTissueDiagnosis
		,ReasonNotDone
		,FollowUpDate
		,Referred
		,ReasonForReferral
		,CSE.RecordUUID
		,CSE.Date_Created
		,CSE.Date_Last_Modified
		,CSE.Created
	FROM [DWAPICentral].[dbo].[CancerScreeningExtract] CSE
	INNER JOIN [DWAPICentral].[dbo].[PatientExtract] P
	ON CSE.[PatientId] = P.ID
	INNER JOIN [DWAPICentral].[dbo].[Facility] F
	ON P.[FacilityId] = F.Id
	WHERE p.gender != 'Unknown' 
) AS b ON( a.SiteCode = b.SiteCode
	AND a.PatientPK = b.PatientPK
	AND a.visitID = b.visitID
	and a.voided   = b.voided
	AND a.visitDate = b.visitDate

	AND a.ID = b.ID 
) WHEN NOT MATCHED THEN INSERT(
	Sitecode, PatientPK, PatientID, Emr, Project, Voided, Id, FacilityName, VisitType, VisitID, VisitDate, SmokesCigarette, NumberYearsSmoked, NumberCigarettesPerDay, OtherFormTobacco, TakesAlcohol, HIVStatus, FamilyHistoryOfCa, PreviousCaTreatment, SymptomsCa, CancerType, FecalOccultBloodTest, TreatmentOccultBlood, Colonoscopy, TreatmentColonoscopy, EUA, TreatmentRetinoblastoma, RetinoblastomaGene, TreatmentEUA, DRE, TreatmentDRE, PSA, TreatmentPSA, VisualExamination, TreatmentVE, Cytology, TreatmentCytology, Imaging, TreatmentImaging, Biopsy, TreatmentBiopsy, PostTreatmentComplicationCause, OtherPostTreatmentComplication, ReferralReason, ScreeningMethod, TreatmentToday, ReferredOut, NextAppointmentDate, ScreeningType, HPVScreeningResult, TreatmentHPV, VIAScreeningResult, VIAVILIScreeningResult, VIATreatmentOptions, PAPSmearScreeningResult, TreatmentPapSmear, ReferalOrdered, Colposcopy, TreatmentColposcopy, BiopsyCINIIandAbove, BiopsyCINIIandBelow, BiopsyNotAvailable, CBE, TreatmentCBE, Ultrasound, TreatmentUltraSound, IfTissueDiagnosis, DateTissueDiagnosis, ReasonNotDone, FollowUpDate, Referred, ReasonForReferral, RecordUUID, Date_Created, Date_Last_Modified, Created, LoadDate) VALUES(Sitecode, PatientPK, PatientID, Emr, Project, Voided, Id, FacilityName, VisitType, VisitID, VisitDate, SmokesCigarette, NumberYearsSmoked, NumberCigarettesPerDay, OtherFormTobacco, TakesAlcohol, HIVStatus, FamilyHistoryOfCa, PreviousCaTreatment, SymptomsCa, CancerType, FecalOccultBloodTest, TreatmentOccultBlood, Colonoscopy, TreatmentColonoscopy, EUA, TreatmentRetinoblastoma, RetinoblastomaGene, TreatmentEUA, DRE, TreatmentDRE, PSA, TreatmentPSA, VisualExamination, TreatmentVE, Cytology, TreatmentCytology, Imaging, TreatmentImaging, Biopsy, TreatmentBiopsy, PostTreatmentComplicationCause, OtherPostTreatmentComplication, ReferralReason, ScreeningMethod, TreatmentToday, ReferredOut, NextAppointmentDate, ScreeningType, HPVScreeningResult, TreatmentHPV, VIAScreeningResult, VIAVILIScreeningResult, VIATreatmentOptions, PAPSmearScreeningResult, TreatmentPapSmear, ReferalOrdered, Colposcopy, TreatmentColposcopy, BiopsyCINIIandAbove, BiopsyCINIIandBelow, BiopsyNotAvailable, CBE, TreatmentCBE, Ultrasound, TreatmentUltraSound, IfTissueDiagnosis, DateTissueDiagnosis, ReasonNotDone, FollowUpDate, Referred, ReasonForReferral, RecordUUID, Date_Created, Date_Last_Modified, Created, Getdate()
) WHEN MATCHED THEN UPDATE

SET a.[Voided] = b.[Voided], a.[Id] = b.[Id], a.[FacilityName] = b.[FacilityName], a.[VisitType] = b.[VisitType], a.[VisitID] = b.[VisitID], a.[VisitDate] = b.[VisitDate], a.[SmokesCigarette] = b.[SmokesCigarette], a.[NumberYearsSmoked] = b.[NumberYearsSmoked], a.[NumberCigarettesPerDay] = b.[NumberCigarettesPerDay], a.[OtherFormTobacco] = b.[OtherFormTobacco], a.[TakesAlcohol] = b.[TakesAlcohol], a.[HIVStatus] = b.[HIVStatus], a.[FamilyHistoryOfCa] = b.[FamilyHistoryOfCa], a.[PreviousCaTreatment] = b.[PreviousCaTreatment], a.[SymptomsCa] = b.[SymptomsCa], a.[CancerType] = b.[CancerType], a.[FecalOccultBloodTest] = b.[FecalOccultBloodTest], a.[TreatmentOccultBlood] = b.[TreatmentOccultBlood], a.[Colonoscopy] = b.[Colonoscopy], a.[TreatmentColonoscopy] = b.[TreatmentColonoscopy], a.[EUA] = b.[EUA], a.[TreatmentRetinoblastoma] = b.[TreatmentRetinoblastoma], a.[RetinoblastomaGene] = b.[RetinoblastomaGene], a.[TreatmentEUA] = b.[TreatmentEUA], a.[DRE] = b.[DRE], a.[TreatmentDRE] = b.[TreatmentDRE], a.[PSA] = b.[PSA], a.[TreatmentPSA] = b.[TreatmentPSA], a.[VisualExamination] = b.[VisualExamination], a.[TreatmentVE] = b.[TreatmentVE], a.[Cytology] = b.[Cytology], a.[TreatmentCytology] = b.[TreatmentCytology], a.[Imaging] = b.[Imaging], a.[TreatmentImaging] = b.[TreatmentImaging], a.[Biopsy] = b.[Biopsy], a.[TreatmentBiopsy] = b.[TreatmentBiopsy], a.[PostTreatmentComplicationCause] = b.[PostTreatmentComplicationCause], a.[OtherPostTreatmentComplication] = b.[OtherPostTreatmentComplication], a.[ReferralReason] = b.[ReferralReason], a.[ScreeningMethod] = b.[ScreeningMethod], a.[TreatmentToday] = b.[TreatmentToday], a.[ReferredOut] = b.[ReferredOut], a.[NextAppointmentDate] = b.[NextAppointmentDate], a.[ScreeningType] = b.[ScreeningType], a.[HPVScreeningResult] = b.[HPVScreeningResult], a.[TreatmentHPV] = b.[TreatmentHPV], a.[VIAScreeningResult] = b.[VIAScreeningResult], a.[VIAVILIScreeningResult] = b.[VIAVILIScreeningResult], a.[VIATreatmentOptions] = b.[VIATreatmentOptions], a.[PAPSmearScreeningResult] = b.[PAPSmearScreeningResult], a.[TreatmentPapSmear] = b.[TreatmentPapSmear], a.[ReferalOrdered] = b.[ReferalOrdered], a.[Colposcopy] = b.[Colposcopy], a.[TreatmentColposcopy] = b.[TreatmentColposcopy], a.[BiopsyCINIIandAbove] = b.[BiopsyCINIIandAbove], a.[BiopsyCINIIandBelow] = b.[BiopsyCINIIandBelow], a.[BiopsyNotAvailable] = b.[BiopsyNotAvailable], a.[CBE] = b.[CBE], a.[TreatmentCBE] = b.[TreatmentCBE], a.[Ultrasound] = b.[Ultrasound], a.[TreatmentUltraSound] = b.[TreatmentUltraSound], a.[IfTissueDiagnosis] = b.[IfTissueDiagnosis], a.[DateTissueDiagnosis] = b.[DateTissueDiagnosis], a.[ReasonNotDone] = b.[ReasonNotDone], a.[FollowUpDate] = b.[FollowUpDate], a.[Referred] = b.[Referred], a.[ReasonForReferral] = b.[ReasonForReferral], a.[RecordUUID] = b.[RecordUUID], a.[Date_Created] = b.[Date_Created], a.[Date_Last_Modified] = b.[Date_Last_Modified], a.[Created] = b.[Created];

END