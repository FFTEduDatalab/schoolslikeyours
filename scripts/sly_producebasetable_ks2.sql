use public_data
go

---- GIAS
if object_id('tempdb.dbo.#base', 'u') is not null
	drop table #base;

select
	sch_id,
	la_code,
	gor_code,
	establishmentname,
	case
		when gender_code=9 then 3
		else gender_code
	end gender_code,
	case
		when religiouscharacter_code=2 then 1		-- Church of England
		when religiouscharacter_code in (3,35) then 2		-- Roman Catholic/Catholic
		when religiouscharacter_code in (4,8,9,11,12,13,15,16,19,20,22,30,31) then 3		-- Other Christian
		when religiouscharacter_code in (5,7,14,21,25,29,43) then 4		-- Other
		when religiouscharacter_code in (0,6,99) then 9		-- None/not available
		else 500		-- shouldn't be any of these
	end religiouscharacter_code,
	urn,
	case
		when typeofestablishment_code in (2,3) then 1		-- Voluntary aided school, Voluntary controlled school
		when typeofestablishment_code=5 then 2		-- Foundation school
		when typeofestablishment_code=1 then 3		-- Community school
		when typeofestablishment_code in (6,34) then 4		-- City technology college, Converter academy
		when typeofestablishment_code=28 then 5		-- Sponsored academy
		when typeofestablishment_code=35 then 6		-- Free school
		when typeofestablishment_code in (40,41) then 7		-- University technical college, Studio school
	end schtype,
	case
		when statutorylowage=7 and statutoryhighage=11 then 2 -- junior
		when statutorylowage>7 and statutoryhighage<15 then 3 -- middle (excluding first and middle)
		when statutoryhighage>=16 then 4 -- all-through
		else 1 -- primary (including first and middle)
	end phase,
	case
		when left(urbanrural_code,1)='C' then 'C'
		when left(urbanrural_code,1)='D' then 'D'
		when left(urbanrural_code,1) in ('E','F') then 'E/F'
		else urbanrural_code
	end urbanrural_code,
	easting,
	northing,
	opendate
into #base
from organisation.gias
where
	ac_year=2018 and
	version=12 and
	establishmentstatus_code in (1,3) and
	statutoryhighage>=9 and
	statutorylowage<11 and
	typeofestablishment_code in (1,2,3,5,6,28,34,35,40,41)


---- KS2
if object_id('tempdb.dbo.#ks2_y0', 'u') is not null
	drop table #ks2_y0;
if object_id('tempdb.dbo.#ks2_y1', 'u') is not null
	drop table #ks2_y1;
if object_id('tempdb.dbo.#ks2_y2', 'u') is not null
	drop table #ks2_y2;

select
	rectype,
	lea*10000 + estab laestab,
	iclose,
	isnull(new_laestab,lea*10000+estab) sch_id,
	telig telig_2019,
	tks1average,
	tfsm6cla1a,
	ptfsm6cla1a,
	ptealgrp2,
	ptmobn ptnmob,
	readprog readprog_2019,
	matprog matprog_2019,
	writprog writprog_2019,
	ptrwm_exp ptrwm_exp_2019,
	ptrwm_high ptrwm_high_2019,
	ptrwm_exp_fsm6cla1a ptrwm_exp_pp_2019,
	ptrwm_high_fsm6cla1a ptrwm_high_pp_2019,
	ptread_exp ptread_exp_2019,
	ptread_high ptread_high_2019,
	ptmat_exp ptmat_exp_2019,
	ptmat_high ptmat_high_2019,
	ptwritta_exp ptwritta_exp_2019,
	ptwritta_high ptwritta_high_2019,
	ptgps_exp ptgps_exp_2019,
	ptgps_high ptgps_high_2019,
	telig*readcov readpups_2019,
	telig*writcov writpups_2019,
	telig*matcov matpups_2019,
	ptrwm_exp_3yr ptrwm_exp_3yr_2019,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks2_y0
from pt.ks2final2019edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+f.estab=p.old_laestab
where
	rectype in (1,5) and		-- NB: differs from special
	telig>0

select
	rectype,
	lea*10000 + estab laestab,
	iclose,
	isnull(new_laestab,lea*10000+estab) sch_id,
	telig telig_2018,
	tks1average,
	tfsm6cla1a,
	ptfsm6cla1a,
	ptealgrp2,
	ptmobn ptnmob,
	readprog readprog_2018,
	matprog matprog_2018,
	writprog writprog_2018,
	ptrwm_exp ptrwm_exp_2018,
	ptrwm_high ptrwm_high_2018,
	ptrwm_exp_fsm6cla1a ptrwm_exp_pp_2018,
	ptrwm_high_fsm6cla1a ptrwm_high_pp_2018,
	ptread_exp ptread_exp_2018,
	ptread_high ptread_high_2018,
	ptmat_exp ptmat_exp_2018,
	ptmat_high ptmat_high_2018,
	ptwritta_exp ptwritta_exp_2018,
	ptwritta_high ptwritta_high_2018,
	ptgps_exp ptgps_exp_2018,
	ptgps_high ptgps_high_2018,
	telig*readcov readpups_2018,
	telig*writcov writpups_2018,
	telig*matcov matpups_2018,
	ptrwm_exp_3yr ptrwm_exp_3yr_2018,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks2_y1
from pt.ks2final2018edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+estab=old_laestab
where
	rectype in (1,5) and		-- NB: differs from special
	telig>0

select
	rectype,
	lea*10000 + estab laestab, iclose, isnull(new_laestab,lea*10000+estab) sch_id,
	telig telig_2017, tks1average, ptfsm6cla1a, ptealgrp2, ptmobn ptnmob,
	readprog readprog_2017, matprog matprog_2017, writprog writprog_2017,
	ptrwm_exp ptrwm_exp_2017, ptrwm_high ptrwm_high_2017,
	ptread_exp ptread_exp_2017, ptread_high ptread_high_2017,
	ptmat_exp ptmat_exp_2017, ptmat_high ptmat_high_2017,
	ptwritta_exp ptwritta_exp_2017, ptwritta_high ptwritta_high_2017,
	ptgps_exp ptgps_exp_2017, ptgps_high ptgps_high_2017,
	telig*readcov readpups_2017,
	telig*writcov writpups_2017,
	telig*matcov matpups_2017,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks2_y2
from pt.ks2final2017edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+estab=old_laestab
where
	rectype in (1,5) and		-- NB: differs from special
	telig>0

-- sch_id reversion
update t
set t.sch_id=t.laestab
from #base b
	inner join #ks2_y0 t
		on b.sch_id=t.laestab
where
	not exists (select * from #ks2_y0 c where c.sch_id=b.sch_id)

update t
set t.sch_id=t.laestab
from #base b
	inner join #ks2_y1 t
		on b.sch_id=t.laestab
where
	not exists (select * from #ks2_y1 c where c.sch_id=b.sch_id)

update t
set t.sch_id=t.laestab
from #base b
	inner join #ks2_y2 t
		on b.sch_id=t.laestab
where
	not exists (select * from #ks2_y2 c where c.sch_id=b.sch_id)

--- Add schools to base which appear in y0 KS2 data
insert #base
select
	sch_id,
	la_code,
	gor_code,
	establishmentname,
	gender_code,
	religiouscharacter_code,
	urn,
	schtype,
	phase,
	urbanrural_code,
	easting,
	northing,
	opendate
from
(
select
	g.sch_id,
	la_code,
	gor_code,
	establishmentname,
	gender_code,
	case
		when religiouscharacter_code=2 then 1		-- Church of England
		when religiouscharacter_code in (3,35) then 2		-- Roman Catholic/Catholic
		when religiouscharacter_code in (4,8,9,11,12,13,15,16,19,20,22,30,31) then 3		-- Other Christian
		when religiouscharacter_code in (5,7,14,21,25,29,43) then 4		-- Other
		when religiouscharacter_code in (0,6,99) then 9		-- None/not available
		else 500		-- shouldn't be any of these
	end religiouscharacter_code,
	urn,
	case
		when typeofestablishment_code in (2,3) then 1		-- Voluntary aided school, Voluntary controlled school
		when typeofestablishment_code=5 then 2		-- Foundation school
		when typeofestablishment_code=1 then 3		-- Community school
		when typeofestablishment_code in (6,34) then 4		-- City technology college, Converter academy
		when typeofestablishment_code=28 then 5		-- Sponsored academy
		when typeofestablishment_code=35 then 6		-- Free school
		when typeofestablishment_code in (40,41) then 7		-- University technical college, Studio school
	end schtype,
	case
		when statutorylowage=7 and statutoryhighage=11 then 2 -- junior
		when statutorylowage>7 and statutoryhighage<15 then 3 -- middle (excluding first and middle)
		when statutoryhighage>=16 then 4 -- all-through
		else 1 -- primary (including first and middle)
	end phase,
	case
		when left(urbanrural_code,1)='C' then 'C'
		when left(urbanrural_code,1)='D' then 'D'
		when left(urbanrural_code,1) in ('E','F') then 'E/F'
		else urbanrural_code
	end urbanrural_code,
	easting,
	northing,
	opendate,
	row_number() over (partition by g.sch_id order by opendate desc) rowid
from #ks2_y0 y
	inner join organisation.gias g on
		y.sch_id=g.sch_id and
		ac_year=2018 and
		version=12 and
		statutorylowage<11
where
	iclose=0 and
	not exists (select * from #base b where b.sch_id=y.sch_id)
) q
where rowid=1


--- Characteristics
if object_id('tempdb.dbo.#context', 'u') is not null
	drop table #context;

select
	isnull(new_laestab,laestab) laestab,
	laestab orig_laestab,
    pct_of_pupils_known_to_be_eligible_for_and_claiming_free_school_meals pct_fsm,
	e.pnumfsmever pct_fsm6,		-- this is a big misnomer in the p.t. census file!
	round(100*cast(number_of_pupils_whose_first_language_is_known_or_believed_to_be_other_than_english as real)/nullif(headcount_of_pupils,0),1) pct_eal,
	nullif(headcount_of_pupils,0) pupils,
	cast(full_time_boys_aged_5 as int)+cast(full_time_boys_aged_6 as int)+cast(full_time_boys_aged_7 as int)+		-- NB: this differs from KS4 code
	cast(full_time_boys_aged_8 as int)+cast(full_time_boys_aged_9 as int)+cast(full_time_girls_aged_5 as int)+
	cast(full_time_girls_aged_6 as int)+cast(full_time_girls_aged_7 as int)+
	cast(full_time_girls_aged_8 as int)+cast(full_time_girls_aged_9 as int)+
	cast(full_time_boys_aged_10 as int)+cast(full_time_girls_aged_10 as int) as comp_pupils,
	case when cast(full_time_boys_aged_5 as int)>=2 or cast(full_time_girls_aged_5 as int)>=2 then 1 else 0 end +
	case when cast(full_time_boys_aged_6 as int)>=2 or cast(full_time_girls_aged_6 as int)>=2 then 1 else 0 end +
	case when cast(full_time_boys_aged_7 as int)>=2 or cast(full_time_girls_aged_7 as int)>=2 then 1 else 0 end +
	case when cast(full_time_boys_aged_8 as int)>=2 or cast(full_time_girls_aged_8 as int)>=2 then 1 else 0 end +
	case when cast(full_time_boys_aged_9 as int)>=2 or cast(full_time_girls_aged_9 as int)>=2 then 1 else 0 end +
	case when cast(full_time_boys_aged_10 as int)>=2 or cast(full_time_girls_aged_10 as int)>=2 then 1 else 0 end as comp_cohorts,
	round(100*(cast(number_of_pupils_classified_as_white_british_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_irish_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_traveller_of_irish_heritage_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_any_other_white_background_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_gypsy_roma_ethnic_origin as real))
	/nullif(headcount_of_pupils,0),1) pct_white,
	round(100*(cast(number_of_pupils_classified_as_white_and_black_caribbean_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_white_and_black_african_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_white_and_asian_ethnic_origin as real) +
	cast(number_of_pupils_classified_as_any_other_mixed_background_ethnic_origin as real))
	/nullif(headcount_of_pupils,0),1) pct_mixed,
	round(100*(cast(number_of_pupils_classified_as_indian_ethnic_origin as real)+
	cast(number_of_pupils_classified_as_pakistani_ethnic_origin as real)+
	cast(number_of_pupils_classified_as_bangladeshi_ethnic_origin as real)+
	cast(number_of_pupils_classified_as_any_other_asian_background_ethnic_origin as real))
	/nullif(headcount_of_pupils,0),1) pct_asian,
	round(100*(cast(number_of_pupils_classified_as_black_caribbean_ethnic_origin as real)+
	cast(number_of_pupils_classified_as_black_african_ethnic_origin as real)+
	cast(number_of_pupils_classified_as_any_other_black_background_ethnic_origin as real))
	/nullif(headcount_of_pupils,0),1) pct_black,
	round(100*cast(number_of_pupils_classified_as_chinese_ethnic_origin as real)/nullif(headcount_of_pupils,0),1) pct_chinese,
	round(100*(cast(number_of_pupils_classified_as_any_other_ethnic_group_ethnic_origin as real) +
	cast(number_of_pupils_unclassified as real))
	/nullif(headcount_of_pupils,0),1) pct_otherunclassified,
	count(1) over (partition by isnull(new_laestab,laestab)) dups
into #context
from public_data.spc.udschoolspupils2019edited c
	left join public_data.organisation.predecessors p on
		c.laestab=p.old_laestab
	left join public_data.pt.census2019 e on
		c.laestab=concat(e.la,e.estab)
where
	c.geographic_level='school'


--- In context data, set laestab back to orig_laestab where laestab is unmatched to GIAS
update t
set t.laestab=orig_laestab
from #base b
	inner join #context t
		on sch_id=t.orig_laestab
where
	not exists (select * from #context c where c.laestab=sch_id)


-- Update fsmever for schools which changed laestab
update c
set pct_fsm6=pnumfsmever
from #context c
	left join public_data.organisation.predecessors p
		on c.laestab=p.new_laestab
	left join pt.census2019 s
		on old_laestab=s.la*10000+estab
where
	pct_fsm6 is null and
	exists (select * from #base b where sch_id=laestab)


--- Ofsted rating at end of year
if object_id('tempdb.dbo.#ofsted', 'u') is not null
	drop table #ofsted;

select
	isnull(cast(new_laestab as real), cast(laestab as real)) laestab,
	inspectionenddate,
	overall latest_ofsted,
	laestab orig_laestab,
	year,
	row_number() over (partition by isnull(cast(new_laestab as real), cast(laestab as real)) order by year desc, inspectionenddate desc) inspid		-- used to pick up the latest inspection
into #ofsted
from
(
select
	*,
	row_number() over (partition by laestab, year order by inspectionenddate desc) rowid		-- used to pick up the latest inspection in any given year
from
(
select distinct
	laestab,
	[inspection_date] inspectionenddate,
	[overall_effectiveness] overall,
	year(inspection_date) + case when month(inspection_date)>=9 then 1 else 0 end year		-- 201708 -> 2017, 201709 -> 2018
from public_data.ofsted.MIcompiled
where
	[overall_effectiveness] is not null
) q
where
	year<=2019
) y
left join public_data.organisation.predecessors h
	on y.laestab=h.old_laestab
where
	rowid=1

--- sch_id reversion
update t
set t.laestab=orig_laestab
from #base b
	inner join #ofsted t
		on sch_id=t.orig_laestab
where
	not exists (select * from #ofsted c where c.laestab=sch_id)

--- Workforce
if object_id('tempdb.dbo.#swf', 'u') is not null
	drop table #swf;

select
	isnull(cast(new_laestab as real), concat([la number],[establishment number])) laestab,
	concat([la number],[establishment number]) orig_laestab,
	case
		when isnumeric([Total Number of Teachers (Headcount)])=1 then [Total Number of Teachers (Headcount)]
		else null
	end total_teachers,
	case
		when isnumeric([Total Number of Teachers (full-time Equivalent)])=1 then [Total Number of Teachers (full-time Equivalent)]
		else null
	end total_teachers_fte,
	case
		when isnumeric([Ratio of Teaching Assistants to All Teachers])=1 then [Ratio of Teaching Assistants to All Teachers]
		else null
	end assistant_teacher_ratio,
	case
		when isnumeric([Pupil:     Teacher Ratio])=1 then [Pupil:     Teacher Ratio]
		else null
	end pupil_teacher_ratio,
	case
		when isnumeric([Teachers Aged 50 or over (%)])=1 then [Teachers Aged 50 or over (%)]/100.0 			-- needs to be in range 0-1 for funnel plots to work
		else null
	end pct_teachers_50,
	case
		when isnumeric([Teachers with Qualified Teacher Status (%)])=1 then [Teachers with Qualified Teacher Status (%)]/100.0
		else null
	end pct_teachers_qts,
	case
		when isnumeric([Mean Gross Salary of All Teachers (£)])=1 then [Mean Gross Salary of All Teachers (£)]
		else null
	end mean_salary_teachers,
	case
		when isnumeric([All Classroom Teachers on Main Pay Range (%)])=1 then [All Classroom Teachers on Main Pay Range (%)]/100.0
		else null
	end pct_teachers_main,
	case
		when isnumeric([All Teachers on the Leadership Pay Range (%)])=1 then [All Teachers on the Leadership Pay Range (%)]/100.0
		else null
	end pct_teachers_leadership,
	case
		when isnumeric([Average Number of Days Lost to Teacher Sickness Absence (All Tea])=1 then [Average Number of Days Lost to Teacher Sickness Absence (All Tea]
		else null
	end mean_sick_days,
	case
		when isnumeric([Full-Time Temporarily Filled Posts - Demoninator is an addition])=1 then [Full-Time Temporarily Filled Posts - Demoninator is an addition]/100.0
		else null
	end pct_temp_posts,
	count(1) over (partition by isnull(cast(new_laestab as real), concat([la number],[establishment number]))) dups
into #swf
from public_data.sw.schools201811 s
	left join public_data.organisation.predecessors p on
		concat(s.[la number],s.[establishment number])=old_laestab

--- sch_id reversion
update t
set t.laestab=orig_laestab
from #base b
	inner join #swf t
		on sch_id=t.orig_laestab
where
	not exists (select * from #swf c where c.laestab=sch_id)


-- Absence
if object_id('tempdb.dbo.#absence', 'u') is not null
	drop table #absence;

select
	geographic_level,
	school_type,
	isnull(cast(p.new_laestab as real), a.laestab) laestab,
	a.laestab orig_laestab,
	urn,
	case
		when isnumeric(sess_overall_percent)=1 then sess_overall_percent/100.0 			-- needs to be in range 0-1 for funnel plots to work
		else null
	end total_absence,
	case
		when isnumeric(enrolments_pa_10_exact_percent)=1 then enrolments_pa_10_exact_percent/100.0
		else null
	end persistent_absence,
	count(1) over (partition by isnull(cast(p.new_laestab as real), a.laestab)) dups		-- used to exclude schools that appear in source data more than once, on the grounds that there has e.g. been a merger, and using either individual record wouldn't be accurate
into #absence
from public_data.sfr.absence2019 a
	left join public_data.organisation.predecessors p
		on a.laestab=p.old_laestab
where
	geographic_level in ('national','school') and
	time_period='201819'

update t
set t.laestab=orig_laestab
from #base b
	inner join #absence t
		on sch_id=t.orig_laestab
where
	not exists (select * from #absence c where c.laestab=sch_id)


-- Finance
if object_id('tempdb.dbo.#mat_totals_y2', 'u') is not null
	drop table #mat_totals_y2;
if object_id('tempdb.dbo.#mat_totals_y1', 'u') is not null
	drop table #mat_totals_y1;
if object_id('tempdb.dbo.#mat_totals_y0', 'u') is not null
	drop table #mat_totals_y0;

select
	max(mat_number) mat_number,
	sum(
		case
			when return_type='MAT' then number_pupils_fte
			else null
		end
	) number_pupils_fte,
	sum(
		case
			when return_type='MAT' then period_covered
			else null
		end
	) period_covered,
	sum(
		case
			when return_type='Central Services' then i_totals_income_net
			else null
		end
	) i_totals_income_net
into #mat_totals_y2
from public_data.finance.academiesIE2017
group by mat_number

select
	max(a.[Company number]) company_number,
	sum(
		case
			when a.[MAT SAT or Central Services]='MAT' then a.[No Pupils]
			else null
		end
	) number_pupils_fte,
	sum(
		case
			when a.[MAT SAT or Central Services]='MAT' then a.[Period covered by return]
			else null
		end
	) period_covered,
	sum(
		case
			when c.[MAT SAT or Central Services]='Central Services' then c.[Total Income]-c.[Income from catering]-c.[Receipts from supply teacher insurance claims]
			else null
		end
	) i_totals_income_net
into #mat_totals_y1
from public_data.finance.academiesIE2018 a
	inner join public_data.finance.academiesIE2018centralservices c on
		a.[Company Number]=c.[Company Number]
where
	a.[MAT SAT or Central Services]='MAT'
group by a.[Company Number]

select
	max(a.[Company number]) company_number,
	sum(
		case
			when a.[MAT SAT or Central Services]='MAT' then a.[No Pupils]
			else null
		end
	) number_pupils_fte,
	sum(
		case
			when a.[MAT SAT or Central Services]='MAT' then a.[Period covered by return]
			else null
		end
	) period_covered,
	sum(
		case
			when c.[MAT SAT or Central Services]='Central Services' then c.[Total Income]-c.[Income from catering]-c.[Receipts from supply teacher insurance claims]
			else null
		end
	) i_totals_income_net
into #mat_totals_y0
from public_data.finance.academiesIE2019 a
	inner join public_data.finance.academiesIE2019centralservices c on
		a.[Company Number]=c.[Company Number]
where
	a.[MAT SAT or Central Services]='MAT' and
	a.[No Pupils] is not null		-- there are a small number of records where this is the case
group by a.[Company Number]

if object_id('tempdb.dbo.#finance_y2', 'u') is not null
	drop table #finance_y2;
if object_id('tempdb.dbo.#finance_y1', 'u') is not null
	drop table #finance_y1;
if object_id('tempdb.dbo.#finance_y0', 'u') is not null
	drop table #finance_y0;

select
	isnull(new_laestab, laestab) laestab,
	laestab orig_laestab,
	income_per_pupil income_per_pupil_2017,
	count(1) over (partition by isnull(new_laestab, laestab)) dups
into #finance_y2
from
(
	select
		concat(la,estab) laestab,
		case
			when t.number_pupils_fte is not null then cast(((a.i_totals_income_net/a.period_covered*12+isnull(t.i_totals_income_net*a.number_pupils_fte*a.period_covered*1.0/(t.number_pupils_fte*t.period_covered),0))/cast(a.number_pupils_fte as real)) as int)
			else cast((a.i_totals_income_net/a.period_covered*12.0)/cast(a.number_pupils_fte as real) as int)
		end income_per_pupil
	from finance.academiesIE2017 a
		left join #mat_totals_y2 t on
			t.mat_number=a.mat_number
	where
		isnumeric(a.number_pupils_fte)=1 and
		isnull(cast(a.number_pupils_fte as real),0)!=0 and
		a.i_totals_income_net>0

	union all

	select
		cast(school_dfe_number as int),
		cast(cast(total_income_net as real)/cast(number_of_pupils_fte as real) as int)
	from finance.cfrfull2017edited
	where
		isnumeric(number_of_pupils_fte)=1 and
		isnull(cast(number_of_pupils_fte as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and
	q.income_per_pupil<19000

update t
set t.laestab=orig_laestab
from #base b
	inner join #finance_y2 t
		on sch_id=t.orig_laestab
where
	not exists (select * from #finance_y2 c where c.laestab=b.sch_id)

select
	isnull(new_laestab, laestab) laestab,
	laestab orig_laestab,
	income_per_pupil income_per_pupil_2018,
	count(1) over (partition by isnull(new_laestab, laestab)) dups
into #finance_y1
from
(
	select
		concat(la,estab) laestab,
		case
			when t.number_pupils_fte is not null then cast (((a.[Total income]-a.[Income from catering]-a.[Receipts from supply teacher insurance claims])/a.[Period covered by return]*12+isnull(t.i_totals_income_net*a.[No Pupils]*a.[Period covered by return]*1.0/(t.number_pupils_fte*t.period_covered),0))/cast(a.[No Pupils] as real) as int)
			else cast(((a.[Total income]-a.[Income from catering]-a.[Receipts from supply teacher insurance claims])/a.[Period covered by return]*12.0)/cast(a.[No Pupils] as real) as int)
		end income_per_pupil
	from finance.academiesIE2018 a
		left join #mat_totals_y1 t on
			t.company_number=a.[Company number]
	where
		isnumeric(a.[No Pupils])=1 and
		isnull(cast(a.[No Pupils] as real),0)!=0 and
		a.[Total income]>0 and
		a.[Period covered by return]>0

	union all

	select
		cast([School DfE number] as int),
		cast(cast(total_income_net as real)/cast([Number of Pupils (FTE)] as real) as int)
	from finance.cfrfull2018edited
	where
		isnumeric([Number of Pupils (FTE)])=1 and
		isnull(cast([Number of Pupils (FTE)] as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and
	q.income_per_pupil<19000

update t
set t.laestab=orig_laestab
from #base b
	inner join #finance_y1 t
		on sch_id=t.orig_laestab
where
	not exists (select * from #finance_y1 c where c.laestab=b.sch_id)

select
	isnull(new_laestab, laestab) laestab,
	laestab orig_laestab,
	income_per_pupil income_per_pupil_2019,
	count(1) over (partition by isnull(new_laestab, laestab)) dups
into #finance_y0
from
(
	select
		concat(la,estab) laestab,
		case
			when t.number_pupils_fte is not null then cast (((a.[Total income]-a.[Income from catering]-a.[Receipts from supply teacher insurance claims])/a.[Period covered by return]*12+isnull(t.i_totals_income_net*a.[No Pupils]*a.[Period covered by return]*1.0/(t.number_pupils_fte*t.period_covered),0))/cast(a.[No Pupils] as real) as int)
			else cast(((a.[Total income]-a.[Income from catering]-a.[Receipts from supply teacher insurance claims])/a.[Period covered by return]*12.0)/cast(a.[No Pupils] as real) as int)
		end income_per_pupil
	from finance.academiesIE2019 a
		left join #mat_totals_y0 t on
			t.company_number=a.[Company number]
	where
		isnumeric(a.[No Pupils])=1 and
		isnull(cast(a.[No Pupils] as real),0)!=0 and
		a.[Total income]>0 and
		a.[Period covered by return]>0

	union all

	select
		laestab,
		cast(cast(total_income_net as real)/cast([No Pupils] as real) as int)
	from finance.cfrfull2019edited
	where
		isnumeric([No Pupils])=1 and
		isnull(cast([No Pupils] as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and
	q.income_per_pupil<19000

update t
set t.laestab=orig_laestab
from #base b
	inner join #finance_y0 t
		on sch_id=t.orig_laestab
where
	not exists (select * from #finance_y0 c where c.laestab=b.sch_id)


-- School capacity
if object_id('tempdb..#capacity') is not null
	drop table #capacity;

select
	isnull(cast(p.new_laestab as real), a.laestab) laestab,
	a.laestab orig_laestab,
	cast(maynor as real)/netcapacity pct_capacity,
	count(1) over (partition by isnull(p.new_laestab, a.laestab)) dups
into #capacity
from cap.school_capacity_2019 a
	left join public_data.organisation.predecessors p
		on a.laestab=p.old_laestab

update t
set t.laestab=orig_laestab
from #base b
	inner join #capacity t
		on sch_id=t.orig_laestab
where
	not exists (select * from #capacity c where c.laestab=sch_id)


-- Search strings
-- if object_id('tempdb..#search') is not null
-- 	drop table #search;
--
-- select
-- 	b.urn,
-- 	' '+upper(cast(n.establishmentname as varchar(max))
-- 	+' '+cast(la.name as varchar(max))
-- 	+' '+cast(b.sch_id as varchar(max))
-- 	+' '+cast(b.urn as varchar(max))
-- 	+' ') string
-- into
-- 	#search
-- from
-- 	#base b
-- 	left join datalab.fos.schoolnames20180801 n on b.urn = n.urn
-- 	left join core.organisation.organisations la on b.la_code = la.organisation_id
-- ;
-- update #search set string = replace(string, '''', '') where string like '%''%';
-- update #search set string = replace(string, '#E28099', '') where string like '%#E28099%'; -- typographer's apostrophe
-- update #search set string = replace(string, '`', '') where string like '%`%'; -- school using a backtick as an apostrophe!
-- update #search set string = replace(string, ',', '') where string like '%,%';
-- update #search set string = replace(string, '.', '') where string like '%.%';
-- update #search set string = replace(string, ':', '') where string like '%:%';
-- update #search set string = replace(string, '&', ' ') where string like '%&%';
-- update #search set string = replace(string, '@', ' ') where string like '%@%';
-- update #search set string = replace(string, '-', ' ') where string like '%-%';
-- update #search set string = replace(string, '#E28093', ' ') where string like '%#E28093%'; -- en-dash
-- update #search set string = replace(string, '/', ' ') where string like '%/%';
-- update #search set string = replace(replace(string, '(', ' '), ')', ' ') where string like '%[()]%';
--
-- if exists(select * from #search where string like '%[^A-Z0-9 #]%')
-- begin
-- 	select top 100 string from #search where string like '%[^A-Z0-9 #]%'
-- 	raiserror('Bad character in search string', 16, 1);
-- end
--
-- update #search set string = replace(string, ' SAINT ', ' ST ') where string like '% SAINT %';
-- update #search set string = replace(string, ' CHURCH OF ENGLAND ', ' CE ') where string like '% CHURCH OF ENGLAND %';
-- update #search set string = replace(string, ' COFE ', ' CE ') where string like '% COFE %';
-- update #search set string = replace(string, ' C OF E ', ' CE ') where string like '% C OF E %';
-- update #search set string = replace(string, ' ROMAN CATHOLIC ', ' RC ') where string like '% ROMAN CATHOLIC %';
--
-- update #search set string = ltrim(rtrim(string));
-- while @@rowcount > 0
-- 	insert #search
-- 	select
-- 		urn,
-- 		substring(string, charindex(' ', string) + 1, len(string))
-- 	from
-- 		(
-- 		update #search
-- 		set string = substring(string, 1, charindex(' ', string) - 1)
-- 		output deleted.urn, deleted.string
-- 		from #search
-- 		where string like '% %'
-- 		) _
-- 	;
--
-- delete #search
-- where string in (
-- 	'AIDED',
-- 	'AND',
-- 	'CONTROLLED',
-- 	'NURSERY',
-- 	'PRIMARY',
-- 	'SCHOOL',
-- 	'SECONDARY',
-- 	'THE',
-- 	'VOLUNTARY',
-- 	'');
-- delete #search where len(string) < 3 and string not in ('CE', 'RC', 'ST');
-- delete #search
-- where string like '#C___'
-- 	or string like '_#C___'
-- 	or string like '#C____'
-- 	or string like '#E_____'
-- 	or string like '_#E_____'
-- 	or string like '#E______'
--
-- create clustered index cx_search on #search(urn);
--
-- delete s
-- from (select *, row_number() over (partition by urn, string order by (select 1)) n from #search) s
-- where n > 1
-- ;
--
-- declare @urn int, @string varchar(max);
--
-- update #search
-- set
-- 	@string = string = case urn when @urn then @string + ' ' + string else string end,
-- 	@urn = urn
-- from
-- 	#search
-- ;
--
-- delete #search
-- where exists(
-- 	select *
-- 	from #search _
-- 	where
-- 		urn = #search.urn
-- 		and string > #search.string
-- 	);


--- Final select
if object_id('datalab.fos.ks2', 'u') is not null
	drop table datalab.fos.ks2;
go

if object_id('datalab.fos.ks2_natavgs', 'u') is not null
	drop table datalab.fos.ks2_natavgs;
go

select
	cast(
		case
			when y0.telig_2019>5 then 1
			else 0
		end
	as varchar(max)) inResults,
	isnull(cast(b.sch_id as varchar(max)),'""') sch_id,
	isnull(cast(b.urn as varchar(max)),'""') urn,
	isnull('"' + datalab.fos.setNonNumericsToNull(s.establishmentname)+'"','""') establishmentname,
	isnull(cast(b.la_code as varchar(max)),'""') la_code,
	isnull('"' + datalab.fos.setNonNumericsToNull(b.gor_code)+'"','""') gor_code,
	isnull('"' + datalab.fos.setNonNumericsToNull(b.opendate)+'"','""') opendate,
	isnull(cast(b.schtype as varchar(max)),'""') schtype,
	isnull(cast(b.phase as varchar(max)),'""') phase,
	isnull(cast(b.religiouscharacter_code as varchar(max)),'""') religiouscharacter_code,
	isnull('"' + datalab.fos.setNonNumericsToNull(b.urbanrural_code)+'"','""') urbanrural_code,
	isnull(cast(case when xy.coastal_la=1 and xy.distance<=5500 then 1 else 0 end  as varchar(max)),'""') coastal,
	isnull('[' + datalab.fos.setNonNumericsToNull(b.easting)+','+datalab.fos.setNonNumericsToNull(b.northing)+']','""') grid_ref,
	isnull(datalab.fos.setNonNumericsToNull(cap.pct_capacity),'""') pct_capacity,
	isnull(cast(o.latest_ofsted as varchar(max)),'""') latest_ofsted,
	isnull(datalab.fos.setNonNumericsToNull(c.pupils),'""') pupils,
	isnull(datalab.fos.setNonNumericsToNull(c.comp_pupils),'""') comp_pupils,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_fsm),'""') pct_fsm,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_fsm6),'""') pct_fsm6,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_eal),'""') pct_eal,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_white),'""') pct_white,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_black),'""') pct_black,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_asian),'""') pct_asian,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_chinese),'""') pct_chinese,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_mixed),'""') pct_mixed,
	isnull(datalab.fos.setNonNumericsToNull(c.pct_otherunclassified),'""') pct_otherunclassified,
	isnull(datalab.fos.setNonNumericsToNull(y0.telig_2019),'""') telig_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.readpups_2019),'""') readpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.writpups_2019),'""') writpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.matpups_2019),'""') matpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.tfsm6cla1a),'""') tfsm6cla1a_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptfsm6cla1a),'""') ptfsm6cla1a_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptealgrp2),'""') ptealgrp2_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptnmob),'""') ptnmob_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.tks1average),'""') tks1average,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_exp_2019),'""') ptrwm_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_high_2019),'""') ptrwm_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_exp_pp_2019),'""') ptrwm_exp_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_high_pp_2019),'""') ptrwm_high_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptread_exp_2019),'""') ptread_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptread_high_2019),'""') ptread_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.readprog_2019),'""') readprog_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptwritta_exp_2019),'""') ptwritta_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptwritta_high_2019),'""') ptwritta_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.writprog_2019),'""') writprog_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptmat_exp_2019),'""') ptmat_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptmat_high_2019),'""') ptmat_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.matprog_2019),'""') matprog_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptgps_exp_2019),'""') ptgps_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptgps_high_2019),'""') ptgps_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y1.telig_2018),'""') telig_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.readpups_2018),'""') readpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.writpups_2018),'""') writpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.matpups_2018),'""') matpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.ptrwm_exp_2018),'""') ptrwm_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptrwm_high_2018),'""') ptrwm_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptread_exp_2018),'""') ptread_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptread_high_2018),'""') ptread_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.readprog_2018),'""') readprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptwritta_exp_2018),'""') ptwritta_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptwritta_high_2018),'""') ptwritta_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.writprog_2018),'""') writprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptmat_exp_2018),'""') ptmat_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptmat_high_2018),'""') ptmat_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.matprog_2018),'""') matprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptgps_exp_2018),'""') ptgps_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptgps_high_2018),'""') ptgps_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y2.telig_2017),'""') telig_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.readpups_2017),'""') readpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.writpups_2017),'""') writpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.matpups_2017),'""') matpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.ptrwm_exp_2017),'""') ptrwm_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptrwm_high_2017),'""') ptrwm_high_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptread_exp_2017),'""') ptread_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptread_high_2017),'""') ptread_high_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.readprog_2017),'""') readprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptwritta_exp_2017),'""') ptwritta_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptwritta_high_2017),'""') ptwritta_high_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.writprog_2017),'""') writprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptmat_exp_2017),'""') ptmat_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptmat_high_2017),'""') ptmat_high_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.matprog_2017),'""') matprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptgps_exp_2017),'""') ptgps_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptgps_high_2017),'""') ptgps_high_2017,
	isnull(cast((isnull(telig_2019,0)+isnull(telig_2018,0)+isnull(telig_2017,0))/3 as varchar(max)),'""') telig_3yr_2019,
	isnull(cast((isnull(readpups_2019,0)+isnull(readpups_2018,0)+isnull(readpups_2017,0))/3 as varchar(max)),'""') readpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(cast((isnull(writpups_2019,0)+isnull(writpups_2018,0)+isnull(writpups_2017,0))/3 as varchar(max)),'""') writpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(cast((isnull(matpups_2019,0)+isnull(matpups_2018,0)+isnull(matpups_2017,0))/3 as varchar(max)),'""') matpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(cast(
		round(isnull(ptrwm_exp_3yr_2019,
		(isnull(ptrwm_exp_2019,0)*isnull(telig_2019,0)+
		 isnull(ptrwm_exp_2018,0)*isnull(telig_2018,0)+
		 isnull(ptrwm_exp_2017,0)*isnull(telig_2017,0)
		)/nullif(isnull(case when nullif(ptrwm_exp_2017,0) is not null then telig_2017 end,0)+
				 isnull(case when nullif(ptrwm_exp_2018,0) is not null then telig_2018 end,0)+
				 isnull(case when nullif(ptrwm_exp_2019,0) is not null then telig_2019 end,0)
				,0)
		 ),2)+0.0		-- gets rid of negative zeros
 	as varchar(max)),'""') ptrwm_exp_3yr_2019,
	isnull(cast(
		round((isnull(readprog_2019,0)*isnull(readpups_2019,0)+isnull(readprog_2018,0)*isnull(readpups_2018,0)+isnull(readprog_2017,0)*isnull(readpups_2017,0))
		/nullif(isnull(readpups_2019,0)+isnull(readpups_2018,0)+isnull(readpups_2017,0),0),1)+0.0
	as varchar(max)),'""') readprog_3yr_2019,
	isnull(cast(
		round((isnull(writprog_2019,0)*isnull(writpups_2019,0)+isnull(writprog_2018,0)*isnull(writpups_2018,0)+isnull(writprog_2017,0)*isnull(writpups_2017,0))
		/nullif(isnull(writpups_2019,0)+isnull(writpups_2018,0)+isnull(writpups_2017,0),0),1)+0.0
	as varchar(max)),'""') writprog_3yr_2019,
	isnull(cast(
		round((isnull(matprog_2019,0)*isnull(matpups_2019,0)+isnull(matprog_2018,0)*isnull(matpups_2018,0)+isnull(matprog_2017,0)*isnull(matpups_2017,0))
		/nullif(isnull(matpups_2019,0)+isnull(matpups_2018,0)+isnull(matpups_2017,0),0),1)+0.0
	as varchar(max)),'""') matprog_3yr_2019,
	isnull(datalab.fos.setNonNumericsToNull(a.total_absence),'""') total_absence,
	isnull(datalab.fos.setNonNumericsToNull(a.persistent_absence),'""') persistent_absence,
	isnull(datalab.fos.setNonNumericsToNull(w.total_teachers),'""') total_teachers,
	isnull(datalab.fos.setNonNumericsToNull(w.total_teachers_fte),'""') total_teachers_fte,
	isnull(datalab.fos.setNonNumericsToNull(w.pupil_teacher_ratio),'""') pupil_teacher_ratio,
	isnull(datalab.fos.setNonNumericsToNull(w.assistant_teacher_ratio),'""') assistant_teacher_ratio,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_qts),'""') pct_teachers_qts,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_50),'""') pct_teachers_50,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_temp_posts),'""') pct_temp_posts,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_main),'""') pct_teachers_main,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_leadership),'""') pct_teachers_leadership,
	isnull(datalab.fos.setNonNumericsToNull(w.mean_salary_teachers),'""') mean_salary_teachers,
	isnull(datalab.fos.setNonNumericsToNull(w.mean_sick_days),'""') mean_sick_days,
	isnull(datalab.fos.setNonNumericsToNull(f0.income_per_pupil_2019),'""') income_per_pupil_2019,
	isnull(datalab.fos.setNonNumericsToNull(f1.income_per_pupil_2018),'""') income_per_pupil_2018,
	isnull(datalab.fos.setNonNumericsToNull(f2.income_per_pupil_2017),'""') income_per_pupil_2017
	-- '"' + isnull(#search.string, '') + '"' search_string
into datalab.fos.ks2
from #base b
	inner join datalab.fos.schoolnames20190801 s on
		b.urn=s.urn
	inner join #context c on
		b.sch_id=c.laestab and c.dups=1
	left join #ofsted o on
		b.sch_id=o.laestab and o.inspid=1
	left join #ks2_y0 y0 on
		b.sch_id=y0.sch_id and y0.dups=1
	left join #ks2_y1 y1 on
		b.sch_id=y1.sch_id and y1.dups=1
	left join #ks2_y2 y2 on
		b.sch_id=y2.sch_id and y2.dups=1
	left join #swf w on
		b.sch_id=w.laestab and w.dups=1
	left join #absence a on
		b.sch_id=a.laestab and a.dups=1
	left join #finance_y0 f0 on
		b.sch_id=f0.laestab and f0.dups=1
	left join #finance_y1 f1 on
		b.sch_id=f1.laestab and f1.dups=1
	left join #finance_y2 f2 on
		b.sch_id=f2.laestab and f2.dups=1
	left join datalab.organisation.schoolxy_gias xy on
		b.sch_id=xy.point_id
	left join #capacity cap on
		b.sch_id=cap.laestab and cap.dups=1
	-- left join #search on
	-- 	b.urn=#search.urn

select
	'""' inResults,
	'""' sch_id,
	'""' urn,
	'"England"' establishmentname,
	'""' la_code,
	'""' gor_code,
	'""' opendate,
	'""' schtype,
	'""' phase,
	'""' religiouscharacter_code,
	'""' urbanrural_code,
	'""' coastal,
	'""' grid_ref,
	'""' pct_capacity,
	'""' latest_ofsted,
	'""' pupils,
	'""' comp_pupils,
	'""' pct_fsm,
	'""' pct_fsm6,
	'""' pct_eal,
	'""' pct_white,
	'""' pct_black,
	'""' pct_asian,
	'""' pct_chinese,
	'""' pct_mixed,
	'""' pct_otherunclassified,
	isnull(datalab.fos.setNonNumericsToNull(y0.telig_2019),'""') telig_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.readpups_2019),'""') readpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.writpups_2019),'""') writpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.matpups_2019),'""') matpups_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.tfsm6cla1a),'""') tfsm6cla1a_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptfsm6cla1a),'""') ptfsm6cla1a_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptealgrp2),'""') ptealgrp2_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptnmob),'""') ptnmob_ks2,
	isnull(datalab.fos.setNonNumericsToNull(y0.tks1average),'""') tks1average,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_exp_2019),'""') ptrwm_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_high_2019),'""') ptrwm_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_exp_pp_2019),'""') ptrwm_exp_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_high_pp_2019),'""') ptrwm_high_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptread_exp_2019),'""') ptread_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptread_high_2019),'""') ptread_high_2019,
	'0' readprog_2019,		-- progress measures are manually set to the correct value of zero, as they aren't given in the p.t. files
	isnull(datalab.fos.setNonNumericsToNull(y0.ptwritta_exp_2019),'""') ptwritta_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptwritta_high_2019),'""') ptwritta_high_2019,
	'0' writprog_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptmat_exp_2019),'""') ptmat_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptmat_high_2019),'""') ptmat_high_2019,
	'0' matprog_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptgps_exp_2019),'""') ptgps_exp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptgps_high_2019),'""') ptgps_high_2019,
	isnull(datalab.fos.setNonNumericsToNull(y1.telig_2018),'""') telig_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.readpups_2018),'""') readpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.writpups_2018),'""') writpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.matpups_2018),'""') matpups_2018, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y1.ptrwm_exp_2018),'""') ptrwm_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptrwm_high_2018),'""') ptrwm_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptread_exp_2018),'""') ptread_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptread_high_2018),'""') ptread_high_2018,
	'0' readprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptwritta_exp_2018),'""') ptwritta_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptwritta_high_2018),'""') ptwritta_high_2018,
	'0' writprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptmat_exp_2018),'""') ptmat_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptmat_high_2018),'""') ptmat_high_2018,
	'0' matprog_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptgps_exp_2018),'""') ptgps_exp_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.ptgps_high_2018),'""') ptgps_high_2018,
	isnull(datalab.fos.setNonNumericsToNull(y2.telig_2017),'""') telig_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.readpups_2017),'""') readpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.writpups_2017),'""') writpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.matpups_2017),'""') matpups_2017, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y2.ptrwm_exp_2017),'""') ptrwm_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptrwm_high_2017),'""') ptrwm_high_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptread_exp_2017),'""') ptread_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptread_high_2017),'""') ptread_high_2017,
	'0' readprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptwritta_exp_2017),'""') ptwritta_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptwritta_high_2017),'""') ptwritta_high_2017,
	'0' writprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptmat_exp_2017),'""') ptmat_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptmat_high_2017),'""') ptmat_high_2017,
	'0' matprog_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptgps_exp_2017),'""') ptgps_exp_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.ptgps_high_2017),'""') ptgps_high_2017,
	isnull(cast((isnull(telig_2019,0)+isnull(telig_2018,0)+isnull(telig_2017,0))/3 as varchar(max)),'""') telig_3yr_2019,
	isnull(cast((isnull(readpups_2019,0)+isnull(readpups_2018,0)+isnull(readpups_2017,0))/3 as varchar(max)),'""') readpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(cast((isnull(writpups_2019,0)+isnull(writpups_2018,0)+isnull(writpups_2017,0))/3 as varchar(max)),'""') writpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(cast((isnull(matpups_2019,0)+isnull(matpups_2018,0)+isnull(matpups_2017,0))/3 as varchar(max)),'""') matpups_3yr_2019, --- will be hidden (required for funnel plot)
	isnull(datalab.fos.setNonNumericsToNull(y0.ptrwm_exp_3yr_2019),'""') ptrwm_exp_3yr_2019,
	'0' readprog_3yr_2019,
	'0' writprog_3yr_2019,
	'0' matprog_3yr_2019,
	isnull(datalab.fos.setNonNumericsToNull(a.total_absence),'""') total_absence,
	isnull(datalab.fos.setNonNumericsToNull(a.persistent_absence),'""') persistent_absence,
	'""' total_teachers,		-- NB: no school workforce national average figures added as they aren't broken down by phase
	'""' total_teachers_fte,
	'""' pupil_teacher_ratio,
	'""' assistant_teacher_ratio,
	'""' pct_teachers_qts,
	'""' pct_teachers_50,
	'""' pct_temp_posts,
	'""' pct_teachers_main,
	'""' pct_teachers_leadership,
	'""' mean_salary_teachers,
	'""' mean_sick_days,
	'""' income_per_pupil_2019,
	'""' income_per_pupil_2018,
	'""' income_per_pupil_2017
	-- '""' search_string
into datalab.fos.ks2_natavgs
from #ks2_y0 y0
	inner join #ks2_y1 y1 on
		y0.rectype=5 and y1.rectype=5
	inner join #ks2_y2 y2 on
		y0.rectype=5 and y2.rectype=5
	outer apply (
		select *
		from #absence
		where
			geographic_level='national' and
			school_type='state-funded primary'		-- NB: needs updating for KS2/KS4
	) a
order by y0.rectype desc


-- Remove trailing zeros from decimals (and decimal points, where applicable)
declare @i int=1
declare @j int
declare @column varchar(max)
declare @command varchar(max)
declare @command2 varchar(max)

set @j=(select count(1) from datalab.sys.columns c where c.object_id=object_id('datalab.fos.ks2'))

while @i<=@j
begin
	set @column=(select c.name from datalab.sys.columns c where c.object_id=object_id('datalab.fos.ks2') and c.column_id=@i)

	if @column!='establishmentname' and @column!='opendate'
		set @command='update datalab.fos.ks2 set ' + @column + ' = replace(rtrim(replace(' + @column + ', ''0'', '' '')), '' '', ''0'') where ' + @column + ' like ''%.%'''
		set @command2='update datalab.fos.ks2 set ' + @column + ' = substring(' + @column + ', 1, len(' + @column +') - 1) where ' + @column + ' like ''%.'''

		exec (@command)
		exec (@command2)

	set @i=@i+1;
end;
