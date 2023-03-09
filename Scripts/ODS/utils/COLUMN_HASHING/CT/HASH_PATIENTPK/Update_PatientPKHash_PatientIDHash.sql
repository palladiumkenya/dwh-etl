update ODS.dbo.CT_Patient 
	set PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientPk  as nvarchar(36))), 2),
		PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);


	update PB
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientBaselines  PB
		JOIN ODS.dbo.CT_Patient p
	on PB.SiteCode = p.SiteCode and PB.PatientPK = p.PatientPK;

	update AC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_AllergiesChronicIllness  AC
		JOIN ODS.dbo.CT_Patient p
	on AC.SiteCode = p.SiteCode and AC.PatientPK = p.PatientPK;


	update ARTP
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_ARTPatients   ARTP
		JOIN ODS.dbo.CT_Patient p
	on ARTP.SiteCode = p.SiteCode and ARTP.PatientPK = p.PatientPK;


	update CL
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_ContactListing    CL
		JOIN ODS.dbo.CT_Patient p
	on CL.SiteCode = p.SiteCode and CL.PatientPK = p.PatientPK;

	update EAC
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_EnhancedAdherenceCounselling     EAC
		JOIN ODS.dbo.CT_Patient p
	on EAC.SiteCode = p.SiteCode and EAC.PatientPK = p.PatientPK;


		update Otz 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Otz     Otz 
		JOIN ODS.dbo.CT_Patient p
	on Otz .SiteCode = p.SiteCode and Otz.PatientPK = p.PatientPK;

	update Ovc 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ovc     Ovc 
		JOIN ODS.dbo.CT_Patient p
	on Ovc .SiteCode = p.SiteCode and Ovc.PatientPK = p.PatientPK;

	update DT 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DefaulterTracing      DT 
		JOIN ODS.dbo.CT_Patient p
	on DT .SiteCode = p.SiteCode and DT.PatientPK = p.PatientPK;

	update PS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_PatientStatus   PS 
		JOIN ODS.dbo.CT_Patient p
	on PS .SiteCode = p.SiteCode and PS.PatientPK = p.PatientPK;

	update AE 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_AdverseEvents   AE 
		JOIN ODS.dbo.CT_Patient p
	on AE .SiteCode = p.SiteCode and AE.PatientPK = p.PatientPK;

	update DS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DepressionScreening    DS 
		JOIN ODS.dbo.CT_Patient p
	on DS .SiteCode = p.SiteCode and DS.PatientPK = p.PatientPK;


	update DAS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_DrugAlcoholScreening   DAS 
		JOIN ODS.dbo.CT_Patient p
	on DAS.SiteCode = p.SiteCode and DAS.PatientPK = p.PatientPK;

	update GbvS 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_GbvScreening  GbvS
		JOIN ODS.dbo.CT_Patient p
	on GbvS.SiteCode = p.SiteCode and GbvS.PatientPK = p.PatientPK;

	update C 
		set PatientPKHash = p.PatientPKHash,
			PatientIDHash = p.PatientIDHash
	from  ODS.dbo.CT_Covid   C
		JOIN ODS.dbo.CT_Patient p
	on C.SiteCode = p.SiteCode and C.PatientPK = p.PatientPK;

	update v
		set PatientPKHash = p.PatientPKHash
	from ODS.dbo.CT_PatientVisits  v
	JOIN ODS.dbo.CT_Patient p
		on v.SiteCode = p.SiteCode and v.PatientPK = p.PatientPK;

	update Ipt
		set PatientPKHash = p.PatientPKHash
	from ODS.dbo.CT_Ipt  Ipt
	JOIN ODS.dbo.CT_Patient p
		on Ipt.SiteCode = p.SiteCode and Ipt.PatientPK = p.PatientPK;

	update Labs 
		set PatientPKHash = p.PatientPKHash
	from ODS.dbo.CT_PatientLabs   Labs 
		JOIN ODS.dbo.CT_Patient p
		on Labs .SiteCode = p.SiteCode and Labs .PatientPK = p.PatientPK;

	update Phar 
		set PatientPKHash = p.PatientPKHash
	from ODS.dbo.CT_PatientPharmacy   Phar
	JOIN ODS.dbo.CT_Patient p
	on Phar .SiteCode = p.SiteCode and Phar .PatientPK = p.PatientPK;









