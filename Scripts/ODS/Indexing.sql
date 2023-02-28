CREATE INDEX CT_AdverseEvents_index
ON CT_AdverseEvents (Patientpk, SiteCode);

go
CREATE INDEX CT_AllergiesChronicIllness_index
ON CT_AllergiesChronicIllness (Patientpk, SiteCode);
go

CREATE INDEX CT_ARTPatients_index
ON CT_ARTPatients (Patientpk, SiteCode);
go

CREATE INDEX CT_ContactListing_index
ON CT_ContactListing (Patientpk, SiteCode);
go

CREATE INDEX CT_Covid_index
ON CT_Covid (Patientpk, SiteCode);
go

CREATE INDEX CT_DefaulterTracing_index
ON CT_DefaulterTracing (Patientpk, SiteCode);
go

CREATE INDEX CT_DepressionScreening_index
ON CT_DepressionScreening (Patientpk, SiteCode);
go

CREATE INDEX CT_DrugAlcoholScreening_index
ON CT_DrugAlcoholScreening (Patientpk, SiteCode);
go

CREATE INDEX CT_EnhancedAdherenceCounselling_index
ON CT_EnhancedAdherenceCounselling (Patientpk, SiteCode);
go

CREATE INDEX CT_Ipt_index
ON CT_Ipt (Patientpk, SiteCode);
go

CREATE INDEX CT_LastPatientEncounter_index
ON CT_LastPatientEncounter (Patientpk, SiteCode);
go

CREATE INDEX CT_Otz_index
ON CT_Otz (Patientpk, SiteCode);
go

CREATE INDEX CT_Ovc_index
ON CT_Ovc (Patientpk, SiteCode);
go

CREATE INDEX CT_Patient_index
ON CT_Patient (Patientpk, SiteCode);
go

CREATE INDEX CT_PatientBaselines_index
ON CT_PatientBaselines (Patientpk, SiteCode);
go

CREATE INDEX CT_PatientLabs_index
ON CT_PatientLabs (Patientpk, SiteCode);
go

CREATE INDEX CT_PatientPharmacy_index
ON CT_PatientPharmacy (Patientpk, SiteCode);
go

CREATE INDEX CT_PatientStatus_index
ON CT_PatientStatus (Patientpk, SiteCode);
go

CREATE INDEX CT_PatientVisits_index
ON CT_PatientVisits (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_ARTOutcomes_index
ON Intermediate_ARTOutcomes (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_BaseLineViralLoads_index
ON Intermediate_BaseLineViralLoads (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastestWeightHeight_index
ON Intermediate_LastestWeightHeight (Patientpk, SiteCode);
go

CREATE INDEX IIntermediate_LastOTZVisit_index
ON Intermediate_LastOTZVisit (Patientpk, SiteCode);
go


CREATE INDEX Intermediate_LastOVCVisit_index
ON Intermediate_LastOVCVisit (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastPatientEncounter_index
ON Intermediate_LastPatientEncounter (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastPatientEncounterAsAt_index
ON Intermediate_LastPatientEncounterAsAt (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastPharmacyDispenseDate_index
ON Intermediate_LastPharmacyDispenseDate (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastVisitAsAt_index
ON Intermediate_LastVisitAsAt (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LastVisitDate_index
ON Intermediate_LastVisitDate (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_LatestViralLoads_index
ON Intermediate_LatestViralLoads (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_OrderedViralLoads_index
ON Intermediate_OrderedViralLoads (Patientpk, SiteCode);
go

CREATE INDEX Intermediate_PharmacyDispenseAsAtDate_index
ON Intermediate_PharmacyDispenseAsAtDate (Patientpk, SiteCode);
go

--------------------------------------------------------------------hts

CREATE INDEX HTS_ClientLinkages
ON HTS_ClientLinkages (SiteCode,Patientpk,HtsNumber);
go

CREATE INDEX HTS_clients
ON HTS_clients (SiteCode,Patientpk);
go

CREATE INDEX HTS_ClientTests
ON HTS_clients (SiteCode,Patientpk);
go

CREATE INDEX HTS_ClientTracing
ON HTS_ClientTracing (SiteCode,Patientpk);
go

CREATE INDEX HTS_EligibilityExtract
ON HTS_EligibilityExtract (SiteCode,Patientpk);
go

CREATE INDEX HTS_PartnerNotificationServices
ON HTS_PartnerNotificationServices (SiteCode,Patientpk);
go
CREATE INDEX HTS_PartnerTracings
ON HTS_PartnerNotificationServices (SiteCode,Patientpk);
go

CREATE INDEX HTS_TestKits
ON HTS_TestKits (SiteCode,Patientpk);
go