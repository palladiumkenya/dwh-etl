if object_id(N'REPORTING.dbo.all_EMRSites', N'U') is not NULL
  drop table reporting.dbo.all_emrsites;


with modulesuptake as (
  select
    fac.mflcode,
    fac.facilityname,
    fac.subcounty,
    fac.county,
    fac.isemrsite,
    pat.partnername,
    agency.agencyname,
    modules.isct,
    modules.ishts,
    modules.ishtsml,
    modules.isiitml,
    modules.isotz,
    modules.isovc,
    modules.ispmtct,
    modules.isprep,
    fac.latitude,
    fac.longitude,
    fac.emr_status,
    modules.emr,
    modules.owner,
    modules.infrastructuretype,
    modules.keph_level,
    cast(getdate() as date) as loaddate
  from ndwh.dbo.factmodulesuptake as modules
  left join ndwh.dbo.dimfacility as fac on modules.facilitykey = fac.facilitykey
  left join ndwh.dbo.dimpartner as pat on modules.partnerkey = pat.partnerkey
  left join ndwh.dbo.dimagency as agency on modules.agencykey = agency.agencykey
)

select *
into reporting.dbo.all_emrsites
from modulesuptake;
