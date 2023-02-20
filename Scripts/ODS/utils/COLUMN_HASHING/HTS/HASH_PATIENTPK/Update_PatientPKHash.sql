update ODS.dbo.HTS_ClientLinkages 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_clients 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_ClientTests 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_ClientTracing 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_PartnerNotificationServices 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_PartnerTracings 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_PositivePatients 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_TestKits 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_EligibilityExtract 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
update ODS.dbo.HTS_PositivePatients_new 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
