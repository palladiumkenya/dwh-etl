UPDATE a
    SET Voided = 0             
    from [ODS].[dbo].[MNCH_Patient] a
WHERE Voided is null
GO