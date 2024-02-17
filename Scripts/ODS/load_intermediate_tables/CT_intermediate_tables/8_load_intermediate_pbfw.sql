IF OBJECT_ID(N'[ODS].[dbo].[Intermediate_Pbfw]', N'U') IS NOT NULL 
	DROP TABLE [ODS].[dbo].[Intermediate_Pbfw];		
with visits_source as (
select 
    distinct obs.SiteCode,
        obs.PatientPK,
        obs.PatientPKHash,
        Breastfeeding,
        Pregnant,
		patient.Gender,
		patient.DOB,
		art_patient.StartARTDate,
		patient.DateConfirmedHIVPositive,
		last_visit.LastvisitDate
from ODS.dbo.intermediate_LatestObs as obs
left join ODS.dbo.CT_ARTPatients as art_patient on art_patient.PatientPK = obs.PatientPK
    and art_patient.SiteCode = obs.SiteCode
left join Ods.Dbo.Ct_patient as patient on patient.PatientPk = obs.PatientPK
	and patient.SiteCode = obs.SiteCode
left join ODS.dbo.Intermediate_LastVisitDate as last_visit on last_visit.PatientPK = obs.PatientPK
	and last_visit.SiteCode = obs.SiteCode
where 
    Pregnant='Yes' OR breastfeeding='Yes'
    and datediff(Year, art_patient.DOB, art_patient.LastVisit) > 10
    /*Check if period of gestation is within  9 months +6 for BF = 15 */
    and  DATEDIFF(DAY, DATEADD(DAY, -(CAST(FLOOR(CONVERT(FLOAT, GestationAge)) * 7 AS INT)), CAST(LMP AS DATE)), EOMONTH(DATEADD(mm,-1,GETDATE()))) <= 450
),
visits_odering_asc as (
	select 
		Row_number()
			OVER (
			Partition BY visit.Patientpk, visit.Sitecode
			ORDER BY Visitdate asc ) as num,
		visit.PatientPK,
		visit.SiteCode,
		VisitDate
	from ODS.dbo.CT_PatientVisits as visit
	left join ODS.dbo.CT_ARTPatients as art_patient on art_patient.PatientPK = visit.PatientPK
    and art_patient.SiteCode = visit.SiteCode
	where
	    Pregnant='Yes' OR breastfeeding='Yes'
    		and datediff(Year, art_patient.DOB, art_patient.LastVisit) > 1
),
first_anc_from_visits as (
	select 
		*
	from visits_odering_asc 
	where num = 1
),
anc_source as (
	select Row_number()
			OVER (
			Partition BY Patientpk, Sitecode
			ORDER BY Visitdate desc ) as num,
		Patientpk,
		Patientpkhash,
		Sitecode,
		Visitdate,
		HIVStatusBeforeANC
	from   Ods.Dbo.Mnch_ancvisits
	where Hivstatusbeforeanc = 'KP'
			OR Hivtestfinalresult = 'Positive'
),
pnc_source AS (
	select Row_number()
			over (
			partition by Patientpk, Sitecode
			order by Visitdate desc ) as num,
		Patientpk,
		Patientpkhash,
		Sitecode,
		Visitdate
	from   ods.dbo.Mnch_pncvisits
	where Priorhivstatus = 'Positive'
			or Hivtestfinalresult = 'Positive'
			and Babyfeeding in ( 'Breastfed exclusively',
								'Exclusive breastfeeding',
								'mixed feeding' )
),
mat_source as (
	select Row_number()
		over (
		partition by Patientpk, Sitecode
		order by Visitdate desc ) as num,
	Patientpk,
	Patientpkhash,
	Sitecode,
	Visitdate
	from  Ods.Dbo.Mnch_matvisits
	where Hivtestfinalresult = 'Positive'
		or Onartanc = 'Yes'
		and Initiatedbf = 'Yes'
),
latest_anc as (
	select 
		*
	from anc_source
	where num = 1
),
latest_pnc as (
	select 
		*
	from pnc_source
	where num = 1
),
latest_mat as (
	select 
		*
	from mat_source 
	where num = 1
),
mnch_art_ordering as ( 
	select row_number()
			over (
			partition by Patientpk, Sitecode
			order by StartARTDate asc) as num,
			SiteCode,
			PatientPK,
			StartARTDate
	from ODS.dbo.MNCH_Arts
),
earliest_mnch_start_art as (
	select 
		*
	from mnch_art_ordering
	where num = 1
),
mnch_enrollment_ordering as (
		select row_number()
			over (
			partition by Patientpk, Sitecode
			order by EnrollmentDateAtMnch desc) as num,
			SiteCode,
			PatientPK,
			HIVStatusBeforeANC		
		from ODS.dbo.MNCH_Enrolments
),
latest_mnch_enrollment as (
	select 
		*
	from mnch_enrollment_ordering
	where num = 1
),
joined_data as (
select 
	coalesce(visits_source.SiteCode, latest_anc.SiteCode, latest_pnc.SiteCode, latest_mat.SiteCode) as SiteCode,
	coalesce(visits_source.PatientPKHash, latest_anc.PatientPKHash, latest_pnc.PatientPKhash, latest_mat.PatientPKHash) as PatientPKHash,
    coalesce(visits_source.PatientPK, latest_anc.PatientPK, latest_pnc.PatientPK, latest_mat.PatientPK) as PatientPK,
    visits_source.Breastfeeding,
	visits_source.Pregnant,
	coalesce(visits_source.StartARTDate, earliest_mnch_start_art.StartARTDate) as StartARTDate,
	visits_source.DateConfirmedHIVPositive,
	coalesce(visits_source.LastvisitDate, latest_anc.VisitDate, latest_pnc.VisitDate, latest_mat.VisitDate) as LastvisitDate,
	coalesce(latest_mnch_enrollment.HIVStatusBeforeANC, latest_anc.HIVStatusBeforeANC) as HIVStatusBeforeANC,
	visits_source.Gender,
	visits_source.DOB,
	case when latest_anc.PatientPK is not null then 1 else 0 end as IsAncSource,
	latest_anc.HIVStatusBeforeANC as HIVStatusBeforeANCSource,
	first_anc_from_visits.VisitDate as ANCdate1
from visits_source
full join latest_anc on visits_source .Patientpk = latest_anc.Patientpk
	and visits_source .Sitecode = latest_anc.Sitecode
full join latest_pnc on latest_pnc.Patientpk = visits_source.Patientpk
	and latest_pnc.Sitecode = visits_source.Sitecode
full join latest_mat on latest_mat.Patientpk = visits_source.Patientpk
	and visits_source.Sitecode = latest_mat.Sitecode
left join earliest_mnch_start_art on earliest_mnch_start_art.Patientpk = visits_source.Patientpk
	and visits_source.Sitecode = earliest_mnch_start_art.Sitecode
left join latest_mnch_enrollment on latest_mnch_enrollment.PatientPK = visits_source.PatientPK 
	and latest_mnch_enrollment.SiteCode = visits_source.SiteCode
left join first_anc_from_visits on first_anc_from_visits.PatientPK = visits_source.PatientPK
	and first_anc_from_visits.SiteCode = visits_source.SiteCode
)
select 
	SiteCode,
	PatientPKHash,
    PatientPK,
	Breastfeeding,
	Pregnant,
	StartARTDate,
	DateConfirmedHIVPositive,
	LastvisitDate,
	HIVStatusBeforeANC,
	IsAncSource,
	Gender,
	DOB,
	case 
		when DateConfirmedHIVPositive < LastvisitDate then 'Known Positive'
		when DateConfirmedHIVPositive = LastvisitDate then 'New Positive'
		when HIVStatusBeforeANC in ('Positive', 'KP') then 'Known Positive'
		when IsAncSource = 1 and HIVStatusBeforeANCSource not in ('KP') then 'New Positive'
	else 'Missing'
	end as PBFWCategory,
	ANCdate1 as GreenCardAncDate1
into ODS.dbo.Intermediate_Pbfw
from joined_data