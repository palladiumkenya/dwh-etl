if object_id(N'[REPORTING].[dbo].[AggregateDSD]', N'U') is not null
  drop table reporting.dbo.aggregatedsd
go

select distinct
  f.mflcode,
  f.facilityname,
  f.county,
  f.subcounty,
  p.partnername,
  a.agencyname,
  pat.gender,
  age.datimagegroup as agegroup,
  art.stabilityassessment,
  art.differentiatedcare,
  cast(getdate() as date) as loaddate,
  sum(art.onmmd) as patients_onmmd,
  sum(case when art.onmmd = 0 then 1 else 0 end) as patients_nonmmd,
  count(art.stabilityassessment) as stability,
  sum(pat.istxcurr) as txcurr
into reporting.dbo.aggregatedsd
from ndwh.dbo.factart as art
left join ndwh.dbo.factlatestobs as lob on art.patientkey = lob.patientkey
left join ndwh.dbo.dimagegroup as age on art.agegroupkey = age.agegroupkey
left join ndwh.dbo.dimfacility as f on art.facilitykey = f.facilitykey
left join ndwh.dbo.dimagency as a on art.agencykey = a.agencykey
left join ndwh.dbo.dimpatient as pat on art.patientkey = pat.patientkey
left join ndwh.dbo.dimpartner as p on art.partnerkey = p.partnerkey
where pat.istxcurr = 1
group by
  f.mflcode,
  f.facilityname,
  f.county,
  f.subcounty,
  p.partnername,
  a.agencyname,
  pat.gender,
  age.datimagegroup,
  art.stabilityassessment,
  art.differentiatedcare
go
