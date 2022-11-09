---DimPartner Load
with source_partner as (
select
	distinct SDP as AgencyName
from HIS_Implementation.dbo.All_EMRSites
)
select 
	source_partner.*,
	cast(getdate() as date) as LoadDate
into dbo.DimPartner
from source_partner;