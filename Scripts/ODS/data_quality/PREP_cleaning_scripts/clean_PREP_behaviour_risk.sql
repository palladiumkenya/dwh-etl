-- clean NumberofchildrenWithPartner
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET NumberofchildrenWithPartner = NULL
WHERE NumberofchildrenWithPartner = ''

GO

-- clean SexWithoutCondom
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET SexWithoutCondom = NULL
WHERE SexWithoutCondom = ''

GO

-- clean MonthsknownHIVSerodiscordant
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET MonthsknownHIVSerodiscordant = NULL
WHERE MonthsknownHIVSerodiscordant = ''

GO

--clean HIVPartnerARTStartDate
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET HIVPartnerARTStartDate = NULL
WHERE HIVPartnerARTStartDate = ''

GO

-- clean PartnerEnrolledtoCCC
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET PartnerEnrolledtoCCC = NULL
WHERE PartnerEnrolledtoCCC = ''

GO

-- clean ReferralToOtherPrevServices
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET ReferralToOtherPrevServices = NULL
WHERE ReferralToOtherPrevServices = ''

GO

-- clean RiskReductionEducationOffered
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET RiskReductionEducationOffered = NULL
WHERE RiskReductionEducationOffered = ''

GO

-- clean PrEPDeclineReason
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET PrEPDeclineReason = NULL
WHERE PrEPDeclineReason = ''

GO

-- clean ClientWillingToTakePrep
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET ClientWillingToTakePrep = NULL
WHERE ClientWillingToTakePrep = ''

GO

-- clean ClientRisk
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET ClientRisk = NULL
WHERE ClientRisk = ''

GO


-- clean ClientAssessments
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET ClientRisk = NULL
WHERE ClientRisk = ''

GO


-- clean IsPartnerHighrisk
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET IsPartnerHighrisk = NULL
WHERE IsPartnerHighrisk = ''

GO

-- clean IsHIVPositivePartnerCurrentonART
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET IsHIVPositivePartnerCurrentonART = NULL
WHERE IsHIVPositivePartnerCurrentonART = ''

GO

-- clean SexPartnerHIVStatus
UPDATE ODS.dbo.PrEP_BehaviourRisk
    SET SexPartnerHIVStatus = NULL
WHERE SexPartnerHIVStatus = ''

GO