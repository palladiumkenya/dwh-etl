update ODS.dbo.HTS_ClientLinkages 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_clients 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_ClientLinkages 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_ClientTracing 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_PartnerNotificationServices 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_PartnerTracings 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_TestKits 
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);
update ODS.dbo.HTS_EligibilityExtract
	set HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);

