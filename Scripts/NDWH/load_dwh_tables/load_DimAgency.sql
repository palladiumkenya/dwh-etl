--DimAgency Load
with source_agency as (
select 
	distinct [SDP Agency] as PartnerName
from HIS_Implementation.dbo.All_EMRSites
where [SDP Agency] <> 'NULL'
)
insert into dbo.DimAgency
select
 source_agency.*,
 cast(getdate() as date) as LoadDate
from source_agency;