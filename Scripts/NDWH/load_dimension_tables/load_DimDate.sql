---DimDate Load
--- This is just loaded once for dates from 1900 to 2100

declare @sdate date = '1900-01-01', @edate date = '2100-12-31';

with dates_cte(date) as (
    select @sdate 
		union all
    select dateadd(day, 1, date)
    from dates_cte
    where date < @edate
)
select 
	isnull(format(date, 'yyyyMMdd'), '') as DateKey,
	Date,
	year(date) as Year,
	month(date) Month,
	datepart(quarter, date) as CalendarQuarter,
	case 
		when month(date) between 10 and 12 then 1
		when month(date) between 1 and 3 then 2
		when month(date) between 4 and 6 then 3
		when month(date) between 7 and 9 then 4
	end as CDCFinancialQuarter,
	cast(getdate() as date) as LoadDate
into dbo.DimDate
from dates_CTE
option (maxrecursion 0);
ALTER TABLE dbo.DimDate ADD PRIMARY KEY(DateKey);