DECLARE @Start_date Date = '2019-01-31',
        @End_date   Date = '2023-04-30';

WITH Dates
     AS (SELECT Datefromparts(Year(@Start_date), Month(@Start_date), 1) AS dte
         UNION ALL
         SELECT Dateadd(Month, 1, Dte)
         FROM   Dates
         WHERE  Dateadd(Month, 1, Dte) <= @End_date)
SELECT Eomonth(Dte) AS end_date
INTO   #months
FROM   Dates
OPTION (Maxrecursion 0);

--declare as of date
DECLARE @As_of_date AS Date;
--declare cursor
DECLARE Cursor_asofdates CURSOR FOR
  SELECT *
  FROM   #months

OPEN Cursor_asofdates

FETCH Next FROM Cursor_asofdates INTO @As_of_date

WHILE @@fetch_status = 0
  BEGIN
      WITH Clinical_visits_as_of_date
           AS (
              /* get visits as of date */
              SELECT Patientpkhash,
                     Patientidhash,
                     Patientid,
                     Patientpk,
                     Sitecode,
                     Visitdate,
                     Nextappointmentdate
               FROM   Ods.Dbo.Ct_patientvisits
               WHERE  Sitecode > 0
                      AND Nextappointmentdate <= @As_of_date),
           Pharmacy_visits_as_of_date
           AS (
              /* get pharmacy dispensations as of date */
              SELECT Patientpkhash,
                     Patientidhash,
                     Patientid,
                     Patientpk,
                     Sitecode,
                     Dispensedate,
                     Expectedreturn
               FROM   Ods.Dbo.Ct_patientpharmacy
               WHERE  Sitecode > 0
                      AND Expectedreturn <= @As_of_date),
           Patient_art_and_enrollment_info
           AS (
              /* get patients' ART start date */
              SELECT DISTINCT Ct_artpatients.Patientidhash,
                              Ct_artpatients.Patientpkhash,
                              Ct_artpatients.Patientpk,
                              Ct_artpatients.Patientid,
                              Ct_artpatients.Sitecode,
                              Ct_artpatients.Startartdate,
                              Ct_artpatients.Expectedreturn,
                              Ct_artpatients.Startregimen,
                              Ct_artpatients.Startregimenline,
                              Ct_patient.Registrationatccc
                              AS
                              EnrollmentDate,
                              Ct_patient.Dob,
                              Ct_patient.Gender,
                              Ct_patient.Dateconfirmedhivpositive,
                              Datediff(Yy, Ct_patient.Dob,
                              Ct_patient.Registrationatccc) AS
                              AgeEnrollment
               FROM   Ods.Dbo.Ct_artpatients
                      LEFT JOIN Ods.Dbo.Ct_patient
                             ON Ct_patient.Patientpk = Ct_artpatients.Patientpk
                                AND Ct_patient.Sitecode =
                                    Ct_artpatients.Sitecode)
      ,
           Visit_encounter_as_of_date_ordering
           AS (
              /* order visits as of date by the VisitDate */
              SELECT Clinical_visits_as_of_date.*,
                     Row_number()
                       OVER (
                         Partition BY Patientpk, Sitecode
                         ORDER BY Visitdate DESC) AS rank
               FROM   Clinical_visits_as_of_date),
           Pharmacy_dispense_as_of_date_ordering
           AS (
              /* order pharmacy dispensations as of date by the VisitDate */
              SELECT Pharmacy_visits_as_of_date.*,
                     Row_number()
                       OVER (
                         Partition BY Patientpk, Sitecode
                         ORDER BY Dispensedate DESC) AS rank
               FROM   Pharmacy_visits_as_of_date),
           Last_visit_encounter_as_of_date
           AS (
              /*get the latest visit record for patients for as of date */
              SELECT *
               FROM   Visit_encounter_as_of_date_ordering
               WHERE  Rank = 1),
           Second_last_visit_encounter_as_of_date
           AS (
              /*get the second latest visit record for patients for as of date */
              SELECT *
               FROM   Visit_encounter_as_of_date_ordering
               WHERE  Rank = 2),
           Last_pharmacy_dispense_as_of_date
           AS (
              /*get the latest pharmacy dispensations record for patients for as of date */
              SELECT *
               FROM   Pharmacy_dispense_as_of_date_ordering
               WHERE  Rank = 1),
           Second_last_pharmacy_dispense_as_of_date
           AS (
              /*get the second latest pharmacy dispensations record for patients for as of date */
              SELECT *
               FROM   Pharmacy_dispense_as_of_date_ordering
               WHERE  Rank = 2),
           Effective_discontinuation_ordering
           AS (
              /*order the effective discontinuation by the EffectiveDiscontinuationDate*/
              SELECT Patientidhash,
                     Patientpkhash,
                     Patientid,
                     Patientpk,
                     Sitecode,
                     Effectivediscontinuationdate,
                     Exitdate,
                     Exitreason,
                     Row_number()
                       OVER (
                         Partition BY Patientpk, Sitecode
                         ORDER BY Effectivediscontinuationdate DESC) AS rank
               FROM   Ods.Dbo.Ct_patientstatus
               WHERE  Exitdate IS NOT NULL
                      AND Effectivediscontinuationdate IS NOT NULL),
           Latest_effective_discontinuation
           AS (
              /*get the latest discontinuation record*/
              SELECT *
               FROM   Effective_discontinuation_ordering
               WHERE  Rank = 1),
           Exits_as_of_date
           AS (
              /* get exits as of date */
              SELECT Patientidhash,
                     Patientpkhash,
                     Patientid,
                     Patientpk,
                     Sitecode,
                     Exitdate,
                     Exitreason,
                     Reenrollmentdate
               FROM   Ods.Dbo.Ct_patientstatus
               WHERE  Exitdate <= @As_of_date),
           Exits_as_of_date_ordering
           AS (
              /* order the exits by the ExitDate*/
              SELECT Patientidhash,
                     Patientpkhash,
                     Patientid,
                     Patientpk,
                     Sitecode,
                     Exitdate,
                     Exitreason,
                     Reenrollmentdate,
                     Row_number()
                       OVER (
                         Partition BY Patientpk, Sitecode
                         ORDER BY Exitdate DESC) AS rank
               FROM   Exits_as_of_date),
           Last_exit_as_of_date
           AS (
              /* get latest exit_date as of date */
              SELECT *
               FROM   Exits_as_of_date_ordering
               WHERE  Rank = 1),
           Visits_and_dispense_encounters_combined_tbl
           AS (
              /* combine latest visits and latest pharmacy dispensation records as of date - 'borrowed logic from the view vw_PatientLastEnconter*/
              /* we don't include the CT_ARTPatients table logic because this table has only the latest records of the patients (no history) */
              SELECT DISTINCT COALESCE (Last_visit.Patientidhash,
                              Last_dispense.Patientidhash) AS
                              PatientIDHash,
                              COALESCE(Last_visit.Sitecode,
                              Last_dispense.Sitecode)
                              AS SiteCode,
                              COALESCE(Last_visit.Patientpkhash,
                              Last_dispense.Patientpkhash)
                              AS PatientPKhash,
                              COALESCE(Last_visit.Patientpk,
                              Last_dispense.Patientpk)
                              AS PatientPK,
                              COALESCE(Last_visit.Patientid,
                              Last_dispense.Patientid)
                              AS PatientID,
                              CASE
                                WHEN Last_visit.Visitdate >=
                                     Last_dispense.Dispensedate
                              THEN
                                Last_visit.Visitdate
                                ELSE Isnull(Last_dispense.Dispensedate,
                                     Last_visit.Visitdate)
                              END
                              AS LastEncounterDate,
                              CASE
                                WHEN Last_visit.Nextappointmentdate >=
                                     Last_dispense.Expectedreturn THEN
                                Last_visit.Nextappointmentdate
                                ELSE Isnull(Last_dispense.Expectedreturn,
                                     Last_visit.Nextappointmentdate)
                              END
                              AS NextAppointmentDate
               FROM   Last_visit_encounter_as_of_date AS Last_visit
                      FULL JOIN Last_pharmacy_dispense_as_of_date AS
                                Last_dispense
                             ON Last_visit.Sitecode = Last_dispense.Sitecode
                                AND Last_visit.Patientpk =
                                    Last_dispense.Patientpk
               WHERE  CASE
                        WHEN Last_visit.Visitdate >= Last_dispense.Dispensedate
                      THEN
                        Last_visit.Visitdate
                        ELSE Isnull(Last_dispense.Dispensedate,
                             Last_visit.Visitdate)
                      END IS NOT NULL),
           Uploads
           AS (SELECT [Daterecieved],
                      Row_number()
                        OVER(
                          Partition BY Sitecode
                          ORDER BY [Daterecieved] DESC) AS Num,
                      Sitecode,
                      Cast([Daterecieved]AS Date)       AS DateReceived
               FROM   Ods.Dbo.Ct_facilitymanifest),
           Uploads_as_of_date
           AS (
              /* get Uploads as of date */
              SELECT Sitecode,
                     Daterecieved
               FROM   Ods.Dbo.Ct_facilitymanifest
               WHERE  Daterecieved <= @As_of_date),
           Uploads_as_of_date_ordering
           AS (
              /* order the Uploads by the DateReceived*/
              SELECT Sitecode,
                     Daterecieved,
                     Row_number()
                       OVER (
                         Partition BY Sitecode
                         ORDER BY Daterecieved DESC) AS rank
               FROM   Uploads_as_of_date),
           Last_upload_as_of_date
           AS (
              /* get latest upload_date as of date */
              SELECT Sitecode,
                     Daterecieved
               FROM   Uploads_as_of_date_ordering
               WHERE  Rank = 1),
           Secondlast_visits_and_dispense_encounters_combined_tbl
           AS (
              /* combine latest visits and latest pharmacy dispensation records as of date - 'borrowed logic from the view vw_PatientLastEnconter*/
              /* we don't include the CT_ARTPatients table logic because this table has only the latest records of the patients (no history) */
              SELECT DISTINCT COALESCE (Second_last_visit.Patientidhash,
                              Second_last_dispense.Patientidhash)
                              AS PatientIDHash,
                              COALESCE(Second_last_visit.Sitecode,
                              Second_last_dispense.Sitecode)           AS
                              SiteCode
                              ,
                              COALESCE(
              Second_last_visit.Patientpkhash,
                              Second_last_dispense.Patientpkhash) AS
                              PatientPKhash,
                              COALESCE(Second_last_visit.Patientpk,
                              Second_last_dispense.Patientpk)         AS
                              PatientPK,
                              COALESCE(Second_last_visit.Patientid,
                              Second_last_dispense.Patientid)         AS
                              PatientId,
                              CASE
                                WHEN Second_last_visit.Visitdate >=
                                     Second_last_dispense.Dispensedate THEN
                                Second_last_visit.Visitdate
                                ELSE Isnull(Second_last_dispense.Dispensedate,
                                     Second_last_visit.Visitdate)
                              END
                              AS LastEncounterDate,
                              CASE
                                WHEN Second_last_visit.Nextappointmentdate >=
                                     Second_last_dispense.Expectedreturn THEN
                                Second_last_visit.Nextappointmentdate
                                ELSE Isnull(Second_last_dispense.Expectedreturn,
Second_last_visit.Nextappointmentdate)
END
AS NextAppointmentDate
FROM   Second_last_visit_encounter_as_of_date AS Second_last_visit
FULL JOIN Second_last_pharmacy_dispense_as_of_date AS
Second_last_dispense
ON Second_last_visit.Sitecode =
Second_last_dispense.Sitecode
AND Second_last_visit.Patientpk =
Second_last_dispense.Patientpk
WHERE  CASE
WHEN Second_last_visit.Visitdate >=
Second_last_dispense.Dispensedate
THEN
Second_last_visit.Visitdate
ELSE Isnull(Second_last_dispense.Dispensedate,
Second_last_visit.Visitdate)
END IS NOT NULL),
Second_last_encounter
AS (
/* preparing the second latest encounter records as of date */
SELECT
Secondlast_visits_and_dispense_encounters_combined_tbl .Patientidhash,
Secondlast_visits_and_dispense_encounters_combined_tbl .Sitecode,
Secondlast_visits_and_dispense_encounters_combined_tbl .Patientpk,
Secondlast_visits_and_dispense_encounters_combined_tbl .Patientid,
Secondlast_visits_and_dispense_encounters_combined_tbl .Patientpkhash,
Secondlast_visits_and_dispense_encounters_combined_tbl .Lastencounterdate
AS
Second_Last_EncounterDate,
CASE
WHEN Datediff(Dd, @As_of_date,
Secondlast_visits_and_dispense_encounters_combined_tbl.Nextappointmentdate)
>=
365 THEN Dateadd(Day, 30,
Secondlast_visits_and_dispense_encounters_combined_tbl .Lastencounterdate)
ELSE
Secondlast_visits_and_dispense_encounters_combined_tbl.Nextappointmentdate
END
AS
second_last_NextAppointmentDate
FROM   Secondlast_visits_and_dispense_encounters_combined_tbl),
Last_encounter
AS (
/* preparing the latest encounter records as of date */
SELECT Visits_and_dispense_encounters_combined_tbl.Patientidhash,
Visits_and_dispense_encounters_combined_tbl.Sitecode,
Visits_and_dispense_encounters_combined_tbl.Patientpk,
Visits_and_dispense_encounters_combined_tbl.Patientid,
Visits_and_dispense_encounters_combined_tbl.Patientpkhash,
Visits_and_dispense_encounters_combined_tbl.Lastencounterdate,
CASE
WHEN Datediff(Dd, @As_of_date,
Visits_and_dispense_encounters_combined_tbl.Nextappointmentdate)
>= 365
THEN Dateadd(Day, 30, Lastencounterdate)
ELSE Visits_and_dispense_encounters_combined_tbl.Nextappointmentdate
END AS NextAppointmentDate
FROM   Visits_and_dispense_encounters_combined_tbl),
Artoutcomescompuation
AS (
/* computing the ART_Outcome as of date - 'borrowed logic from the view vw_ARTOutcomeX'*/
SELECT Last_encounter.*,
Patient_art_and_enrollment_info.Startartdate,
Last_exit_as_of_date.Exitdate,
Patient_art_and_enrollment_info.Enrollmentdate,
Patient_art_and_enrollment_info.Ageenrollment,
Patient_art_and_enrollment_info.Startregimen,
Patient_art_and_enrollment_info.Startregimenline,
Patient_art_and_enrollment_info.Dateconfirmedhivpositive,
Patient_art_and_enrollment_info.Gender,
Datediff(Year, Patient_art_and_enrollment_info.Dob,
Last_encounter.Lastencounterdate)                     AS
AgeLastVisit,
Second_last_encounter.Second_last_nextappointmentdate AS
ExpectedNextAppointmentDate,
Second_last_encounter.Second_last_encounterdate       AS
ExpectedLastEncounter,
Datediff(Mm, Patient_art_and_enrollment_info.Startartdate,
Eomonth(
@As_of_date))
ARTDurationMonths,
@As_of_date                                           AS AsOfDate
FROM   Last_encounter
LEFT JOIN Latest_effective_discontinuation
ON Latest_effective_discontinuation.Patientpk =
Last_encounter.Patientpk
AND Latest_effective_discontinuation.Sitecode =
Last_encounter.Sitecode
LEFT JOIN Last_exit_as_of_date
ON Last_exit_as_of_date.Patientpk =
Last_encounter.Patientpk
AND Last_exit_as_of_date.Sitecode =
Last_encounter.Sitecode
LEFT JOIN Patient_art_and_enrollment_info
ON Patient_art_and_enrollment_info.Patientpk =
Last_encounter.Patientpk
AND Patient_art_and_enrollment_info.Sitecode =
Last_encounter.Sitecode
LEFT JOIN Second_last_encounter
ON Second_last_encounter.Patientpk =
Last_encounter.Patientpk
AND Second_last_encounter.Sitecode =
Last_encounter.Sitecode
LEFT JOIN Last_upload_as_of_date
ON Last_upload_as_of_date.Sitecode =
Last_encounter.Sitecode),
Summary
AS (SELECT Artoutcomescompuation.Patientidhash
AS
PatientIDHash,
Artoutcomescompuation.Patientpkhash,
Artoutcomescompuation.Patientid,
Artoutcomescompuation.Patientpk,
Artoutcomescompuation.Sitecode
AS
MFLCode,
Cast (Artoutcomescompuation.Expectedlastencounter AS Date)
AS
ExpectedLastEncounter,
Cast (Artoutcomescompuation.Expectednextappointmentdate AS Date)
AS
ExpectedNextAppointmentDate,
Cast (Artoutcomescompuation.Lastencounterdate AS Date)
AS
LastEncounterDate,
Datediff(Dd, Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate)
AS
DiffExpectedTCADateLastEncounter,
CASE
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) < 0 THEN
'Came before'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) = 0 THEN
'On time'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) BETWEEN 1
AND
7
THEN
'Missed 1-7 days'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) BETWEEN 8
AND
14
THEN
'Missed 8-14 days'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) BETWEEN
15 AND
30
THEN
'Missed 15-30 days'
WHEN Last_upload_as_of_date.Daterecieved <
Artoutcomescompuation.Expectednextappointmentdate THEN
'LostinHMIS'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) BETWEEN
31 AND
60
THEN
'IIT and RTT within 30 days'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) > 60 THEN
'IIT and RTT beyond 30 days'
WHEN Datediff(Day,
Artoutcomescompuation.Expectednextappointmentdate,
Artoutcomescompuation.Lastencounterdate) >= 91
AND Artoutcomescompuation.Expectednextappointmentdate <>
'1900-01-01'
THEN 'Still IIT'
ELSE
CASE
WHEN Last_exit_as_of_date.Exitreason IN
( 'dead', 'Death', 'Died' ) THEN
'Dead'
WHEN Last_exit_as_of_date.Exitreason IN (
'Lost', 'Lost to followup', 'LTFU', 'ltfu'
               ) THEN 'Still IIT'
WHEN Last_exit_as_of_date.Exitreason IN (
'Stopped', 'Stopped Treatment' )
THEN 'Stopped'
WHEN Last_exit_as_of_date.Exitreason IN (
'Transfer', 'Transfer Out', 'transfer_out',
'Transferred out' ) THEN 'Transfer-Out'
WHEN Last_exit_as_of_date.Exitreason NOT IN (
'dead', 'Death', 'Died', 'Lost',
'Lost to followup',
'LTFU',
'ltfu', 'Stopped'
,
'Stopped Treatment',
'Transfer',
'Transfer Out', 'transfer_out',
'Transferred out' )
THEN
'Other'
ELSE Last_exit_as_of_date.Exitreason
END
END
AS
AppointmentStatus,
Artoutcomescompuation.Asofdate,
Artoutcomescompuation.Startartdate,
Artoutcomescompuation.Artdurationmonths,
Last_upload_as_of_date.Daterecieved
FROM   Artoutcomescompuation
LEFT JOIN Last_exit_as_of_date
ON Last_exit_as_of_date.Patientpk =
Artoutcomescompuation.Patientpk
AND Last_exit_as_of_date.Sitecode =
Artoutcomescompuation.Sitecode
LEFT JOIN Last_upload_as_of_date
ON Last_upload_as_of_date.Sitecode =
Artoutcomescompuation.Sitecode
WHERE  Datediff(Mm, Artoutcomescompuation.Nextappointmentdate,
Dateadd(Month, -2, Artoutcomescompuation.Asofdate)) <= 6
)
SELECT *
INTO   Ods.Dbo.[Historicalappointmentstatus]
FROM   Summary
WHERE  Appointmentstatus IN ( 'Came before', 'Dead',
'IIT and RTT beyond 30 days',
'IIT and RTT within 30 days',
'LostinHMIS', 'LTFU', 'Missed 1-7 days',
'Missed 15-30 days',
'Missed 8-14 days', 'On time', 'Still IIT',
'Stopped',
'Transfer-Out' )

FETCH Next FROM Cursor_asofdates INTO @As_of_date
END
--free up objects
--drop table #months
--close cursor_AsOfDates 
--deallocate cursor_AsOfDates 
--truncate table ODS.dbo.[HistoricalAppointmentStatus]
--alter table ODS.dbo.[HistoricalAppointmentStatus] drop column NextappointmentDate