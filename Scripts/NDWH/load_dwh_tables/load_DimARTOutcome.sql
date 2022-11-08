---DimARTOutcome
with distinct_ARTOutcomes as (
	select 'S' as ARTOutcome
		union all
	select 'D' as ARTOutcome
		union all
	select 'L' as ARTOutcome
		union all
	select 'NV' as ARTOutcome
		union all
	select 'T' as ARTOutcome
		union all
	select 'V' as ARTOutcome
		union all
	select 'NP' as ARTOutcome
		union all
	select'uL' as ARTOutcome
)
insert into dbo.DimARTOutcome
select 
	ARTOutcome,
	case
		when ARTOutcome = 'S' then 'Stopped'
		when ARTOutcome = 'D' then 'Dead'
		when ARTOutcome = 'L' then 'Loss To Follow Up'
		when ARTOutcome = 'NV' then 'No Visit'
		when ARTOutcome = 'T' then 'Transferred Out'
		when ARTOutcome = 'V' then 'Active'
		when ARTOutcome = 'NP' then 'New Patient'
		when ARTOutcome = 'uL' then 'Undocumented Loss'
	end as ARTOutcomeDescription,
	cast(getdate() as date) as LoadDate
 from distinct_ARTOutcomes;