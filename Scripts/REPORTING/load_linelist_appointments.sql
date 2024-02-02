TRUNCATE TABLE [REPORTING].[dbo].linelistappointments;

INSERT INTO [REPORTING].[dbo].linelistappointments
            (patientidhash,
             patientpkhash,
             nupi,
             dob,
             maritalstatus,
             mflcode,
             facilityname,
             subcounty,
             county,
             partnername,
             agencyname,
             gender,
             expectednextappointmentdate,
             lastencounterdate,
             diffexpectedtcadatelastencounter,
             appointmentstatus,
             asofdate,
             datimagegroup,
             latestdsdmodel,
             loaddate)
SELECT Patient.patientidhash,
       Patient.patientpkhash,
       Patient.nupi,
       Patient.dob,
       Patient.maritalstatus,
       facility.mflcode,
       facility.facilityname,
       facility.subcounty,
       facility.county,
       partner.partnername,
       agency.agencyname,
       patient.gender,
       expectednextappointmentdate,
       lastencounterdate,
       diffexpectedtcadatelastencounter,
       apt.appointmentstatus,
       apt.asofdate,
       age_group.datimagegroup,
       NULL                    LatestDSDModel,
       --dsd_models.DifferentiatedCare as LatestDSDModel,
       Cast(Getdate() AS DATE) AS LoadDate
FROM   ndwh.dbo.factappointments(nolock) AS apt
       LEFT JOIN ndwh.dbo.dimfacility(nolock) AS facility
              ON facility.facilitykey = apt.facilitykey
       LEFT JOIN ndwh.dbo.dimpartner(nolock) AS partner
              ON partner.partnerkey = apt.partnerkey
       LEFT JOIN ndwh.dbo.dimpatient(nolock) AS patient
              ON patient.patientkey = apt.patientkey
       LEFT JOIN ndwh.dbo.dimagency(nolock) AS agency
              ON agency.agencykey = apt.agencykey
       LEFT JOIN ndwh.dbo.dimagegroup(nolock) AS age_group
              ON age_group.agegroupkey = Datediff(yy, patient.dob, apt.asofdate)
--left join dsd_models on dsd_models.PatientKey = apt.PatientKey
WHERE  asofdate >= '2017-01-31' 