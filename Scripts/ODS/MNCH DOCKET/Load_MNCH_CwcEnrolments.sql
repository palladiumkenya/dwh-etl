
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
						  ,[Date_Last_Modified]

					  FROM [MNCHCentral].[dbo].[CwcEnrolments]P
					  INNER JOIN [MNCHCentral].[dbo].[Facilities]F on F.Id=P.FacilityId ) AS b 
						ON(
						 a.PatientPK  = b.PatientPK 
						and a.SiteCode = b.SiteCode
						and a.ID  = b.ID
							)
					WHEN NOT MATCHED THEN 
						INSERT(id,PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified) 
						VALUES(id,PatientIDCWC,HEIID,PatientPk,SiteCode,EMR,FacilityName,Project,DateExtracted,PKV,MothersPkv,RegistrationAtCWC,RegistrationAtHEI,VisitID,Gestation,BirthWeight,BirthLength,BirthOrder,BirthType,PlaceOfDelivery,ModeOfDelivery,SpecialNeeds,SpecialCare,HEI,MotherAlive,MothersCCCNo,TransferIn,TransferInDate,TransferredFrom,HEIDate,NVP,BreastFeeding,ReferredFrom,ARTMother,ARTRegimenMother,ARTStartDateMother,Date_Created,Date_Last_Modified)
				
					WHEN MATCHED THEN
						UPDATE SET 
							a.PlaceOfDelivery	 =b.PlaceOfDelivery;
END

