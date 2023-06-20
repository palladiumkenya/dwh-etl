IF OBJECT_ID(N'[NDWH].[dbo].[FactViralLoads]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactViralLoads];
BEGIN
	with MFL_partner_agency_combination as (
		select 
			distinct MFL_Code,
			SDP,
			[SDP_Agency]  as Agency
		from ODS.dbo.All_EMRSites 
	),
	 eligible_for_VL as (
		 select 
	 		distinct PatientID,
			PatientPK,
			SiteCode,
	 		case 
		 		when datediff(month,StartARTDate, getdate()) >=3 then 1
				when DATEDIFF(MONTH, StartARTDate, getdate()) <3 then 0
			end as EligibleVL
		from ODS.dbo.CT_ARTPatients
	 ),
	 last_12M_VL as (
		select 
	 		distinct PatientID,
			 SiteCode,
			 PatientPK,
			 OrderedbyDate,
			 Replace(TestResult ,',','') as TestResult	 
		from ODS.dbo.Intermediate_LatestViralLoads
		where datediff(month, OrderedbyDate, getdate()) <= 12
	 ),
	 last_12M_VL_indicators as (
		select 
			PatientPK,
			SiteCode,
			TestResult as Last12MonthVLResults,
			case 
				when TestResult is not null then 1
				else 0 	
			end as	Last12MonthVL,
			case 
				when TestResult in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') then 1 
			end as Last12MVLSup,
			OrderedbyDate as Last12MVLDate,
			case 
				when ISNUMERIC(TestResult) = 1 then 
					case 
						when CAST(replace(TestResult,',','') AS float) > 1000.00 then '>1000' 
						when cast(replace(TestResult,',','') as float) between 400.00 and 999.00  then '400-900'
						when CAST(replace(TestResult,',','') as float) between 51.00 and 399.00 then '51-399'
						when CAST(replace(TestResult,',','') as float) < 50 then '<50'
						end 
				else 
					case 
						when TestResult  in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') then 'Undetectable'
					end  
			end as	Last12MVLResult
		 from last_12M_VL
	 ),
	 patient_viral_load_intervals as (
		select
			distinct PatientPK,
			SiteCode,
	 		[_6MonthVL],
			[_6MonthVLDate],
			[_12MonthVL],
			[_12MonthVLDate],
			[_18MonthVL],
			[_18MonthVLDate],
			[_24MonthVL],
			[_24MonthVLDate],
			[_6MonthVLSup],
			[_12MonthVLSup],
			[_18MonthVLSup],
			[_24MonthVLSup]
		from ODS.dbo.Intermediate_ViralLoadsIntervals
	 ),
	 first_vl as (
		select 
			PatientPK,
			SiteCode,
	 		replace(TestResult, ',', '') as FirstVL,
			OrderedbyDate as FirstVLDate 
		from ODS.dbo.Intermediate_BaseLineViralLoads	
	 ),
	last_vl as (
		select 
			PatientPK,
			SiteCode,
	 		replace(TestResult, ',', '') as LastVL,
			OrderedbyDate as LastVLDate 	
		from ODS.dbo.Intermediate_LatestViralLoads
	),
	time_to_first_vl as (
		select
		distinct baseline.PatientPK,
		baseline.SiteCode,
		case 
			when baseline.OrderedbyDate is not null and StartARTDate is not null then 
				case 
					when OrderedbyDate >= art_patients.StartARTDate then datediff(day, art_patients.StartARTDate, baseline.OrderedbyDate)
				end
		end as TimetoFirstVL
	from ODS.dbo.Intermediate_BaseLineViralLoads as baseline
	left join ODS.dbo.CT_ARTPatients as art_patients on art_patients.PatientPK = baseline.PatientPK
		and art_patients.SiteCode = baseline.SiteCode
	),
	time_to_first_vl_group as (
		select
			PatientPK,
			SiteCode,
			case 
				when [TimetoFirstVL] < 0 then 'Before ARTStart'
				when [TimetoFirstVL] between 0 and 90 then '3 Months'
				when [TimetoFirstVL] between 91 and 180 then '6 Months'
				when [TimetoFirstVL] between 181 and 365 then '12 Months'
				when [TimetoFirstVL] > 365 then '> 12 Months'
			end as TimeToFirstVLGrp
		from time_to_first_vl
	),
	latest_VL_1 as (
		select 
			PatientPK,
			SiteCode,
			TestResult as LatestVL1,
			OrderedbyDate as LatestVLDate1,
			rank
		from ODS.dbo.Intermediate_OrderedViralLoads
		where rank = 1
	),
	latest_VL_2 as (
		select 
			PatientPK,
			SiteCode,
			TestResult as LatestVL2,
			OrderedbyDate as LatestVLDate2,
			rank
		from ODS.dbo.Intermediate_OrderedViralLoads
		where rank = 2
	),
	latest_VL_3 as (
		select 
			PatientPK,
			SiteCode,
			TestResult as LatestVL3,
			OrderedbyDate as LatestVLDate3,
			rank
		from ODS.dbo.Intermediate_OrderedViralLoads
		where rank = 3
	),
	combined_viral_load_dataset as (
		select
			patient.PatientPK,
			patient.PatientPKHash,
			patient.SiteCode,
			eligible_for_VL.EligibleVL,
			last_12M_VL_indicators.Last12MonthVLResults,
			last_12M_VL_indicators.Last12MonthVL,
			last_12M_VL_indicators.Last12MVLResult,
			last_12M_VL_indicators.Last12MVLSup,
			last_12M_VL_indicators.Last12MVLDate,
			patient_viral_load_intervals.[_6MonthVLDate],
			patient_viral_load_intervals.[_6MonthVL],
			patient_viral_load_intervals.[_12MonthVLDate],
			patient_viral_load_intervals.[_12MonthVL],
			patient_viral_load_intervals.[_18MonthVLDate],
			patient_viral_load_intervals.[_18MonthVL],
			patient_viral_load_intervals.[_24MonthVLDate],
			patient_viral_load_intervals.[_24MonthVL],
			patient_viral_load_intervals.[_6MonthVLSup],
			patient_viral_load_intervals.[_12MonthVLSup],
			patient_viral_load_intervals.[_18MonthVLSup],
			patient_viral_load_intervals.[_24MonthVLSup],
			first_vl.FirstVL,
			first_vl.FirstVLDate,
			last_vl.LastVL,
			last_vl.LastVLDate,
			time_to_first_vl.TimetoFirstVL,
			time_to_first_vl_group.TimeToFirstVLGrp,
			latest_VL_1.LatestVLDate1,
			latest_VL_1.LatestVL1,
			latest_VL_2.LatestVLDate2,
			latest_VL_2.LatestVL2,
			latest_VL_3.LatestVLDate3,
			latest_VL_3.LatestVL3,
			Case WHEN ISNUMERIC(last_12M_VL_indicators.Last12MonthVLResults) = 1 
				THEN CASE WHEN CAST(Replace(last_12M_VL_indicators.Last12MonthVLResults,',','')AS FLOAT) > 1000.00 THEN 1 ELSE 0 END
			END as HighViremia,
			Case WHEN ISNUMERIC(last_12M_VL_indicators.Last12MonthVLResults) = 1 
				THEN CASE WHEN CAST(Replace(last_12M_VL_indicators.Last12MonthVLResults,',','')AS FLOAT) between 400.00 and 1000.00 THEN 1 ELSE 0 END
			END as LowViremia,
			datediff(yy, patient.DOB, last_encounter.LastEncounterDate) as AgeLastVisit
		from ODS.dbo.CT_Patient as patient
		left join eligible_for_VL on eligible_for_VL.PatientPK = patient.PatientPK
			and eligible_for_VL.SiteCode = patient.SiteCode
		left join last_12M_VL_indicators on last_12M_VL_indicators.PatientPK = patient.PatientPK
			and last_12M_VL_indicators.SiteCode = patient.SiteCode
		left join patient_viral_load_intervals on patient_viral_load_intervals.PatientPK = patient.PatientPK
			and patient_viral_load_intervals.SiteCode = patient.SiteCode
		left join first_vl on first_vl.PatientPK = patient.PatientPK
			and first_vl.SiteCode = patient.SiteCode
		left join last_vl on last_vl.PatientPK = patient.PatientPK
			and last_vl.SiteCode = patient.SiteCode
		left join time_to_first_vl_group on time_to_first_vl_group.PatientPK = patient.PatientPK
			and time_to_first_vl_group.SiteCode = patient.SiteCode	
		left join time_to_first_vl on time_to_first_vl.PatientPK = patient.PatientPK
			and time_to_first_vl.SiteCode = patient.SiteCode
		left join latest_VL_1 on latest_VL_1.PatientPK = patient.PatientPK
			and latest_VL_1.SiteCode = patient.SiteCode	
		left join latest_VL_2 on latest_VL_2.PatientPK = patient.PatientPK
			and latest_VL_2.SiteCode = patient.SiteCode	
		left join latest_VL_3 on latest_VL_3.PatientPK = patient.PatientPK
			and latest_VL_3.SiteCode = patient.SiteCode	
		left join ODS.dbo.Intermediate_LastPatientEncounter as last_encounter on patient.PatientPK = last_encounter.PatientPK
			and last_encounter.SiteCode = patient.SiteCode
	)
	select
		Factkey = IDENTITY(INT, 1, 1),
		patient.PatientKey,
		facility.FacilityKey,
		partner.PartnerKey,
		agency.AgencyKey,
		age_group.AgeGroupKey,
		last_12MVL_date.DateKey as Last12MVLDateKey,
		_6_monthVL_date.DateKey as [6MonthVLDateKey],
		_12_monthVL_date.DateKey as [12MonthVLDateKey],
		_18_monthVL_date.DateKey as [18MonthVLDateKey],
		_24_monthVL_date.Datekey as [24MonthVLDateKey],
		first_VL_date.DateKey as FirstVLDateKey,
		last_VL_date.DateKey as LastVLDateKey,
		lastest_VL_date1.DateKey as LatestVLDate1Key,
		lastest_VL_date2.DateKey as LatestVLDate2Key,
		lastest_VL_date3.DateKey as LatestVLDate3Key,
		combined_viral_load_dataset.LatestVL1,
		combined_viral_load_dataset.LatestVL2,
		combined_viral_load_dataset.LatestVL3,
		combined_viral_load_dataset.EligibleVL,
		combined_viral_load_dataset.Last12MonthVLResults,
		combined_viral_load_dataset.Last12MonthVL,
		combined_viral_load_dataset.Last12MVLResult,
		combined_viral_load_dataset.Last12MVLSup,
		combined_viral_load_dataset.[_6MonthVL],
		combined_viral_load_dataset.[_12MonthVL],
		combined_viral_load_dataset.[_18MonthVL],
		combined_viral_load_dataset.[_24MonthVL],
		combined_viral_load_dataset.[_6MonthVLSup] as [6MonthVLSup],
		combined_viral_load_dataset.[_12MonthVLSup] as [12MonthVLSup],
		combined_viral_load_dataset.[_18MonthVLSup] as [18MonthVLSup],
		combined_viral_load_dataset.[_24MonthVLSup] as [24MonthVLSup],	
		combined_viral_load_dataset.FirstVL,
		combined_viral_load_dataset.LastVL,
		combined_viral_load_dataset.TimetoFirstVL,
		combined_viral_load_dataset.TimeToFirstVLGrp,
		combined_viral_load_dataset.HighViremia,
		combined_viral_load_dataset.LowViremia
	into [NDWH].[dbo].[FactViralLoads]
	from combined_viral_load_dataset
	left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = combined_viral_load_dataset.PatientPKHash
		and patient.SiteCode = combined_viral_load_dataset.SiteCode
	left join NDWH.dbo.DimFacility as facility on facility.MFLCode = combined_viral_load_dataset.SiteCode
	left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = combined_viral_load_dataset.SiteCode
	left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
	left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
	left join NDWH.dbo.DimAgeGroup as age_group on age_group.Age = combined_viral_load_dataset.AgeLastVisit
	left join NDWH.dbo.DimDate as last_12MVL_date on last_12MVL_date.Date = combined_viral_load_dataset.Last12MVLDate
	left join NDWH.dbo.DimDate as _6_monthVL_date on _6_monthVL_date.Date = combined_viral_load_dataset.[_6MonthVLDate]
	left join NDWH.dbo.DimDate as _12_monthVL_date on _12_monthVL_date.Date = combined_viral_load_dataset.[_12MonthVLDate]
	left join NDWH.dbo.DimDate as _18_monthVL_date on _18_monthVL_date.Date = combined_viral_load_dataset.[_18MonthVLDate]
	left join NDWH.dbo.DimDate as _24_monthVL_date on _24_monthVL_date.Date = combined_viral_load_dataset.[_24MonthVLDate]
	left join NDWH.dbo.DimDate as first_VL_date on first_VL_date.Date = combined_viral_load_dataset.FirstVLDate
	left join NDWH.dbo.DimDate as last_VL_date on last_VL_date.Date = combined_viral_load_dataset.LastVLDate
	left join NDWH.dbo.DimDate as lastest_VL_date1 on lastest_VL_date1.Date = combined_viral_load_dataset.LatestVLDate1
	left join NDWH.dbo.DimDate as lastest_VL_date2 on lastest_VL_date2.Date = combined_viral_load_dataset.LatestVLDate2
	left join NDWH.dbo.DimDate as lastest_VL_date3 on lastest_VL_date3.Date = combined_viral_load_dataset.LatestVLDate3;

	alter table [NDWH].[dbo].[FactViralLoads] add primary key(FactKey);
END