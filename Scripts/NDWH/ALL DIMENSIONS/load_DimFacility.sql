
BEGIN
    WITH source_facility
         AS (SELECT DISTINCT Cast(mfl_code AS NVARCHAR) AS MFLCode,
                             facility_name              AS [FacilityName],
                             subcounty,
                             county,
                             emr,
                             project,
                             longitude,
                             latitude,
                             implementation,
                             sdp_agency                 AS Agency
             FROM   ods.dbo.all_emrsites),
         site_abstraction
         AS (SELECT sitecode,
                    Max(visitdate) AS DateSiteAbstraction
             FROM   ods.dbo.ct_patientvisits
             GROUP  BY sitecode),
         latest_upload
         AS (SELECT sitecode,
                    Max(Cast([daterecieved] AS DATE)) AS LatestDateUploaded
             FROM   [ODS].[dbo].[ct_facilitymanifest](nolock)
             GROUP  BY sitecode)
    MERGE [NDWH].[dbo].[dimfacility] AS a
    using (SELECT source_facility.*,
                  Cast(Format(site_abstraction.datesiteabstraction, 'yyyyMMdd')
                       AS
                       INT) AS
                  DateSiteAbstractionKey,
                  Cast(Format(latest_upload.latestdateuploaded, 'yyyyMMdd') AS
                       INT)
                  AS
                  LatestDateUploadedKey,
                  CASE
                    WHEN [implementation] LIKE '%CT%' THEN 1
                    ELSE 0
                  END
                  AS
                        isCT,
                  CASE
                    WHEN [implementation] LIKE '%CT%' THEN 1
                    ELSE 0
                  END
                  AS
                        isPKV,
                  CASE
                    WHEN [implementation] LIKE '%HTS%' THEN 1
                    ELSE 0
                  END
                  AS
                        isHTS,
                  Cast(Getdate() AS DATE)
                  AS
                        LoadDate
           FROM   source_facility
                  LEFT JOIN site_abstraction
                         ON site_abstraction.sitecode = source_facility.mflcode
                  LEFT JOIN latest_upload
                         ON latest_upload.sitecode = source_facility.mflcode) AS
          b
    ON ( a.mflcode = b.mflcode )
    WHEN NOT matched THEN
      INSERT( mflcode,
              facilityname,
              subcounty,
              county,
              emr,
              project,
              longitude,
              latitude,
              implementation,
              datesiteabstractionkey,
              latestdateuploadedkey,
              isct,
              ispkv,
              ishts,
              loaddate )
      VALUES ( mflcode,
               facilityname,
               subcounty,
               county,
               emr,
               project,
               longitude,
               latitude,
               implementation,
               datesiteabstractionkey,
               latestdateuploadedkey,
               isct,
               ispkv,
               ishts,
               loaddate )
    WHEN matched THEN
      UPDATE SET a.facilityname = b.facilityname,
                 a.subcounty = b.subcounty,
                 a.county = b.county,
                 a.longitude = b.longitude,
                 a.latitude = b.latitude,
                 a.implementation = b.implementation;

    WITH cte
         AS (SELECT mflcode,
                    Row_number()
                      OVER (
                        partition BY mflcode
                        ORDER BY mflcode ) Row_Num
             FROM   ndwh.dbo.dimfacility)
    DELETE FROM cte
    WHERE  row_num > 1;
END 
