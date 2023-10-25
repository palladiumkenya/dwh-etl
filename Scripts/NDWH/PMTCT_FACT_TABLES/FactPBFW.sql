
IF OBJECT_ID(N'[NDWH].[dbo].[FactPBFW]', N'U') IS NOT NULL 
DROP TABLE [NDWH].[dbo].[FactPBFW];
BEGIN
with MFL_partner_agency_combination as (
  select 
    distinct MFL_Code, 
    SDP, 
    SDP_Agency as Agency 
  from 
    ODS.dbo.All_EMRSites
), 
PBFW_Patient as (
  select 
    row_number() OVER (
      PARTITION BY visits.SiteCode, 
      visits.Patientpkhash 
      ORDER BY 
        visits.VisitDate asc
    ) AS NUM, 
    visits.PatientPKHash, 
    visits.PatientPK, 
    visits.SiteCode, 
    patient.DOB, 
    patient.Gender, 
    Pregnant, 
    Breastfeeding, 
    visits.VisitDate, 
    DateConfirmedHIVPositive, 
    StartARTDate, 
    TestResult, 
    case when DATEDIFF(
      month, 
      StartARTDate, 
      getdate()
    ) >= 3 then 1 when DATEDIFF(
      MONTH, 
      StartARTDate, 
      getdate()
    ) < 3 then 0 end as EligibleVL, 
    case when isnumeric([TestResult]) = 1 then case when cast(
      replace([TestResult], ',', '') as float
    ) < 200.00 then 1 else 0 end else case when [TestResult] in (
      'undetectable', 'NOT DETECTED', '0 copies/ml', 
      'LDL', 'Less than Low Detectable Level'
    ) then 1 else 0 end end as Suppressed, 
    OrderedbyDate as ValidVLDate, 
    case when ISNUMERIC(TestResult) = 1 then case when cast(
      replace(TestResult, ',', '') AS float
    ) >= 200.00 then '>200' when cast(
      replace(TestResult, ',', '') as float
    ) between 200.00 
    and 999.00 then '200-999' when cast(
      replace(TestResult, ',', '') as float
    ) between 51.00 
    and 199.00 then '51-199' when cast(
      replace(TestResult, ',', '') as float
    ) < 50 then '<50' end else case when TestResult in (
      'undetectable', 'NOT DETECTED', '0 copies/ml', 
      'LDL', 'Less than Low Detectable Level'
    ) then 'Undetectable' end end as ValidVLResultCategory 
  from 
    ODS.dbo.CT_Patient as patient 
    inner join ODS.dbo.CT_PatientVisits as visits on visits.PatientPKHash = patient.PatientPKHash 
    and visits.SiteCode = patient.SiteCode 
    left join ODS.dbo.CT_ARTPatients art on patient.PatientPKHash = art.PatientPKHash 
    and patient.SiteCode = art.SiteCode 
    left join ODS.dbo.Intermediate_LatestViralLoads vl on patient.PatientPKHash = vl.PatientPKHash 
    and patient.SiteCode = vl.SiteCode 
  where 
    visits.Pregnant = 'Yes' 
    or Breastfeeding = 'Yes' 
    and visits.LMP > '1900-01-01' 
    and visits.SiteCode > 0 
    and DATEDIFF(
      YEAR, 
      patient.DOB, 
      GETDATE()
    )> 10
), 
ANCDate2 as (
  Select 
    PBFW_Patient.PatientPKHash, 
    PBFW_Patient.SiteCode, 
    PBFW_Patient.VisitDate as ANCDate2 
  from 
    PBFW_Patient 
  where 
    NUM = 2
), 
ANCDate3 as (
  Select 
    PBFW_Patient.PatientPKHash, 
    PBFW_Patient.SiteCode, 
    PBFW_Patient.VisitDate as ANCDate3 
  from 
    PBFW_Patient 
  where 
    NUM = 3
), 
ANCDate4 as (
  Select 
    PBFW_Patient.PatientPKHash, 
    PBFW_Patient.SiteCode, 
    PBFW_Patient.VisitDate as ANCDate4 
  from 
    PBFW_Patient 
  where 
    NUM = 4
), 
TestedatANC AS (
  Select 
   row_number() OVER (
      PARTITION BY Pat.SiteCode, 
      Pat.Patientpkhash 
      ORDER BY 
        tests.testdate asc
    ) AS NUM,
    pat.PatientPKHash, 
    pat.sitecode, 
    case when EntryPoint is not null Then 1 Else 0 end as TestedAtANC 
  from 
    PBFW_Patient pat 
    inner join ODS.dbo.HTS_ClientTests tests on pat.PatientPKHash = tests.PatientPKHash 
    and pat.SiteCode = tests.SiteCode 
  where 
    EntryPoint in ('PMTCT ANC', 'MCH') and NUM=1
), 
TestedAtLandD AS (
  Select 
    row_number() OVER (
      PARTITION BY Pat.SiteCode, 
      Pat.Patientpkhash 
      ORDER BY 
        tests.testdate asc
    ) AS NUM,
    pat.PatientPKHash, 
    pat.sitecode, 
    case when EntryPoint is not null Then 1 Else 0 end as TestedAtLandD 
  from 
    PBFW_Patient pat 
    inner join ODS.dbo.HTS_ClientTests tests on pat.PatientPKHash = tests.PatientPKHash 
    and pat.SiteCode = tests.SiteCode 
  where 
    EntryPoint in ('Maternity', 'PMTCT MAT') and NUM=1
), 
Summary As (
  Select 
    patient.PatientPKHash, 
    patient.SiteCode, 
    DOB, 
    Gender, 
    VisitDate as ANCDate1, 
    ANCDate2, 
    ANCDate3, 
    ANCDate4, 
    TestedatANC, 
    TestedAtLandD, 
    case when DATEDIFF(
      YEAR, 
      DOB, 
      GETDATE()
    ) between 10 
    and 19 Then 1 else 0 End as PositiveAdolescent, 
    case when DateConfirmedHIVPositive = VisitDate Then 1 Else 0 End as NewPositives, 
    Case when DateConfirmedHIVPositive < VisitDate Then 1 Else 0 End as KnownPositive, 
    case when StartARTDate is not null Then 1 Else 0 End as RecieivedART, 
    coalesce (EligibleVL, 0) As EligibleVL, 
    Suppressed, 
    case when ValidVLResultCategory >= 200.00 Then 1 Else 0 End as Unsuppressed, 
    ValidVLResultCategory 
  from 
    PBFW_Patient as Patient 
    left join ANCDate2 on Patient.PatientPKHash = ANCDate2.PatientPKHash 
    and Patient.SiteCode = ANCDate2.SiteCode 
    left join ANCDate3 on Patient.PatientPKHash = ANCDate3.PatientPKHash 
    and Patient.SiteCode = ANCDate3.SiteCode 
    left join ANCDate4 on Patient.PatientPKHash = ANCDate4.PatientPKHash 
    and Patient.SiteCode = ANCDate4.SiteCode 
    left join TestedatANC on Patient.PatientPKHash = TestedatANC.PatientPKHash 
    and Patient.SiteCode = TestedatANC.SiteCode 
    left join TestedAtLandD on Patient.PatientPKHash = TestedAtLandD.PatientPKHash 
    and Patient.SiteCode = TestedAtLandD.SiteCode 
  where Patient.Num = 1 
    
) 
Select 
  FactKey = IDENTITY(INT, 1, 1), 
  Patient.PatientKey, 
  Facility.FacilityKey, 
  Partner.PartnerKey, 
  Agency.AgencyKey, 
  ANCDate1, 
  ANCDate2, 
  ANCDate3, 
  ANCDate4, 
  TestedatANC, 
  TestedAtLandD, 
  PositiveAdolescent, 
  NewPositives, 
  KnownPositive, 
  RecieivedART, 
  EligibleVL, 
  Suppressed, 
  Unsuppressed, 
  ValidVLResultCategory, 
  ANCDate1.DateKey as ANCDate1Key, 
  ANCDate2.DateKey as ANCDate2Key, 
  ANCDate3.DateKey as ANCDate3Key, 
  ANCDate4.DateKey as ANCDate4Key Into NDWH.dbo.FactPBFW 
from 
  Summary 
  left join NDWH.dbo.DimFacility as Facility on Facility.MFLCode = Summary.SiteCode 
  left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = Summary.SiteCode 
  left join NDWH.dbo.DimPartner as Partner on Partner.PartnerName = MFL_partner_agency_combination.SDP 
  left join NDWH.dbo.DimAgency as Agency on Agency.AgencyName = MFL_partner_agency_combination.Agency 
  left join NDWH.dbo.DimPatient as Patient on Patient.PatientPKHash = Summary.PatientPKHash 
  and Patient.SiteCode = Summary.SiteCode 
  left join NDWH.dbo.DimDate as ANCDate1 on ANCDate1.Date = cast(Summary.ANCDate1 as date) 
  left join NDWH.dbo.DimDate as ANCDate2 on ANCDate2.Date = cast(Summary.ANCDate2 as date) 
  left join NDWH.dbo.DimDate as ANCDate3 on ANCDate3.Date = cast(Summary.ANCDate3 as date) 
  left join NDWH.dbo.DimDate as ANCDate4 on ANCDate4.Date = cast(Summary.ANCDate4 as date) 
alter table 
  NDWH.dbo.FactPBFW 
add 
  primary key(FactKey);
End
