update ODS.dbo.CT_PatientBaselines 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_AllergiesChronicIllness 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_ARTPatients 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_Patient 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_PatientVisits 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_DrugAlcoholScreening 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_Ipt 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_ContactListing 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_EnhancedAdherenceCounselling 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_Otz 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_DepressionScreening 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_GbvScreening 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_Ovc 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_DefaulterTracing 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_PatientStatus 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_PatientPharmacy 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_Covid 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_AdverseEvents 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
update ODS.dbo.CT_PatientLabs 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);
