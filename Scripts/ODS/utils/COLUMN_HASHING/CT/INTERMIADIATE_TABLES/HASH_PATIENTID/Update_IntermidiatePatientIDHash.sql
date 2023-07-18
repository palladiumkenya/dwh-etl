
update ODS.dbo.Intermediate_ARTOutcomes 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_BaseLineViralLoads 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastestWeightHeight 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastOTZVisit 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastOVCVisit 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastPatientEncounter 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastPatientEncounterAsAt 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastPharmacyDispenseDate 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastVisitAsAt 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LastVisitDate 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_LatestViralLoads 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_OrderedViralLoads 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_PharmacyDispenseAsAtDate 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_PregnancyAsATInitiation 
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);
update ODS.dbo.Intermediate_ViralLoadsIntervals
	set PatientIDHash = convert(nvarchar(100), hashbytes('SHA2_256', cast(PatientID  as nvarchar(100))), 2);