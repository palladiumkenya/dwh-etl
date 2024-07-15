TRUNCATE TABLE ndwh.dbo.FactViralLoad_Hist;

DECLARE @start_date DATE;

SELECT @start_date = dateadd(month, -12, eomonth(dateadd(month, -2, getdate())));

DECLARE @end_date DATE;

SELECT @end_date = eomonth(dateadd(month, -2, getdate()));

--- create a temp table to store end of month for each month
with dates as (     
				SELECT datefromparts(year(@start_date), month(@start_date), 1) as dte
				UNION ALL
				SELECT dateadd(month, 1, dte) --incrementing month by month until the date is less than or equal to @end_date
				FROM dates
				WHERE dateadd(month, 1, dte) <= @end_date
			)
SELECT 
	eomonth(dte) as end_date
INTO #months
FROM dates
OPTION (maxrecursion 0);   

--declare as of date
DECLARE @as_of_date As DATE;

--declare cursor
DECLARE cursor_AsOfDates CURSOR FOR
SELECT * FROM #months

OPEN cursor_AsOfDates

FETCH NEXT FROM cursor_AsOfDates INTO @as_of_date
WHILE @@FETCH_STATUS = 0

BEGIN
WITH viralLoad As (
					SELECT	DISTINCT	
					Labs.PatientPk,
					Labs.SiteCode,
					VisitID,
					art.StartARTDate,
					[OrderedbyDate],
					[ReportedbyDate],
					Patient.DOB,
					AgeAsOfDate = Datediff(year,Patient.DOB,@as_of_date),
					[TestName],
					TestResult,
					Labs.[Emr],
					Labs.[Project],
					CASE 
						WHEN datediff(month,art.StartARTDate, @as_of_date) >=3 THEN 1  
						WHEN DATEDIFF(MONTH, art.StartARTDate, @as_of_date) <3 THEN 0
					END As EligibleVL,
					CASE 
						WHEN datediff(month,[OrderedbyDate],@as_of_date) <= 6 and  Datediff(year,Patient.DOB,@as_of_date) <= 24 THEN 1
						WHEN datediff(month,[OrderedbyDate],@as_of_date) <= 12 and  Datediff(year,Patient.DOB,@as_of_date) > 24 THEN 1 
						ELSE 0
					END As IsValidVL,
					CASE 
						WHEN IsNumeric([TestResult]) = 1 THEN 
																CASE 
																	WHEN cast(replace([TestResult], ',', '') as  float) < 200.00 THEN 1 
																	ELSE 0 
																END 
						ELSE 
							CASE 
								WHEN [TestResult]  in ('undetectable','NOT DETECTED','0 copies/ml','LDL','Less than Low Detectable Level') THEN 1 
								ELSE 0 
							END  
					END as VLSup,
					@as_of_date As AsOfDate,
					getdate() As LoadDate
					---into  ndwh.dbo.FactViralLoad_Hist
			FROM  ODS.dbo.CT_ARTPatients art 
			join ODS.dbo.CT_PatientLabs Labs    ---Visits to know whether the the pregnant or not(Pbfw)
			ON	art.PatientPK = labs.Patientpk and
				art.SiteCode = labs.SiteCode
			Left join ODS.dbo.CT_patient  patient
			on art.PatientPK = patient.Patientpk and
				art.SiteCode = patient.SiteCode

			where TestName = 'Viral Load'
					and TestName <>'CholesterolLDL (mmol/L)' and TestName <> 'Hepatitis C viral load' 
					and TestResult is not null 
					and Labs.SiteCode =12601 and art.PatientPK = 10 
					and [OrderedbyDate] <= @as_of_date
				),

Visits As(

select	Visits.SiteCode,
		Visits.PatientPK,
		VisitDate,Pregnant,
		Breastfeeding,
		NextAppointmentDate ,
		@as_of_date As AsOfDate
		from ODS.DBO.CT_PatientVisits Visits
		join viralLoad 
		on  Visits.SiteCode = viralLoad.Sitecode and Visits.PatientPK = viralLoad.PatientPK
where Visits.VisitDate <= @as_of_date and  Visits.SiteCode =12601 and Visits.PatientPK = 10

),

MaxVisitsByAsOf As (
   select 
   row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by VisitDate desc) as rank, 
   SiteCode,
   PatientPK,
   VisitDate,
   AsOfDate,
   NextAppointmentDate,
   Pregnant,
   Breastfeeding
   from Visits
),
RankMaxVisitDateAsOf As(
select SiteCode,PatientPK, VisitDate,Pregnant,Breastfeeding,NextAppointmentDate,AsOfDate
from MaxVisitsByAsOf
where rank =1


),

MaxOrderedbyDateByAsOfDate As (
                     select 
						row_number() over(partition by  SiteCode, PatientPK,AsOfDate order by [OrderedbyDate] desc) as rank, 
						SiteCode,
						PatientPK,
						StartARTDate,
						DOB,
						AgeAsOfDate,
						[OrderedbyDate],
						[ReportedbyDate],
						EligibleVL,
						IsValidVL,
						VLSup,
						AsOfDate,
						[TestName],
						TestResult,
						[Emr],
						[Project]
					from viralLoad
					where [OrderedbyDate] <= AsOfDate

			),
MaxOrderedbyDateByAsOfDate_Final As (
select SiteCode,PatientPK,StartARTDate,DOB,AgeAsOfDate,OrderedbyDate,ReportedbyDate,EligibleVL,IsValidVL,VLSup,AsOfDate,TestName,TestResult,Emr,Project 
from MaxOrderedbyDateByAsOfDate
where rank =1

),
Combined As(
 Select OrderedFinal.SiteCode,OrderedFinal.PatientPK,StartARTDate,DOB,AgeAsOfDate,OrderedbyDate,MaxVisitAsOf.VisitDate,MaxVisitAsOf.Pregnant,MaxVisitAsOf.Breastfeeding,ReportedbyDate,EligibleVL,IsValidVL,VLSup,OrderedFinal.AsOfDate,TestName,TestResult,Emr,Project  
 from MaxOrderedbyDateByAsOfDate_Final OrderedFinal
 join RankMaxVisitDateAsOf MaxVisitAsOf
 on OrderedFinal.SiteCode =  MaxVisitAsOf.SiteCode and OrderedFinal.PatientPK =  MaxVisitAsOf.PatientPK
 and OrderedFinal.AsOfDate =  MaxVisitAsOf.AsOfDate

)

insert into ndwh.dbo.FactViralLoad_Hist( SiteCode,PatientPK,StartARTDate,DOB,VisitDate,Pregnant,Breastfeeding,AgeAsOfDate,OrderedbyDate,ReportedbyDate,EligibleVL,IsValidVL,VLSup,AsOfDate,TestName,TestResult,Emr,Project)

select  SiteCode,PatientPK,StartARTDate,DOB,VisitDate,Pregnant,Breastfeeding,AgeAsOfDate,OrderedbyDate,ReportedbyDate,EligibleVL,IsValidVL,VLSup,AsOfDate,TestName,TestResult,Emr,Project  
from Combined

Update a
set   IsPBFW= case
						WHEN (Pregnant ='yes' or  Breastfeeding ='yes')  THEN 1
						ELSE 0
						END
from ndwh.dbo.FactViralLoad_Hist a;

Update a
set   IsValidVL= case
						WHEN datediff(month,[OrderedbyDate],a.AsOfDate) <= 6  THEN 1
						END
from ndwh.dbo.FactViralLoad_Hist a
where IsPBFW = 1



fetch next from cursor_AsOfDates into @as_of_date
end
drop table #months
close cursor_AsOfDates
deallocate cursor_AsOfDates



