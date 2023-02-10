
BEGIN
    --truncate table [ODS].[dbo].[MNCH_CwcEnrolments]
	MERGE [ODS].[dbo].[MNCH_CwcEnrolments] AS a
			USING(
					SELECT P.id,[PatientIDCWC],[HEIID],[PatientPk],P.[SiteCode],P.[EMR],F.Name FacilityName,[Project],cast([DateExtracted] as date)[DateExtracted]
						  ,[PKV],[MothersPkv],cast([RegistrationAtCWC] as date) [RegistrationAtCWC],cast([RegistrationAtHEI] as date)[RegistrationAtHEI]
						  ,[VisitID],[Gestation],[BirthWeight],[BirthLength],[BirthOrder],[BirthType],[PlaceOfDelivery],[ModeOfDelivery],[SpecialNeeds]
						  ,[SpecialCare],[HEI],[MotherAlive],[MothersCCCNo],[TransferIn],[TransferInDate],[TransferredFrom],[HEIDate],[NVP]
						  ,[BreastFeeding],[ReferredFrom],[ARTMother],[ARTRegimenMother]
						  ,cast([ARTStartDateMother] as date) [ARTStartDateMother]
						  ,[Date_Created]
						  ,[Date_Last_Modified],
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(p.[PatientPk]  as nvarchar(36))), 2) PatientPKHash, 
					  convert(nvarchar(64), hashbytes('SHA2_256', cast(PKV  as nvarchar(36))), 2)PKVHash,
					   convert(nvarchar(64), hashbytes('SHA2_256', cast(MothersPkv  as nvarchar(36))), 2)MothersPkvHash

					  FROM [MNCHCentral].[dbo].[CwcEnrolments]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities]F on F.Id=P.FacilityId ) AS b 
						ON(
						--a.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS = b.PatientID COLLATE SQL_Latin1_General_CP1_CI_AS and
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID COLLATE SQL_Latin1_General_CP1_CI_AS = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(id,PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified,PatientPKHash,PKVHash,MothersPkvHash) 
						VALUES(id,PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified,PatientPKHash,PKVHash,MothersPkvHash)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PlaceOfDelivery	 =b.PlaceOfDelivery;
END

