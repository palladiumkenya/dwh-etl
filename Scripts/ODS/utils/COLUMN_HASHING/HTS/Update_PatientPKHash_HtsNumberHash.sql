	update ODS.dbo.HTS_clients 
		set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
			HTSNumberHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(HTSNumber  as nvarchar(36))), 2);


	update cl
		set cl.PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_ClientLinkages cl
		inner join ODS.dbo.HTS_clients c
		on cl.SiteCode = c.sitecode and cl.PatientPk =c.PatientPk;

	update ct
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_ClientTests    ct
		JOIN ODS.dbo.HTS_clients  c
		on ct.SiteCode = c.SiteCode and ct.PatientPK = c.PatientPK;

	update ct
	set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_ClientTracing   ct
	JOIN ODS.dbo.HTS_clients  c
	on ct.SiteCode = c.SiteCode and ct.PatientPK = c.PatientPK;

	update n
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_PartnerNotificationServices     n
		JOIN ODS.dbo.HTS_clients  c
		on n.SiteCode = c.SiteCode and n.PatientPK = c.PatientPK;

	update PT
	set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_PartnerTracings     PT
	JOIN ODS.dbo.HTS_clients  c
	on PT.SiteCode = c.SiteCode and PT.PatientPK = c.PatientPK;

	update PT
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_PositivePatients   PT
		JOIN ODS.dbo.HTS_clients  c
		on PT.SiteCode = c.SiteCode and PT.PatientPK = c.PatientPK;

	update tk
		set PatientPKHash = c.PatientPKHash
	from  ODS.dbo.HTS_TestKits    tk
	JOIN ODS.dbo.HTS_clients  c
	on tk.SiteCode = c.SiteCode and tk.PatientPK = c.PatientPK;

	update Elg
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_EligibilityExtract      Elg
		JOIN ODS.dbo.HTS_clients  c
		on Elg.SiteCode = c.SiteCode and Elg.PatientPK = c.PatientPK;

	update PPNew
		set PatientPKHash = c.PatientPKHash
	from ODS.dbo.HTS_PositivePatients_new      PPNew
		JOIN ODS.dbo.HTS_clients  c
		on PPNew.SiteCode = c.SiteCode and PPNew.PatientPK = c.PatientPK;
