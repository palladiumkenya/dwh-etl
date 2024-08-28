
IF OBJECT_ID(N'[HIVCaseSurveillance].[dbo].[CsLinelistReportedCasesRisks]', N'U') IS NOT NULL 
	DROP TABLE [HIVCaseSurveillance].[dbo].[CsLinelistReportedCasesRisks];
    with confirmed_reported_cases_and_art as (
        select 
                art.PatientKey,
                patient.Gender,
                art.AgeLastVisit,
                art.FacilityKey,
                PartnerKey,
                AgencyKey,
                eomonth(confirmed_date.Date) as CohortYearMonth,
                case 
					when art_date.Date < confirmed_date.Date then confirmed_date.Date
					else art_date.Date
				end as StartARTDate,
                DATEDIFF(year,patient.DOB,confirmed_date.Date) as AgeatDiagnosis
            from NDWH.dbo.FACTART as art 
            left join NDWH.dbo.DimPatient as patient on patient.PatientKey = art.PatientKey
            left join NDWH.dbo.DimDate as confirmed_date on confirmed_date.DateKey = patient.DateConfirmedHIVPositiveKey
            left join NDWH.dbo.DimDate as art_date on art_date.DateKey = art.StartARTDateKey
    
    ),
    RiskFactors as (
        Select 
        PatientKey,
        row_number() OVER (PARTITION BY Patientkey ORDER BY VisitDatekey DESC) AS NUM,
        case when MultiplePartners= 'YES' Then 1 Else 0 End as HasMultiplePartners,
        case when NumberOfPartners is not null then NumberOfPartners Else 0 End as NumerofSexualPartners,
        case when HIVRiskCategory in ('High','Moderate','Very high') Then 1 Else 0 End as HTSHighRiskCategory
        from NDWH.dbo.FactHTSEligibilityextract as eligibility
        where  PatientKey is not null 
    ),
    LatestRiskFactors as (
        Select 
        PatientKey,
        HasMultiplePartners,
        NumerofSexualPartners,
        HTSHighRiskCategory
        from RiskFactors
        where NUM=1
    ),
    PrepVisits as (
        SELECT
        PatientKey,
          row_number() OVER (PARTITION BY Patientkey ORDER BY VisitDatekey DESC) AS NUM
        from NDWH.dbo.FactPrepVisits
    ),
    LatestPrepVisits as (
        Select 
        PatientKey
        from PrepVisits
        where NUM=1
    ),
    PBFWNotOnART as (
        SELECT
        Patientkey,
        startregimen,
        startartdatekey
        from NDWH.dbo.FactART
        where ispbfwatconfirmationpositive=1 and (startartdatekey is null and startregimen is null) 
    ) , 
    InfantsNotOnProphylaxis as (
      SELECT
      PatientKey
      from ndwh.dbo.FactHEI
      where onprohylaxis <> 1
    )
    select 
        confirmed_reported_cases_and_art.PatientKey,
        Gender,
        AgeLastVisit,
        FacilityName,
        PartnerName,
        AgencyName,
        CohortYearMonth,
        StartARTDate,
        HasMultiplePartners,
        NumerofSexualPartners,
        HTSHighRiskCategory,
        case when LatestPrepVisits.PatientKey is not null then 1 else 0 End as Secoronverted,
        case when AgeatDiagnosis <15 Then 1 Else 0 End as IsChild,
        case when PBFWNotOnART.patientkey is not null then 1 Else 0 end as PbfwNotOnART,
        case when InfantsNotOnProphylaxis.patientkey is not null then 1 else 0 End as InfantsNotOnProphylaxis
 into [HIVCaseSurveillance].[dbo].[CsLinelistReportedCasesRisks]
    from confirmed_reported_cases_and_art
    left join LatestRiskFactors as risks   on confirmed_reported_cases_and_art.PatientKey = risks.PatientKey
    left join NDWH.dbo.DimFacility as facility on facility.FacilityKey=confirmed_reported_cases_and_art.FacilityKey
    left join NDWH.dbo.DimPartner as partner on partner.PartnerKey=confirmed_reported_cases_and_art.PartnerKey
    left join NDWH.dbo.DimAgency as agency on agency.AgencyKey=confirmed_reported_cases_and_art.AgencyKey
    left join LatestPrepVisits on LatestPrepVisits.PatientKey=confirmed_reported_cases_and_art.PatientKey
    left join PBFWNotOnART on PBFWNotOnART.Patientkey=confirmed_reported_cases_and_art.Patientkey
    left join InfantsNotOnProphylaxis on InfantsNotOnProphylaxis.patientkey=confirmed_reported_cases_and_art.PatientKey
   
    
  
    



