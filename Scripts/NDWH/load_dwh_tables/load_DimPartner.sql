---DimPartner Load
with source_partner as (
select
	distinct SDP as AgencyName
from HIS_Implementation.dbo.All_EMRSites
)
insert into dbo.DimPartner
select 
	source_partner.*,
	cast(getdate() as date) as LoadDate
from source_partner;