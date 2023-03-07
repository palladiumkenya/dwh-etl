update ODS.dbo.CT_Patient 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

update ODS.dbo.CT_PatientBaselines 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

update ODS.dbo.CT_AllergiesChronicIllness 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

update ODS.dbo.CT_ARTPatients 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);


--update ODS.dbo.CT_PatientVisits 
--	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

	update v
	set PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientVisits  v
	JOIN ODS.dbo.CT_Patient p
	on v.SiteCode = p.SiteCode and v.PatientPK = p.PatientPK

update ODS.dbo.CT_DrugAlcoholScreening 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

--update ODS.dbo.CT_Ipt 
--	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

		update Ipt
	set PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_Ipt  Ipt
	JOIN ODS.dbo.CT_Patient p
	on Ipt.SiteCode = p.SiteCode and Ipt.PatientPK = p.PatientPK

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

--update ODS.dbo.CT_PatientPharmacy 
--	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

		update Phar 
	set PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientPharmacy   Phar
	JOIN ODS.dbo.CT_Patient p
	on Phar .SiteCode = p.SiteCode and Phar .PatientPK = p.PatientPK

update ODS.dbo.CT_Covid 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

update ODS.dbo.CT_AdverseEvents 
	set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

--update ODS.dbo.CT_PatientLabs 
	--set PatientIDHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(PatientID  as nvarchar(36))), 2);

		update Labs 
	set PatientIDHash = p.PatientIDHash
	from ODS.dbo.CT_PatientLabs   Labs 
	JOIN ODS.dbo.CT_Patient p
	on Labs .SiteCode = p.SiteCode and Labs .PatientPK = p.PatientPK
