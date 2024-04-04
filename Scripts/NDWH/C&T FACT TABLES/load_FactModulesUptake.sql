If Object_id(N'[NDWH].[dbo].[FactModulesuptake]', N'U') Is Not Null
  Drop Table [Ndwh].[Dbo].[FactModulesuptake];

Begin
    With Sites
         As (Select 
         distinct  Mfl_code ,
                   Sdp,
                    Sdp_agency,
                    County,
                    Subcounty,
                    case when Mfl_code is not null then 1 Else 0 End as isEMRSite
             From   Ods.Dbo.All_emrsites
             Where  Emr_status = 'Active'
             ),
         Otz
         As (Select 
                   Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOTZ,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Ct_otz Otz
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Otz.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
            ),
         Ovc
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isOVC,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Ct_ovc Ovc
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Ovc.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Hts
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTS,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Hts_clienttests Tests
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Tests.Sitecode
             Where  Datediff(Month, Testdate, Eomonth(Dateadd(Mm, -1, Getdate())
                                              )) <= 12
            ),
         Prep
         As (Select 
                  Distinct prep.Sitecode,
                  case when prep.SiteCode is not null then 1 Else 0 End as isPrep,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Prep_visits Prep
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Prep.Sitecode
                    Full Join Ods.Dbo.Prep_behaviourrisk Beha
                           On Beha.Sitecode = Prep.Sitecode
             Where  Datediff(Month, Prep.Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Combined_dataset
         As (Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_ancvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_matvisits
             Union
             Select Patientpkhash,
                    Sitecode,
                    Visitdate
             From   Ods.Dbo.Mnch_pncvisits),
         Pmtct
         As (Select 
                 Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isPMTCT,
                  Sdp,
                  Sdp_agency,
                  County
             From   Combined_dataset
                    Left Join Ods.Dbo.All_emrsites As Sites
                           On Sites.Mfl_code = Combined_dataset.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
             ),
         Iit
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isIITML,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Ct_iitriskscores Iit
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Iit.Sitecode
             Where  Datediff(Month, Riskevaluationdate, Eomonth(Dateadd(Mm, -1, Getdate()))) <= 12
             ),
         Htsml
         As (Select 
                  Distinct Sitecode,
                  case when Sitecode is not null then 1 Else 0 End as isHTSML,
                  Sdp,
                  Sdp_agency,
                  County
             From   Ods.Dbo.Hts_eligibilityextract Htsml
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Htsml.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate())))  <= 12 and HIVRiskCategory is not null
             ),
         Summary
         As (Select 
                    Mfl_code ,
                    sites.Sdp,
                    sites.SDP_Agency,
                    sites.County,
                    Subcounty,
                    coalesce (isEMRSite,0) as isEMRSite,
                    coalesce (isOTZ,0) as isOTZ,
                    coalesce (isOVC,0) as isOVC,
                    coalesce (isHTS,0) as isHTS,
                    coalesce (isPrep,0) as isPrep,
                    coalesce (isPMTCT,0) as isPMTCT,
                    coalesce (isIITML,0) as isIITML,
                    coalesce (isHTSML,0) as isHTSML
             From   Sites
                    Left Join Otz
                           On Otz.SiteCode = Sites.MFL_Code
                           and Otz.SDP=Sites.SDP
                    Left Join Ovc
                           On Ovc.SiteCode = Sites.MFL_Code  
                            and Ovc.SDP=Sites.SDP  
                    Left Join Hts
                           On Hts.SiteCode = Sites.MFL_Code
                            and Hts.SDP=Sites.SDP
                    Left Join Prep
                           On Prep.SiteCode = Sites.MFL_Code
                            and Prep.SDP=Sites.SDP
                    Left Join Pmtct
                           On Pmtct.SiteCode = Sites.MFL_Code
                            and Pmtct.SDP=Sites.SDP
                    Left Join Iit
                           On Iit.SiteCode = Sites.MFL_Code
                            and Iit.SDP=Sites.SDP
                    Left Join Htsml
                           On Htsml.SiteCode = Sites.MFL_Code
                            and Htsml.SDP=Sites.SDP
                              )
    Select 
           Factkey = Identity(Int, 1, 1),
           Partner.Partnerkey,
           Agency.Agencykey,
           fac.FacilityKey,
           isEMRSite,
           Summary.isHTS,
           isHTSML,
           isIITML,
           isOTZ,
           isOVC,
           isPMTCT,
           isPrep
    Into   Ndwh.Dbo.FactModulesuptake
    From   Summary
           Left join NDWH.dbo.DimFacility as fac on fac.MFLCode=Summary.MFL_Code
           Left Join Ndwh.Dbo.Dimpartner As Partner
                  On Partner.Partnername = Summary.Sdp
           Left Join Ndwh.Dbo.Dimagency As Agency
                  On Agency.Agencyname = Summary.Sdp_agency
          

    Alter Table Ndwh.Dbo.FactModulesuptake Add Primary Key(Factkey);
End 

