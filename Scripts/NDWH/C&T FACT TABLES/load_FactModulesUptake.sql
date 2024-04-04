If Object_id(N'[NDWH].[dbo].[FactModulesuptake]', N'U') Is Not Null
  Drop Table [Ndwh].[Dbo].[FactModulesuptake];

Begin
    With Sites
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Mfl_code) EMRSites
             From   Ods.Dbo.All_emrsites
             Where  Emr_status = 'Active'
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Otz
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Sitecode) OTZ
             From   Ods.Dbo.Ct_otz Otz
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Otz.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Ovc
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Sitecode) OVC
             From   Ods.Dbo.Ct_ovc Ovc
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Ovc.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Hts
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Sitecode) HTS
             From   Ods.Dbo.Hts_clienttests Tests
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Tests.Sitecode
             Where  Datediff(Month, Testdate, Eomonth(Dateadd(Mm, -1, Getdate())
                                              ))
                    <= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Prep
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Prep.Sitecode) Prep
             From   Ods.Dbo.Prep_visits Prep
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Prep.Sitecode
                    Full Join Ods.Dbo.Prep_behaviourrisk Beha
                           On Beha.Sitecode = Prep.Sitecode
             Where  Datediff(Month, Prep.Visitdate, Eomonth( Dateadd(Mm, -1, Getdate()))) <= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
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
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count(Distinct Sitecode) As PMTCT
             From   Combined_dataset
                    Left Join Ods.Dbo.All_emrsites As Sites
                           On Sites.Mfl_code = Combined_dataset.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth(Dateadd(Mm, -1, Getdate())))<= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Iit
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Sitecode) IIT
             From   Ods.Dbo.Ct_iitriskscores Iit
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Iit.Sitecode
             Where  Datediff(Month, Riskevaluationdate, Eomonth(Dateadd(Mm, -1, Getdate()))) <= 12
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Htsml
         As (Select Sdp,
                    Sdp_agency,
                    County,
                    Count (Distinct Sitecode) HTSML
             From   Ods.Dbo.Hts_eligibilityextract Htsml
                    Left Join Ods.Dbo.All_emrsites Emr
                           On Emr.Mfl_code = Htsml.Sitecode
             Where  Datediff(Month, Visitdate, Eomonth( Dateadd(Mm, -1, Getdate())))  <= 12 and HIVRiskCategory is not null
             Group  By Sdp,
                       Sdp_agency,
                       County),
         Summary
         As (Select Sites.Sdp,
                    Sites.Sdp_agency,
                    Sites.County,
                    Emrsites,
                    Coalesce (Otz, 0)   As OTZ,
                    Coalesce (Ovc, 0)   As OVC,
                    Coalesce (Hts, 0)   As HTS,
                    Coalesce (Prep, 0)  As Prep,
                    Coalesce (Pmtct, 0) As PMTCT,
                    Coalesce (Iit, 0)   As IIT,
                    Coalesce (Htsml, 0) As HTSML
             From   Sites
                    Left Join Otz
                           On Otz.Sdp = Sites.Sdp
                              And Otz.Sdp_agency = Sites.Sdp_agency
                              And Otz.County=Sites.County
                    Left Join Ovc
                           On Ovc.Sdp = Sites.Sdp
                              And Ovc.Sdp_agency = Sites.Sdp_agency
                              And Ovc.County=Sites.County
                    Left Join Hts
                           On Hts.Sdp = Sites.Sdp
                              And Hts.Sdp_agency = Sites.Sdp_agency
                              And Hts.County=Sites.County
                    Left Join Prep
                           On Prep.Sdp = Sites.Sdp
                              And Prep.Sdp_agency = Sites.Sdp_agency
                              And Prep.County=Sites.County
                    Left Join Pmtct
                           On Pmtct.Sdp = Sites.Sdp
                              And Pmtct.Sdp_agency = Sites.Sdp_agency
                              And Pmtct.County=Sites.County
                    Left Join Iit
                           On Iit.Sdp = Sites.Sdp
                              And Iit.Sdp_agency = Sites.Sdp_agency
                              And Iit.County=Sites.County
                    Left Join Htsml
                           On Htsml.Sdp = Sites.Sdp
                              And Htsml.Sdp_agency = Sites.Sdp_agency
                              And Htsml.County=Sites.County)
    Select Factkey = Identity(Int, 1, 1),
           Partner.Partnerkey,
           Agency.Agencykey,
           EMRSites,
           County,
           Otz,
           Ovc,
           Hts,
           Prep,
           Pmtct,
           Iit,
           Htsml
    Into   Ndwh.Dbo.FactModulesuptake
    From   Summary
           Left Join Ndwh.Dbo.Dimpartner As Partner
                  On Partner.Partnername = Summary.Sdp
           Left Join Ndwh.Dbo.Dimagency As Agency
                  On Agency.Agencyname = Summary.Sdp_agency
          

    Alter Table Ndwh.Dbo.FactModulesuptake Add Primary Key(Factkey);
End 

