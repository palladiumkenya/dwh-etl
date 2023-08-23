IF OBJECT_ID(N'[NDWH].[dbo].[FactHTSEligibilityextract]', N'U') IS NOT NULL 
	DROP TABLE [NDWH].[dbo].[FactHTSEligibilityextract];

BEGIN

    with MFL_partner_agency_combination as (
        select 
            distinct MFL_Code,
            SDP,
            SDP_Agency  as Agency
        from ODS.dbo.All_EMRSites 
    ),
    source_data as (
        select 
            PatientPKHash,
            SiteCode,
            EncounterId,
            VisitID,
            Department,
            IsHealthWorker,
            RelationshipWithContact,
            TestedHIVBefore,
            WhoPErformedTest,
            ResultOfHIV,
            cast(VisitDate as date) as VisitDate,
            cast (DateTestedSelf as date) As DateTestedSelf,
            StartedOnART,
            CONVERT(NVARCHAR(64), HASHBYTES('SHA2_256', CAST(CCCNumber as NVARCHAR(36))), 2) As CCCNumber,
            EverHadSex,
            SexuallyActive,
            NewPartner,
            PartnerHIVStatus,
            CoupleDiscordant,
            MultiplePartners,
            NumberOfPartners,
            AlcoholSex,
            MoneySex,
            CondomBurst,
            UnknownStatusPartner,
            KnownStatusPartner,
            Pregnant,
            BreastfeedingMother,
            ExperiencedGBV,
            ContactWithTBCase,
            Lethargy,
            EverOnPrep,
            CurrentlyOnPep,
            EverHadSTI,
            CurrentlyHasSTI,
            EverHadTB,
            SharedNeedle,
            NeedleStickInjuries,
            TraditionalProcedures,
            ChildReasonsForIneligibility,
            EligibleForTest,
            ReasonsforIneligibility,
            specificReasonForIneligibility,
            Cough,
            cast (DateTestedProvider as date) As DateTestedProvider,
            Fever,
            MothersStatus,
            NightSweats,
            ReferredForTesting,
            ResultOfHIVSelf,
            ScreenedTB,
            TBStatus,
            WeightLoss,
            AssessmentOutcome,
            ForcedSex,
            ReceivedServices,
            TypeGBV,
			HIVRiskCategory,
			HtsRiskScore
        from ODS.dbo.HTS_EligibilityExtract
    )
    select 
        Factkey = IDENTITY(INT, 1, 1),
		source_data.*,
        patient.PatientKey,
        facility.FacilityKey,
        partner.PartnerKey,
        agency.AgencyKey,
        VisitDate.DateKey As VisitDateKey,
        DateTestedSelf.DateKey as DateTestedSelfKey,
        cast(getdate() as date) as LoadDate
    into NDWH.dbo.FactHTSEligibilityextract
    from source_data
    left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = convert(nvarchar(64), hashbytes('SHA2_256', cast(source_data.PatientPK as nvarchar(36))), 2)
        and patient.SiteCode = source_data.SiteCode
    left join NDWH.dbo.DimFacility as facility on facility.MFLCode = source_data.SiteCode
    left join MFL_partner_agency_combination on MFL_partner_agency_combination.MFL_Code = source_data.SiteCode
    left join NDWH.dbo.DimPartner as partner on partner.PartnerName = MFL_partner_agency_combination.SDP
    left join NDWH.dbo.DimAgency as agency on agency.AgencyName = MFL_partner_agency_combination.Agency
    left join NDWH.dbo.DimDate as VisitDate on VisitDate.Date = source_data.VisitDate
    left join NDWH.dbo.DimDate as DateTestedSelf on DateTestedSelf.Date = source_data.DateTestedSelf
    left join NDWH.dbo.DimDate as DateTestedProvider on DateTestedProvider.Date = source_data.DateTestedProvider
    left join NDWH.dbo.DimPatient as patient on patient.PatientPKHash = source_data.PatientPKHash
        and patient.SiteCode = source_data.SiteCode



    alter table NDWH.dbo.FactHTSEligibilityextract add primary key(FactKey);

END