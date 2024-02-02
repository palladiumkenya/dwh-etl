BEGIN ;
    WITH cte
         AS (SELECT P.patientpid,
                    PA.patientid,
                    F.code,
                    PA.visitdate,
                    PA.created,
                    Row_number()
                      OVER (
                        partition BY P.patientpid, F.code, PA.visitdate
                        ORDER BY PA.created DESC) Row_Num
             FROM   [DWAPICentral].[dbo].[patientextract](nolock) P
                    INNER JOIN
                    [DWAPICentral].[dbo].patientadverseeventextract(nolock) PA
                            ON PA.[patientid] = P.id
                               AND PA.voided = 0
                    INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F
                            ON P.[facilityid] = F.id
                               AND F.voided = 0)
    DELETE pb
    FROM   [DWAPICentral].[dbo].patientadverseeventextract(nolock) pb
           INNER JOIN [DWAPICentral].[dbo].[patientextract](nolock) P
                   ON PB.[patientid] = P.id
                      AND PB.voided = 0
           INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F
                   ON P.[facilityid] = F.id
                      AND F.voided = 0
           INNER JOIN cte
                   ON pb.patientid = cte.patientid
                      AND cte.created = pb.created
                      AND cte.code = f.code
                      AND cte.visitdate = pb.visitdate
    WHERE  Row_Num > 1;

    DECLARE @MaxAdverseEventStartDate DATETIME,
            @AdverseEventStartDate    DATETIME,
            @MaxCreatedDate           DATETIME

    SELECT @MaxAdverseEventStartDate = Max(maxadverseeventstartdate)
    FROM   [ODS].[dbo].[ct_adverseevent_log] (nolock);

    SELECT @AdverseEventStartDate = Max(adverseeventstartdate)
    FROM   [DWAPICentral].[dbo].[patientadverseeventextract] WITH (nolock);

    SELECT @MaxCreatedDate = Max(createddate)
    FROM   [ODS].[dbo].[ct_adverseeventcount_log] WITH (nolock);

    --insert into  [ODS].[dbo].[CT_AdverseEventCount_Log](CreatedDate)
    --values(dateadd(year,-1,getdate()))
    INSERT INTO [ODS].[dbo].[ct_adverseevent_log]
                (maxadverseeventstartdate,
                 loadstartdatetime)
    VALUES     (@AdverseEventStartDate,
                Getdate());

    --CREATE INDEX CT_AdverseEvents  ON [ODS].[dbo].[CT_AdverseEvents] (sitecode,PatientPK);
    ---- Refresh [ODS].[dbo].[CT_AdverseEvents]
    MERGE [ODS].[dbo].[ct_adverseevents] AS a
    using(SELECT DISTINCT P.[patientcccnumber] AS PatientID,
                          P.[patientpid]       AS PatientPK,
                          F.NAME               AS FacilityName,
                          F.code               AS SiteCode,
                          [adverseevent],
                          [adverseeventstartdate],
                          [adverseeventenddate],
                          CASE [severity]
                            WHEN '1' THEN 'Mild'
                            WHEN '2' THEN 'Moderate'
                            WHEN '3' THEN 'Severe'
                            ELSE [severity]
                          END                  AS [Severity],
                          [visitdate],
                          PA.[emr],
                          PA.[project],
                          [adverseeventcause],
                          [adverseeventregimen],
                          [adverseeventactiontaken],
                          [adverseeventclinicaloutcome],
                          [adverseeventispregnant],
                          PA.id,
                          PA.[date_created],
                          PA.[date_last_modified],
                          PA.recorduuid,
                          PA.voided
          FROM   [DWAPICentral].[dbo].[patientextract](nolock) P
                 INNER JOIN
                 [DWAPICentral].[dbo].patientadverseeventextract(nolock)
                 PA
                         ON PA.[patientid] = P.id
                 INNER JOIN [DWAPICentral].[dbo].[facility](nolock) F
                         ON P.[facilityid] = F.id
                            AND F.voided = 0
                            AND F.code > 0) AS b
    ON( a.sitecode = b.sitecode
        AND a.patientpk = b.patientpk
        AND a.visitdate = b.visitdate
        AND a.voided = b.voided
        AND a.id = b.id )
    WHEN NOT matched THEN
      INSERT(patientid,
             patientpk,
             sitecode,
             adverseevent,
             adverseeventstartdate,
             adverseeventenddate,
             severity,
             visitdate,
             emr,
             project,
             adverseeventcause,
             adverseeventregimen,
             adverseeventactiontaken,
             adverseeventclinicaloutcome,
             adverseeventispregnant,
             [date_created],
             [date_last_modified],
             recorduuid,
             voided,
             loaddate)
      VALUES(patientid,
             patientpk,
             sitecode,
             adverseevent,
             adverseeventstartdate,
             adverseeventenddate,
             severity,
             visitdate,
             emr,
             project,
             adverseeventcause,
             adverseeventregimen,
             adverseeventactiontaken,
             adverseeventclinicaloutcome,
             adverseeventispregnant,
             [date_created],
             [date_last_modified],
             recorduuid,
             voided,
             Getdate())
    WHEN matched THEN
      UPDATE SET a.[patientid] = b.[patientid],
                 a.[adverseevent] = b.[adverseevent],
                 a.[adverseeventstartdate] = b.[adverseeventstartdate],
                 a.[adverseeventenddate] = b.[adverseeventenddate],
                 a.[severity] = b.[severity],
                 a.[visitdate] = b.[visitdate],
                 a.[adverseeventcause] = b.[adverseeventcause],
                 a.[adverseeventregimen] = b.[adverseeventregimen],
                 a.[adverseeventactiontaken] = b.[adverseeventactiontaken],
                 a.[adverseeventclinicaloutcome] =
                 b.[adverseeventclinicaloutcome],
                 a.[adverseeventispregnant] = b.[adverseeventispregnant],
                 a.[facilityname] = b.[facilityname],
                 a.[date_last_modified] = b.[date_last_modified],
                 a.[date_created] = b.[date_created],
                 a.[recorduuid] = b.[recorduuid],
                 a.[voided] = b.[voided];

    --------------------------------------------------------End
    UPDATE [ODS].[dbo].[ct_adverseevent_log]
    SET    loadenddatetime = Getdate()
    WHERE  maxadverseeventstartdate = @AdverseEventStartDate;

    --truncate table [ODS].[dbo].[CT_AdverseEventCount_Log]
    INSERT INTO [ODS].[dbo].[ct_adverseeventcount_log]
                ([sitecode],
                 [createddate],
                 [adverseeventcount])
    SELECT sitecode,
           Getdate(),
           Count(Concat(sitecode, patientpk)) AS AdverseEventCount
    FROM   [ODS].[dbo].[ct_adverseevents]
    --WHERE @MaxCreatedDate  > @MaxCreatedDate
    GROUP  BY sitecode;
END 