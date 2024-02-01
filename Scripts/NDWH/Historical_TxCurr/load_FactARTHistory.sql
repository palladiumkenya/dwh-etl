BEGIN
    INSERT INTO [NDWH].[dbo].[factarthistory]
                ([facilitykey],
                 [partnerkey],
                 [agencykey],
                 [patientkey],
                 [asofdatekey],
                 [istxcurr],
                 [artoutcomekey],
                 [nextappointmentdate],
                 [lastencounterdate],
                 [loaddate],
                 datetimestamp)
    SELECT [facilitykey],
           [partnerkey],
           [agencykey],
           [patientkey],
           [asofdatekey] [AsOfDateKey],
           artoutcomekey,
           [artoutcomekey],
           [nextappointmentdate],
           lastvisitdate,
           [loaddate],
           Getdate()     AS DateTimeStamp
    FROM   [NDWH].[dbo].[factart]
END 