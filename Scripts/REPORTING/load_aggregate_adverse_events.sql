IF EXISTS (
    SELECT
        *
    FROM
        [REPORTING].sys.objects
    WHERE
        object_id = OBJECT_ID(N'[REPORTING].[dbo].[AggregateAdverseEvents]')
        AND type in (N'U')
) TRUNCATE TABLE [REPORTING].[dbo].AggregateAdverseEvents

GO

with AdverseEvents as (
 SELECT
            MFLCode,
            pat.PatientKey,
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

INSERT INTO [REPORTING].[dbo].AggregateAdverseEvents
SELECT
    MFLCode,
    DATIMAgeGroup,
    Gender,
    FacilityName,
    County,
    Subcounty,
    PartnerName,
    AgencyName,
    AdverseEvent,
    AdverseEventCause,
    AdverseEventActionTaken,
    AdverseEventRegimen,
    Severity,
	count(*) as AdverseEventsCount

FROM AdverseEvents
GROUP BY
    MFLCode,
    DATIMAgeGroup,
    Gender,
    FacilityName,
    County,
    Subcounty,
    PartnerName,
    AgencyName,
    AdverseEvent,
    AdverseEventCause,
    AdverseEventActionTaken,
    AdverseEventRegimen,
    Severity
GO
