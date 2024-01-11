-- clean TraceOutcome

UPDATE [ODS].[dbo].[HTS_PartnerTracings]
    SET TraceOutcome = NULL
WHERE TraceOutcome = 'null'