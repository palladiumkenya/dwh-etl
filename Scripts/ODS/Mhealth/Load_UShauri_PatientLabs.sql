---- Loads data from MhealthCentral to ODS
BEGIN

  MERGE [ODS].[dbo].[Ushauri_PatientLabs] AS a
  USING (
    SELECT DISTINCT [PatientPK], [PatientPKHash], [PatientID], [PatientIDHash], [SiteCode], [FacilityName], [OrderedbyDate], [ReportedbyDate], [TestName], [TestResult], [Units], [LabName]
    FROM [MhealthCentral].[dbo].[CT_PatientLabs] (NOLOCK)
  ) AS b
  ON (a.[PatientID] = b.[PatientID])
  WHEN NOT MATCHED THEN
    INSERT ([Ushauri_PatientPK], [PatientPKHash], [PatientID], [PatientIDHash], [SiteCode], [FacilityName], [OrderedbyDate], [ReportedbyDate], [TestName], [TestResult], [Units], [LabName])
    VALUES (b.[PatientPK], b.[PatientPKHash], b.[PatientID], b.[PatientIDHash], b.[SiteCode], b.[FacilityName], b.[OrderedbyDate], b.[ReportedbyDate], b.[TestName], b.[TestResult], b.[Units], b.[LabName])
    WHEN MATCHED THEN
    UPDATE
    SET
      a.[PatientPKHash] = b.[PatientPKHash],
      a.[PatientIDHash] = b.[PatientIDHash],
      a.[SiteCode] = b.[SiteCode],
      a.[FacilityName] = b.[FacilityName],
      a.[OrderedbyDate] = b.[OrderedbyDate],
      a.[ReportedbyDate] = b.[ReportedbyDate],
      a.[TestName] = b.[TestName],
      a.[TestResult] = b.[TestResult],
      a.[Units] = b.[Units],
      a.[LabName] = b.[LabName],
      a.[Ushauri_PatientPK] = b.[PatientPK];

END;
