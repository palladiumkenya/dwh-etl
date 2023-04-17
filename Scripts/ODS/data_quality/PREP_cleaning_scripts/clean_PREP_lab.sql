-- clean Reason
UPDATE ODS.dbo.PrEP_Lab
    SET Reason = NULL
WHERE Reason = ''

GO

-- clean SampleDate
UPDATE ODS.dbo.PrEP_Lab
    SET SampleDate = NULL
WHERE SampleDate = ''

GO