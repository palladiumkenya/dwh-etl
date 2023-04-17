-- clean DateOfLastPrepDose
UPDATE ODS.dbo.PrEP_CareTermination
    SET DateOfLastPrepDose = NULL
WHERE DateOfLastPrepDose = ''

GO

-- clean ExitReason
UPDATE ODS.dbo.PrEP_CareTermination
    SET ExitReason = NULL
WHERE ExitReason = ''

GO
