---- Loads Nishauri Feature Access data from MhealthCentral to ODS
BEGIN MERGE [ODS].[dbo].[Mhealth_Nishauri_Feature_Access] AS a USING (
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
    [DOB] [MaritalStatus],
    [PatientResidentCounty],
    [PatientResidentLocation],
    [PatientResidentSubCounty],
    [PatientResidentSubLocation],
    [PatientResidentVillage],
    [PatientResidentWard],
    [FeatureAccessDate],
    [PKV],
    [FeatureAccess],
    [DOB_Date],
    [FeatureAccessDate_Date]
  FROM
    [MhealthCentral].[dbo].[Nishauri_Feature_Access] (NOLOCK)
) AS b ON (a.[PatientID] = b.[PatientID])
WHEN NOT MATCHED THEN
INSERT
  (
    [UshauriPatientPK],
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
    [FeatureAccess],
    [DOB],
    [FeatureAccessDate]
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
    b.[FeatureAccess],
    b.[FeatureAccessDate],
    b.[DOB_Date],
    b.[FeatureAccessDate_Date]
  )
  WHEN MATCHED THEN
UPDATE
SET
  a.[UshauriPatientPK] = b.[PatientPK],
  a.[PatientPKHash] = b.[PatientPKHash],
  a.[PartnerName] = b.[PartnerName],
  a.[SiteCode] = b.[SiteCode],
  a.[SiteType] = b.[SiteType],
  a.[PatientID] = b.[PatientID],
  a.[PatientIDHash] = b.[PatientIDHash],
  a.[FacilityID] = b.[FacilityID],
  a.[Emr] = b.[Emr],
  a.[Project] = b.[Project],
  a.[FacilityName] = b.[FacilityName],
  a.[Gender] = b.[Gender],
  a.[MaritalStatus] = b.[MaritalStatus],
  a.[PatientResidentCounty] = b.[PatientResidentCounty],
  a.[PatientResidentLocation] = b.[PatientResidentLocation],
  a.[PatientResidentSubCounty] = b.[PatientResidentSubCounty],
  a.[PatientResidentSubLocation] = b.[PatientResidentSubLocation],
  a.[PatientResidentVillage] = b.[PatientResidentVillage],
  a.[PatientResidentWard] = b.[PatientResidentWard],
  a.[PKV] = b.[PKV],
  a.[FeatureAccess] = b.[FeatureAccess],
  a.[DOB] = b.[DOB_Date],
  a.[FeatureAccessDate] = b.[FeatureAccessDate_Date];

END;
