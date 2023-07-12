IF OBJECT_ID(N'[REPORTING].[dbo].LineListAdverseEvents', N'U') IS NOT NULL 		
	drop TABLE [REPORTING].[dbo].LineListAdverseEvents

GO

with AdverseEvents as (
 SELECT
            MFLCode,
            PatientIDHash,
            PatientPKHash,
            NUPI,
            g.DATIMAgeGroup,
            Gender,
            f.FacilityName,
            County,
            SubCounty,
            p.PartnerName,
            a.AgencyName,
            AdverseEvent,
            AdverseEventCause,
            AdverseEventRegimen,
            AdverseEventActionTaken,
            Severity
        FROM
            [NDWH].dbo.FactAdverseEvents it
            INNER join NDWH.dbo.DimFacility f on f.FacilityKey = it.FacilityKey
            INNER JOIN NDWH.dbo.DimAgency a on a.AgencyKey = it.AgencyKey
            INNER JOIN NDWH.dbo.DimPatient pat on pat.PatientKey = it.PatientKey
            INNER JOIN NDWH.dbo.DimPartner p on p.PartnerKey = it.PartnerKey
            INNER JOIN NDWH.dbo.FactART art on art.PatientKey = it.PatientKey
            LEFT join NDWH.dbo.DimAgeGroup g on g.Age = art.AgeLastVisit
        WHERE
            pat.IsTXCurr = 1
)

SELECT
   MFLCode,
            PatientIDHash,
            PatientPKHash,
            NUPI,
            DATIMAgeGroup,
            Gender,
            FacilityName,
            County,
            SubCounty,
            PartnerName,
            AgencyName,
            AdverseEvent,
            AdverseEventCause,
            AdverseEventRegimen,
            AdverseEventActionTaken,
            Severity
Into  [REPORTING].[dbo].LineListAdverseEvents
FROM AdverseEvents
GO
