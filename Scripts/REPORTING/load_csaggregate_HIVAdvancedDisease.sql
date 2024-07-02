If Object_id(N'HIVCaseSurveillance.dbo.CsAggregateAdvanceHIVDisease', N'U') Is Not Null
  Drop Table Hivcasesurveillance.Dbo.CsAggregateAdvanceHIVDisease;

WITH VisitData AS (
    SELECT 
          pat.PatientKey,
          facility.FacilityName,
          partner.PartnerName,
          agency.AgencyName,
          pat.Gender,             
          County,             
          SubCounty,          
		  EOMONTH (DateConfirmedHIVPositiveKey) As CohortYearMonth,
          visits.WHOStage,
          EOMONTH(VisitDateKey) AS AsofDate
    FROM NDWH.dbo.FactVisits as visits
left join NDWH.dbo.DimFacility as facility on facility.FacilityKey = visits.FacilityKey
Left join NDWH.dbo.DimPatient as pat on pat.PatientKey=visits.PatientKey
left join NDWH.dbo.DimPartner as partner on partner.PartnerKey = visits.PartnerKey
left join NDWH.dbo.DimAgency as agency on agency.AgencyKey = visits.AgencyKey
    WHERE visits.PatientKey is not null

),
RankedVisits AS (
    SELECT 
          VisitData.PatientKey,
          FacilityName,
          PartnerName,
          AgencyName,
          Gender,
          County,
          SubCounty,
          AsofDate,
		  CohortYearMonth,
          VisitData.WHOStage,
          ROW_NUMBER() OVER (PARTITION BY PatientKey, AsofDate ORDER BY AsofDate DESC) AS VisitRank
    FROM VisitData
),
LatestVisits AS (
    SELECT 
          PatientKey,
          FacilityName,
          PartnerName,
          AgencyName,
          Gender,
          County,
          SubCounty,
          AsofDate,
		  CohortYearMonth,
          WHOStage
    FROM RankedVisits
    WHERE VisitRank = 1
)
SELECT 
      AsofDate,
	  CohortYearMonth,
      FacilityName
      Partnername,
      AgencyName,
      Gender,
      County,
      SubCounty,
      WHOStage,
      COUNT(*) AS WHOStageCount
	  into Hivcasesurveillance.dbo.CsAggregateAdvanceHIVDisease
FROM LatestVisits
GROUP BY 
      AsofDate,
	  CohortYearMonth,
      FacilityName,
      PartnerName,
      AgencyName,
      Gender,
      County,
      SubCounty,
      WHOStage
