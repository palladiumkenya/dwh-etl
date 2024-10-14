if OBJECT_ID(N'[REPORTING].[dbo].[AggregateDSD]', N'U') is not null
  drop table Reporting.Dbo.Aggregatedsd
go

select distinct
  Mflcode,
  F.Facilityname,
  County,
  Subcounty,
  P.Partnername,
  A.Agencyname,
  Gender,
  Age.Datimagegroup as Agegroup,
  Stabilityassessment,
  Differentiatedcare,
  cast(GETDATE() as date) as Loaddate,
  SUM(Onmmd) as Patients_Onmmd,
  SUM(case when Onmmd = 0 then 1 else 0 end) as Patients_Nonmmd,
  COUNT(Stabilityassessment) as Stability,
  SUM(Pat.Istxcurr) as Txcurr
into Reporting.Dbo.Aggregatedsd
from Ndwh.Dbo.Factart as Art
left join Ndwh.Dbo.Factlatestobs as Lob on Art.Patientkey = Lob.Patientkey
left join Ndwh.Dbo.Dimagegroup as Age on Art.Agegroupkey = Age.Agegroupkey
left join Ndwh.Dbo.Dimfacility as F on Art.Facilitykey = F.Facilitykey
left join Ndwh.Dbo.Dimagency as A on Art.Agencykey = A.Agencykey
left join Ndwh.Dbo.Dimpatient as Pat on Art.Patientkey = Pat.Patientkey
left join Ndwh.Dbo.Dimpartner as P on Art.Partnerkey = P.Partnerkey
where Pat.Istxcurr = 1
group by
  Mflcode,
  F.Facilityname,
  County,
  Subcounty,
  P.Partnername,
  A.Agencyname,
  Gender,
  Age.Datimagegroup,
  Stabilityassessment,
  Differentiatedcare

go
