---- Loads Nishauri Profile data from MhealthCentral to ODS
BEGIN MERGE [ODS].[dbo].[Mhealth_Nishauri_Profile] AS a USING (
  SELECT
    DISTINCT [PatientPK],
    [PatientPKHash],
    [PartnerName],
    [SiteCode],
    [SiteType],
    [PatientID],
    [PatientIDHash],
    [FacilityID],
    [Emr],
    [Project],
    [FacilityName],
    [Gender],
    [MaritalStatus],
    [PatientResidentCounty],
    [PatientResidentLocation],
    [PatientResidentSubCounty],
    [PatientResidentSubLocation],
    [PatientResidentVillage],
    [PatientResidentWard],
    [PKV],
    [DOB_Date],
    [DateCreated_Date]
  FROM
    [MhealthCentral].[dbo].[Nishauri_Profile] (NOLOCK)
) AS b ON (a.[PatientID] = b.[PatientID])
WHEN NOT MATCHED THEN
INSERT
  (
    [Ushauri_PatientPK],
    [PatientPKHash],
    [PartnerName],
    [SiteCode],
    [SiteType],
    [PatientID],
    [PatientIDHash],
    [FacilityID],
    [Emr],
    [Project],
    [FacilityName],
    [Gender],
    [MaritalStatus],
    [PatientResidentCounty],
    [PatientResidentLocation],
    [PatientResidentSubCounty],
    [PatientResidentSubLocation],
    [PatientResidentVillage],
    [PatientResidentWard],
    [PKV],
    [DOB],
    [DateCreated],
    [LoadDate]
  )
VALUES
  (
    b.[PatientPK],
    b.[PatientPKHash],
    b.[PartnerName],
    b.[SiteCode],
    b.[SiteType],
    b.[PatientID],
    b.[PatientIDHash],
    b.[FacilityID],
    b.[Emr],
    b.[Project],
    b.[FacilityName],
    b.[Gender],
    b.[MaritalStatus],
    b.[PatientResidentCounty],
    b.[PatientResidentLocation],
    b.[PatientResidentSubCounty],
    b.[PatientResidentSubLocation],
    b.[PatientResidentVillage],
    b.[PatientResidentWard],
    b.[PKV],
    b.[DOB_Date],
    b.[DateCreated_Date],
    Getdate()
  )
  WHEN MATCHED THEN
UPDATE
SET
  a.[Ushauri_PatientPK] = b.[PatientPK],
  a.[PatientPKHash] = b.[PatientPKHash],
  a.[PartnerName] = b.[PartnerName],
  a.[SiteCode] = b.[SiteCode],
  a.[SiteType] = b.[SiteType],
  a.[FacilityID] = b.[FacilityID],
  a.[Emr] = b.[Emr],
  a.[Project] = b.[Project],
  a.[FacilityName] = b.[FacilityName],
  a.[Gender] = b.[Gender],
  a.[MaritalStatus] = b.[MaritalStatus],
  a.[PatientResidentCounty] = b.[PatientResidentCounty],
  a.[PatientResidentLocation] = b.[PatientResidentLocation],
  a.[PatientResidentSubCounty] = b.[PatientResidentSubCount],
  a.[PatientResidentSubLocation] = b.[PatientResidentSubLocation],
  a.[PatientResidentVillage] = b.[PatientResidentVillage],
  a.[PatientResidentWard] = b.[PatientResidentWard],
  a.[PKV] = b.[PKV],
  a.[DOB] = b.[DOB_Date],
  a.[DateCreated] = b.[DateCreated_Date];

END
