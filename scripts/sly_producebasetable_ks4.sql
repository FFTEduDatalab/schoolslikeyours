---- GIAS
if object_id('tempdb.dbo.#base', 'u') is not null
	drop table #base;

select
	sch_id laestab,
	la_code,
	gor_code,
	establishmentname,
	case
		when gender_code=9 then 3
		else gender_code
	end gender_code,
	case
		when religiouscharacter_code in (2,34) then 1		-- Anglican/Church of England
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
	case when officialsixthform_code!=1 then 0 else officialsixthform_code end has_sixth_form,		-- Not applicable/Does not have a sixth form/null
	case admissionspolicy_code when 2 then 1 else 0 end grammar,
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
from public_data.organisation.gias
where
	ac_year=2019 and
	version=12 and
	establishmentstatus_code in (1,3) and
	statutoryhighage>15 and
	statutorylowage<16 and
	typeofestablishment_code in (1,2,3,5,6,28,34,35,40,41)


---- KS4
if object_id('tempdb.dbo.#ks4_y0', 'u') is not null
	drop table #ks4_y0;
if object_id('tempdb.dbo.#ks4_y1', 'u') is not null
	drop table #ks4_y1;
if object_id('tempdb.dbo.#ks4_y2', 'u') is not null
	drop table #ks4_y2;

select
	rectype,
	lea*10000 + estab orig_laestab,
	iclose,
	isnull(new_laestab,lea*10000+estab) laestab,
	tpup,
	cast(bpup as real)/cast(tpup as real) pct_boys,
	ks2aps,
	tfsm6cla1a,
	ptfsm6cla1a,
	ptealgrp2,
	ptnmob,
	ptebacc_e_ptq_ee,
	ebaccaps,
	ptebacc_efsm6cla1a_ptq_ee,
	ebaccaps_fsm6cla1a,
	att8scr a8,
	p8mea p8,
	p8pup,
	ptl2basics_94 basics,
	att8scr_fsm6cla1a a8_pp,
	p8mea_fsm6cla1a p8_pp,
	p8pup_fsm6cla1a p8pup_pp,
	ptfsm6cla1abasics_94 basics_pp,
	p8meaeng,
	p8meamat,
	p8meaebac,
	p8meaopen,
	tavent_e_3ng_ptq_ee tavent_e,
	tavent_g_ptq_ee tavent_g,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks4_y0
from public_data.pt.ks4final2019edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+f.estab=p.old_laestab
where
	rectype in (1,7) and
	(nftype!='FESI' or nftype is null) and
	tpup>0

select
	rectype,
	lea*10000 + estab orig_laestab,
	iclose,
	isnull(new_laestab,lea*10000+estab) laestab,
	tpup,
	att8scr a8,
	p8mea p8,
	p8pup,
	ptl2basics_94 basics,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks4_y1
from public_data.pt.ks4final2018edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+estab=old_laestab
where
	rectype in (1,7) and
	(nftype!='FESI' or nftype is null) and
	tpup>0

select
	rectype,
	lea*10000 + estab orig_laestab,
	iclose,
	isnull(new_laestab,lea*10000+estab) laestab,
	tpup,
	att8scr a8,
	p8mea p8,
	p8pup,
	ptl2basics_94 basics,
	count(1) over (partition by isnull(new_laestab,lea*10000+estab)) dups
into #ks4_y2
from public_data.pt.ks4final2017edited f
	left join public_data.organisation.predecessors p
		on f.lea*10000+estab=old_laestab
where
	rectype in (1,7) and
	(nftype!='FESI' or nftype is null) and
	tpup>0

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #ks4_y0 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #ks4_y0 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #ks4_y1 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #ks4_y1 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #ks4_y2 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #ks4_y2 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

--- Add schools to base which appear in y0 KS4 data
insert #base
select
	laestab,
	la_code,
	gor_code,
	establishmentname,
	gender_code,
	religiouscharacter_code,
	urn,
	schtype,
	has_sixth_form,
	grammar,
	urbanrural_code,
	easting,
	northing,
	opendate
from
(
select
	g.sch_id laestab,
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
	case officialsixthform_code when 2 then 0 else officialsixthform_code end has_sixth_form,
	case admissionspolicy_code when 2 then 1 else 0 end grammar,
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
from #ks4_y0 y
	inner join public_data.organisation.gias g on
		y.laestab=g.sch_id and
		ac_year=2018 and
		version=12 and
		statutoryhighage>=16
where
	iclose=0 and
	not exists (select * from #base b where b.laestab=y.laestab)
) q
where rowid=1


--- Characteristics
if object_id('tempdb.dbo.#context', 'u') is not null
	drop table #context;

select
	isnull(new_laestab,laestab) laestab,
	laestab orig_laestab,
    [% of pupils known to be eligible for free school meals] pct_fsm,
	e.pnumfsmever pct_fsm6,		-- this is a big misnomer in the p.t. census file!
	round(100*cast([number of pupils whose first language is known or believed to be other than english] as real)/nullif([headcount of pupils],0),1) pct_eal,
	nullif([headcount of pupils],0) pupils,
	cast([full time boys aged 11] as int)+cast([full time boys aged 12] as int)+cast([full time boys aged 13] as int)+
	cast([full time boys aged 14] as int)+cast([full time boys aged 15] as int)+cast([full-time girls aged 11] as int)+
	cast([full-time girls aged 12] as int)+cast([full-time girls aged 13] as int)+
	cast([full-time girls aged 14] as int)+cast([full-time girls aged 15] as int) as comp_pupils,
	case when cast([full time boys aged 11] as int)>=5 or cast([full-time girls aged 11] as int)>=5 then 1 else 0 end +		-- NB: this differs from KS2 and special code
	case when cast([full time boys aged 12] as int)>=5 or cast([full-time girls aged 12] as int)>=5 then 1 else 0 end +
	case when cast([full time boys aged 13] as int)>=5 or cast([full-time girls aged 13] as int)>=5 then 1 else 0 end +
	case when cast([full time boys aged 14] as int)>=5 or cast([full-time girls aged 14] as int)>=5 then 1 else 0 end +
	case when cast([full time boys aged 15] as int)>=5 or cast([full-time girls aged 15] as int)>=5 then 1 else 0 end as comp_cohorts,
	round(100*(cast([number of pupils classified as white british ethnic origin] as real) +
	cast([number of pupils classified as irish ethnic origin] as real) +
	cast([number of pupils classified as traveller of irish heritage ethnic origin] as real) +
	cast([number of pupils classified as any other white background ethnic origin] as real) +
	cast([number of pupils classified as gypsy roma ethnic origin] as real))
	/nullif([headcount of pupils],0),1) pct_white,
	round(100*(cast([number of pupils classified as white and black caribbean ethnic origin] as real) +
	cast([number of pupils classified as white and black african ethnic origin] as real) +
	cast([number of pupils classified as white and asian ethnic origin] as real) +
	cast([number of pupils classified as any other mixed background ethnic origin] as real))
	/nullif([headcount of pupils],0),1) pct_mixed,
	round(100*(cast([number of pupils classified as indian ethnic origin] as real)+
	cast([number of pupils classified as pakistani ethnic origin] as real)+
	cast([number of pupils classified as bangladeshi ethnic origin] as real)+
	cast([number of pupils classified as any other asian background ethnic origin] as real))
	/nullif([headcount of pupils],0),1) pct_asian,
	round(100*(cast([number of pupils classified as caribbean ethnic origin] as real)+
	cast([number of pupils classified as african ethnic origin] as real)+
	cast([number of pupils classified as any other black background ethnic origin] as real))
	/nullif([headcount of pupils],0),1) pct_black,
	round(100*cast([number of pupils classified as chinese ethnic origin] as real)/nullif([headcount of pupils],0),1) pct_chinese,
	round(100*(cast([number of pupils classified as any other ethnic group ethnic origin] as real) +
	cast([number of pupils unclassified] as real))
	/nullif([headcount of pupils],0),1) pct_otherunclassified,
	count(1) over (partition by isnull(new_laestab,laestab)) dups
into #context
from public_data.spc.udschoolspupils2020 c
	left join public_data.organisation.predecessors p on
		c.laestab=p.old_laestab
	left join public_data.pt.census2019 e on		-- NB: this is the latest data available
		c.laestab=concat(e.la,e.estab)

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #context a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #context c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

-- Update fsmever for schools which changed laestab
update c
set pct_fsm6=pnumfsmever
from #context c
	left join public_data.organisation.predecessors p
		on c.laestab=p.new_laestab
	left join public_data.pt.census2019 s
		on old_laestab=s.la*10000+estab
where
	pct_fsm6 is null and
	exists (select * from #base b where b.laestab=c.laestab)


--- Ofsted rating at end of year
if object_id('tempdb.dbo.#ofsted', 'u') is not null
	drop table #ofsted;

select
	o.laestab orig_laestab,
	isnull(cast(p.new_laestab as real),cast(o.laestab as real)) laestab,
	o.inspection_date,
	o.overall_effectiveness latest_ofsted,
	count(1) over (partition by isnull(p.new_laestab,o.laestab)) dups
into #ofsted
from public_data.ofsted.MIcompiled o
	left join public_data.organisation.predecessors p on
		o.laestab=p.old_laestab
where
	o.source_table='MI202008' and
	o.overall_effectiveness is not null

--- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #ofsted a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #ofsted c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


--- Workforce
if object_id('tempdb.dbo.#teachers', 'u') is not null
	drop table #teachers;
if object_id('tempdb.dbo.#swf', 'u') is not null
	drop table #swf;

select
	t.school_laestab laestab,
	sum(case
		when t.characteristic_group='Total' then cast(nullif(t.headcount,'c') as int)
		else null
	end) total_teachers,
	sum(case
		when t.characteristic_group='Total' then cast(nullif(t.full_time_equivalent,'c') as decimal(5,2))
		else null
	end) total_teachers_fte,
	sum(case
		when t.characteristic_group='QTS status' and t.characteristic='Qualified' then cast(nullif(t.full_time_equivalent,'c') as decimal(5,2))
		else null
	end) total_qualified_teachers_fte,
	sum(case
		when t.characteristic_group='age group' and t.characteristic in ('50 to 59','60 and over') then cast(nullif(t.full_time_equivalent,'c') as decimal(5,2))
		else null
	end) total_teachers_50plus_fte
into #teachers
from public_data.sw.teachers_characteristics_school2019 t
where
	t.time_period=201920
group by
	t.school_laestab

select
	isnull(cast(p.new_laestab as real), q.laestab) laestab,
	q.laestab orig_laestab,
	q.total_teachers,
	q.total_teachers_fte,
	q.pupil_teacher_ratio,
	cast(q.total_teaching_assistants_fte/q.total_teachers_fte as decimal(3,1)) assistant_teacher_ratio,
	cast(q.total_qualified_teachers_fte*1.0/q.total_teachers_fte as decimal(4,3)) pct_teachers_qts,
	cast(q.total_teachers_50plus_fte*1.0/q.total_teachers_fte as decimal(4,3)) pct_teachers_50,
	q.mean_salary_teachers,
	q.pct_teachers_leadership,
	q.mean_sick_days,
	q.pct_temp_posts,
	count(1) over (partition by isnull(p.new_laestab, q.laestab)) dups
into #swf
from
(select
	t.*,
	cast(nullif(a.full_time_equivalent,'c') as decimal(5,2)	) total_teaching_assistants_fte,
	cast(nullif(nullif(r.pupil_to_qual_unqual_teacher_ratio,'u'),':') as decimal(3,1)) pupil_teacher_ratio,
	cast(nullif(nullif(p.average_mean,'c'),':') as decimal(7,1)) mean_salary_teachers,
	cast(nullif(nullif(p.teachers_on_leadership_pay_range_percent,'c'),':')/100.0 as decimal(4,3)) pct_teachers_leadership,
	cast(nullif(nullif(s.averagenumberdaystaken,'c'),':') as decimal(3,1)) mean_sick_days,
	cast(nullif(v.temprate,':')/100.0 as decimal(4,3)) pct_temp_posts
from #teachers t
	left join public_data.sw.support_staff_characteristics_school2019 a on
		t.laestab=a.school_laestab and
		a.time_period=201920 and
		a.characteristic_group='post' and
		a.characteristic='teaching assistants'
	left join public_data.sw.pupil_teacher_ratio_2019 r on
		t.laestab=r.school_laestab and
		r.time_period=201920
	left join public_data.sw.teacher_pay_school2019 p on
		t.laestab=p.school_laestab and
		p.time_period=201920
	left join public_data.sw.teacher_sickness_absence_2019 s on
		t.laestab=s.laestab and
		s.time_period=201819		-- NB: sic - this is the latest year which the Nov 2019 school workforce survey collected
	left join public_data.sw.vacancies_2019 v on
		t.laestab=v.laestab and
		v.time_period=2019
) q
	left join public_data.organisation.predecessors p on
		q.laestab=p.old_laestab

--- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #swf a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #swf c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


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

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #absence a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #absence c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


-- Exclusions
if object_id('tempdb.dbo.#exclusions', 'u') is not null
	drop table #exclusions;

select
	geographic_level,
	school_type,
	isnull(cast(p.new_laestab as real), a.laestab) laestab,
	a.laestab orig_laestab,
	headcount,
	fixed_excl_rate fixed_excl,
	perm_excl_rate perm_excl,
	count(1) over (partition by isnull(cast(p.new_laestab as real), a.laestab)) dups		-- used to exclude schools that appear in source data more than once, on the grounds that there has e.g. been a merger, and using either individual record wouldn't be accurate
into #exclusions
from public_data.sfr.exclusions2019 a
	left join public_data.organisation.predecessors p
		on a.laestab=p.old_laestab
where
	a.geographic_level in ('national','school') and
	a.time_period='201819'

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #exclusions a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #exclusions c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


-- Finance
-- NB: Note difference in min/max thresholds applied between mainstream and special
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
	from public_data.finance.academiesIE2017 a
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
	from public_data.finance.cfrfull2017edited
	where
		isnumeric(number_of_pupils_fte)=1 and
		isnull(cast(number_of_pupils_fte as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and		-- NB: note difference between mainstream and special
	q.income_per_pupil<19000

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #finance_y2 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #finance_y2 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

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
	from public_data.finance.academiesIE2018 a
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
	from public_data.finance.cfrfull2018edited
	where
		isnumeric([Number of Pupils (FTE)])=1 and
		isnull(cast([Number of Pupils (FTE)] as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and		-- NB: note difference between mainstream and special
	q.income_per_pupil<19000

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #finance_y1 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #finance_y1 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn

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
	from public_data.finance.academiesIE2019 a
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
	from public_data.finance.cfrfull2019edited
	where
		isnumeric([No Pupils])=1 and
		isnull(cast([No Pupils] as real),0)!=0 and
		total_income_net>0
) q
	left join public_data.organisation.predecessors p
		on q.laestab=old_laestab
where
	q.income_per_pupil>2000 and		-- NB: note difference between mainstream and special
	q.income_per_pupil<19000

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #finance_y0 a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #finance_y0 c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


-- School capacity
if object_id('tempdb..#capacity') is not null
	drop table #capacity;

select
	isnull(cast(p.new_laestab as real), a.laestab) laestab,
	a.laestab orig_laestab,
	cast(maynor as real)/netcapacity pct_capacity,
	count(1) over (partition by isnull(p.new_laestab, a.laestab)) dups
into #capacity
from public_data.cap.school_capacity_2019 a
	left join public_data.organisation.predecessors p
		on a.laestab=p.old_laestab

-- laestab reversion
-- This formulation is required to handle the small number of cases where there is a one-to-many predecessor-successor relationship, and neither successor features in #base. In those instances, not updating dups results in us having two records with dups=1 but the same laestab
;with a as
(select
	a.laestab,
	a.orig_laestab,
	a.dups,
	row_number() over (partition by a.orig_laestab order by a.orig_laestab) rn		-- order is arbitrary, given we're talking about duplicates
from #capacity a
	inner join #base b on
		a.orig_laestab=b.laestab
where
	not exists (select * from #capacity c where c.laestab=b.laestab)
)
update a
set
	a.laestab=a.orig_laestab,
	a.dups=a.rn


-- Search strings
-- if object_id('tempdb..#search') is not null
-- 	drop table #search;
--
-- select
-- 	b.urn,
-- 	' '+upper(cast(n.establishmentname as varchar(max))
-- 	+' '+cast(la.name as varchar(max))
-- 	+' '+cast(b.laestab as varchar(max))
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
if object_id('datalab.fos.ks4', 'u') is not null
	drop table datalab.fos.ks4;
go

if object_id('datalab.fos.ks4_natavgs', 'u') is not null
	drop table datalab.fos.ks4_natavgs;
go

select
	cast(
		case
			when y0.tpup>5 then 1
			else 0
		end
	as varchar(max)) inResults,
	isnull(cast(b.laestab as varchar(max)),'""') laestab,
	isnull(cast(b.urn as varchar(max)),'""') urn,
	isnull('"' + datalab.fos.setNonNumericsToNull(s.establishmentname)+'"','""') establishmentname,
	isnull(cast(b.la_code as varchar(max)),'""') la_code,
	isnull('"' + datalab.fos.setNonNumericsToNull(b.gor_code)+'"','""') gor_code,
	isnull('"' + datalab.fos.setNonNumericsToNull(b.opendate)+'"','""') opendate,
	isnull(cast(b.gender_code as varchar(max)),'""') gender_code,
	isnull(cast(b.schtype as varchar(max)),'""') schtype,
	isnull(cast(b.grammar as varchar(max)),'""') grammar,
	isnull(cast(b.religiouscharacter_code as varchar(max)),'""') religiouscharacter_code,
	isnull(cast(b.has_sixth_form as varchar(max)),'""') has_sixth_form,
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
	isnull(datalab.fos.setNonNumericsToNull(y0.tpup),'""') tpup_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8pup),'""') p8pup_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8pup_pp),'""') p8pup_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.pct_boys),'""') pct_boys_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tfsm6cla1a),'""') tfsm6cla1a_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptfsm6cla1a),'""') ptfsm6cla1a_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptealgrp2),'""') ptealgrp2_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptnmob),'""') ptnmob_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ks2aps),'""') ks2aps,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptebacc_e_ptq_ee),'""') ptebacc_e_ptq_ee_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ebaccaps),'""') ebaccaps_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.a8),'""') a8_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8),'""') p8_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaeng),'""') p8meaeng_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meamat),'""') p8meamat_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaebac),'""') p8meaebac_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaopen),'""') p8meaopen_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.basics),'""') basics_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptebacc_efsm6cla1a_ptq_ee),'""') ptebacc_efsm6cla1a_ptq_ee_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ebaccaps_fsm6cla1a),'""') ebaccaps_fsm6cla1a_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.a8_pp),'""') a8_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8_pp),'""') p8_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.basics_pp),'""') basics_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tavent_g),'""') tavent_g_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tavent_e),'""') tavent_e_2019,
	isnull(datalab.fos.setNonNumericsToNull(y1.tpup),'""') tpup_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.p8pup),'""') p8pup_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.a8),'""') a8_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.p8),'""') p8_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.basics),'""') basics_2018,
	isnull(datalab.fos.setNonNumericsToNull(y2.tpup),'""') tpup_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.p8pup),'""') p8pup_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.a8),'""') a8_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.p8),'""') p8_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.basics),'""') basics_2017,
	isnull(datalab.fos.setNonNumericsToNull(a.total_absence),'""') total_absence,
	isnull(datalab.fos.setNonNumericsToNull(a.persistent_absence),'""') persistent_absence,
	isnull(datalab.fos.setNonNumericsToNull(w.total_teachers),'""') total_teachers,
	isnull(datalab.fos.setNonNumericsToNull(w.total_teachers_fte),'""') total_teachers_fte,
	isnull(datalab.fos.setNonNumericsToNull(w.pupil_teacher_ratio),'""') pupil_teacher_ratio,
	isnull(datalab.fos.setNonNumericsToNull(w.assistant_teacher_ratio),'""') assistant_teacher_ratio,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_qts),'""') pct_teachers_qts,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_50),'""') pct_teachers_50,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_temp_posts),'""') pct_temp_posts,
	isnull(datalab.fos.setNonNumericsToNull(w.pct_teachers_leadership),'""') pct_teachers_leadership,
	isnull(datalab.fos.setNonNumericsToNull(w.mean_salary_teachers),'""') mean_salary_teachers,
	isnull(datalab.fos.setNonNumericsToNull(w.mean_sick_days),'""') mean_sick_days,
	isnull(datalab.fos.setNonNumericsToNull(f0.income_per_pupil_2019),'""') income_per_pupil_2019,
	isnull(datalab.fos.setNonNumericsToNull(f1.income_per_pupil_2018),'""') income_per_pupil_2018,
	isnull(datalab.fos.setNonNumericsToNull(f2.income_per_pupil_2017),'""') income_per_pupil_2017,
	isnull(datalab.fos.setNonNumericsToNull(e.fixed_excl),'""') fixed_excl,
	isnull(datalab.fos.setNonNumericsToNull(e.perm_excl),'""') perm_excl
	-- '"' + isnull(#search.string, '') + '"' search_string
into datalab.fos.ks4
from #base b
	inner join datalab.fos.schoolnames20200801 s on
		b.urn=s.urn
	inner join #context c on
		b.laestab=c.laestab and c.dups=1
	left join #ofsted o on
		b.laestab=o.laestab and o.dups=1
	left join #ks4_y0 y0 on
		b.laestab=y0.laestab and y0.dups=1
	left join #ks4_y1 y1 on
		b.laestab=y1.laestab and y1.dups=1
	left join #ks4_y2 y2 on
		b.laestab=y2.laestab and y2.dups=1
	left join #swf w on
		b.laestab=w.laestab and w.dups=1
	left join #absence a on
		b.laestab=a.laestab and a.dups=1
	left join #exclusions e on
		b.laestab=e.laestab and e.dups=1
	left join #finance_y0 f0 on
		b.laestab=f0.laestab and f0.dups=1
	left join #finance_y1 f1 on
		b.laestab=f1.laestab and f1.dups=1
	left join #finance_y2 f2 on
		b.laestab=f2.laestab and f2.dups=1
	left join datalab.organisation.schoolxy_gias xy on
		b.laestab=xy.point_id
	left join #capacity cap on
		b.laestab=cap.laestab and cap.dups=1
	-- left join #search on
	-- 	b.urn=#search.urn

select
	'""' inResults,
	'""' laestab,
	'""' urn,
	'"England"' establishmentname,
	'""' la_code,
	'""' gor_code,
	'""' opendate,
	'""' gender_code,
	'""' schtype,
	'""' grammar,
	'""' religiouscharacter_code,
	'""' has_sixth_form,
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
	isnull(datalab.fos.setNonNumericsToNull(y0.tpup),'""') tpup_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8pup),'""') p8pup_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8pup_pp),'""') p8pup_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.pct_boys),'""') pct_boys_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tfsm6cla1a),'""') tfsm6cla1a_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptfsm6cla1a),'""') ptfsm6cla1a_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptealgrp2),'""') ptealgrp2_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptnmob),'""') ptnmob_ks4,
	isnull(datalab.fos.setNonNumericsToNull(y0.ks2aps),'""') ks2aps,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptebacc_e_ptq_ee),'""') ptebacc_e_ptq_ee_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ebaccaps),'""') ebaccaps_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.a8),'""') a8_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8),'""') p8_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaeng),'""') p8meaeng_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meamat),'""') p8meamat_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaebac),'""') p8meaebac_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8meaopen),'""') p8meaopen_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.basics),'""') basics_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ptebacc_efsm6cla1a_ptq_ee),'""') ptebacc_efsm6cla1a_ptq_ee_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.ebaccaps_fsm6cla1a),'""') ebaccaps_fsm6cla1a_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.a8_pp),'""') a8_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.p8_pp),'""') p8_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.basics_pp),'""') basics_pp_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tavent_g),'""') tavent_g_2019,
	isnull(datalab.fos.setNonNumericsToNull(y0.tavent_e),'""') tavent_e_2019,
	isnull(datalab.fos.setNonNumericsToNull(y1.tpup),'""') tpup_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.p8pup),'""') p8pup_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.a8),'""') a8_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.p8),'""') p8_2018,
	isnull(datalab.fos.setNonNumericsToNull(y1.basics),'""') basics_2018,
	isnull(datalab.fos.setNonNumericsToNull(y2.tpup),'""') tpup_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.p8pup),'""') p8pup_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.a8),'""') a8_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.p8),'""') p8_2017,
	isnull(datalab.fos.setNonNumericsToNull(y2.basics),'""') basics_2017,
	isnull(datalab.fos.setNonNumericsToNull(a.total_absence),'""') total_absence,
	isnull(datalab.fos.setNonNumericsToNull(a.persistent_absence),'""') persistent_absence,
	'""' total_teachers,		-- NB: no school workforce national average figures added as they aren't broken down by phase
	'""' total_teachers_fte,
	'""' pupil_teacher_ratio,
	'""' assistant_teacher_ratio,
	'""' pct_teachers_qts,
	'""' pct_teachers_50,
	'""' pct_temp_posts,
	'""' pct_teachers_leadership,
	'""' mean_salary_teachers,
	'""' mean_sick_days,
	'""' income_per_pupil_2019,
	'""' income_per_pupil_2018,
	'""' income_per_pupil_2017,
	isnull(datalab.fos.setNonNumericsToNull(e.fixed_excl),'""') fixed_excl,
	isnull(datalab.fos.setNonNumericsToNull(e.perm_excl),'""') perm_excl
	-- '""' search_string
into datalab.fos.ks4_natavgs
from #ks4_y0 y0
	inner join #ks4_y1 y1 on
		y0.rectype=7 and y1.rectype=7
	inner join #ks4_y2 y2 on
		y0.rectype=7 and y2.rectype=7
	outer apply (
		select *
		from #absence
		where
			geographic_level='national' and
			school_type='state-funded secondary'		-- NB: needs updating for KS2/KS4
	) a
	outer apply (
		select *
		from #exclusions
		where
			geographic_level='national' and
			school_type='state-funded secondary'
	) e
order by y0.rectype desc


-- Remove trailing zeros from decimals (and decimal points, where applicable)
declare @i int=1
declare @j int
declare @column varchar(max)
declare @command varchar(max)
declare @command2 varchar(max)

set @j=(select count(1) from datalab.sys.columns c where c.object_id=object_id('datalab.fos.ks4'))

while @i<=@j
begin
	set @column=(select c.name from datalab.sys.columns c where c.object_id=object_id('datalab.fos.ks4') and c.column_id=@i)

	if @column!='establishmentname' and @column!='opendate'
		set @command='update datalab.fos.ks4 set ' + @column + ' = replace(rtrim(replace(' + @column + ', ''0'', '' '')), '' '', ''0'') where ' + @column + ' like ''%.%'''
		set @command2='update datalab.fos.ks4 set ' + @column + ' = substring(' + @column + ', 1, len(' + @column +') - 1) where ' + @column + ' like ''%.'''

		exec (@command)
		exec (@command2)

	set @i=@i+1;
end;
