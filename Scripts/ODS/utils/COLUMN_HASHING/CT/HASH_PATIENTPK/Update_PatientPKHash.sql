update ODS.dbo.CT_PatientBaselines 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_AllergiesChronicIllness 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_ARTPatients 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_Patient 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_ContactListing 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_EnhancedAdherenceCounselling 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_Otz 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_Ovc 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_DefaulterTracing 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.CT_PatientStatus 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update ODS.dbo.CT_AdverseEvents 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update [ODS].[dbo].[CT_ContactListing] 
	set ContactPatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(ContactPatientPK  as nvarchar(36))), 2);

update ODS.dbo.CT_DepressionScreening 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	
update ODS.dbo.CT_DrugAlcoholScreening 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_GbvScreening 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_Covid 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_PatientVisits 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

	update ODS.dbo.CT_Ipt 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update ODS.dbo.CT_PatientLabs 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2); 

update ODS.dbo.CT_PatientPharmacy 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);










