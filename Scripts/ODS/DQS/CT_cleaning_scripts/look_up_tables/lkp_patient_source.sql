IF OBJECT_ID(N'[ODS].[DBO].[lkp_patient_source]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[DBO].[lkp_patient_source];
BEGIN
		-- create table statement
		CREATE TABLE [ODS].[DBO].[lkp_patient_source](
			source_name VARCHAR(50) NOT NULL PRIMARY KEY WITH (IGNORE_DUP_KEY = ON),
			target_name VARCHAR(50) NOT NULL,
			date_created DATE NOT NULL
		)

		-- insert to table statement
		INSERT INTO  [ODS].[DBO].[lkp_patient_source](
				   source_name,
				   target_name,
				   date_created
		)
		VALUES
		('VCT','VCT',GETDATE()),
		('OPD','OPD',GETDATE()),
		('PMTCT','MCH',GETDATE()),
		('CCC','CCC',GETDATE()),
		('TB','TB Clinic',GETDATE()),
		('IPD - Adult','IPD - Adult',GETDATE()),
		('TRANSFER-IN','OPD',GETDATE()),
		('OUT PATIENT DEPARTMENT','OPD',GETDATE()),
		('PITC','OTHER',GETDATE()),
		('Maternal and child health program','MCH',GETDATE()),
		('MCH-Chd','MCH',GETDATE()),
		('CCHC','OTHER',GETDATE()),
		('ANC/PPCT','MCH',GETDATE()),
		('IPD-Ad','IPD - Adult',GETDATE()),
		('OTHER NON CODED','OTHER',GETDATE()),
		('mch.cwc','MCH',GETDATE()),
		('NODREAM','OTHER',GETDATE()),
		('IPD-Chd','IPD - Child',GETDATE()),
		('RESEARCH','OTHER',GETDATE()),
		('Inpatient Adult','IPD - Adult',GETDATE()),
		('MCPC_C','OTHER',GETDATE()),
		('7','PITC',GETDATE()),
		('Home based HIV testing program','HBTC',GETDATE()),
		('2','VCT',GETDATE()),
		('IN PATIENT DEPARTMENT - ADULT','IPD - Adult',GETDATE()),
		('MCPC','OTHER',GETDATE()),
		('PEP','OTHER',GETDATE()),
		('5','OTHER',GETDATE()),
		('Unknown','OTHER',GETDATE()),
		('OUTREACH','OTHER',GETDATE()),
		('8','CCC',GETDATE()),
		('HOME BASED COUNSELING AND TESTING (HBCT)','HBTC',GETDATE()),
		('VMMC','VMMC',GETDATE()),
		('IN PATIENT DEPARTMENT - CHILD','IPD - Child',GETDATE()),
		('Inpatient Children','IPD - Child',GETDATE()),
		('ENDASS','OTHER',GETDATE()),
		('PREP','OTHER',GETDATE()),
		('STI','OTHER',GETDATE()),
		('3','TB Clinic',GETDATE()),
		('1','MCH',GETDATE()),
		('CHCW','OTHER',GETDATE()),
		('LABOR WARD','OTHER',GETDATE()),
		('6','VMMC',GETDATE()),
		('SELF REFFERA','OTHER',GETDATE()),
		('OPD-Adult','OPD',GETDATE()),
		('4','CWC',GETDATE()),
		('ORPHANAGE','OTHER',GETDATE()),
		('TBCARE','TB Clinic',GETDATE()),
		('SELF REFERRAL','OTHER',GETDATE())

END