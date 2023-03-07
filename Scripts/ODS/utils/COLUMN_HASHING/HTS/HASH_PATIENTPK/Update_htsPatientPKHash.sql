update ODS.dbo.HTS_clients 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update ODS.dbo.HTS_ClientLinkages 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

--update ODS.dbo.HTS_ClientTests 
--	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

		update ct
set PatientPKHash = c.PatientPKHash
from ODS.dbo.HTS_ClientTests    ct
JOIN ODS.dbo.HTS_clients  c
on ct.SiteCode = c.SiteCode and ct.PatientPK = c.PatientPK;


update ODS.dbo.HTS_ClientTracing 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

--update ODS.dbo.HTS_PartnerNotificationServices 
--	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

		update n
set PatientPKHash = c.PatientPKHash
from ODS.dbo.HTS_PartnerNotificationServices     n
JOIN ODS.dbo.HTS_clients  c
on n.SiteCode = c.SiteCode and n.PatientPK = c.PatientPK;

update ODS.dbo.HTS_PartnerTracings 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

update ODS.dbo.HTS_PositivePatients 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

--update ODS.dbo.HTS_TestKits 
--	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

			update tk
set PatientPKHash = c.PatientPKHash
from  ODS.dbo.HTS_TestKits    tk
JOIN ODS.dbo.HTS_clients  c
on tk.SiteCode = c.SiteCode and tk.PatientPK = c.PatientPK;


--update ODS.dbo.HTS_EligibilityExtract 
--	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);

		update Elg
set PatientPKHash = c.PatientPKHash
from ODS.dbo.HTS_EligibilityExtract      Elg
JOIN ODS.dbo.HTS_clients  c
on Elg.SiteCode = c.SiteCode and Elg.PatientPK = c.PatientPK;

update ODS.dbo.HTS_PositivePatients_new 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2);
