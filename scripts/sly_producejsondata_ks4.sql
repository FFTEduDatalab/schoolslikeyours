if object_id('datalab.fos.ks4_json', 'u') is not null
	drop table datalab.fos.ks4_json;

if object_id('tempdb.dbo.#meta', 'u') is not null
	drop table #meta;
create table #meta (
	ndx int primary key,
	column_name sysname,
	field_name sysname,
	description varchar(max),
	[group] varchar(max),
	type varchar(32),
	sortLookup bit,
	href varchar(max),
	prefix varchar(max),
	isUnique bit,
	isContributor bit,
	isContributable bit,
	isFilter bit,
	isFilterable bit,
	isSearchable bit,
	isVisible bit,
	isDisplayable bit,
	hidden bit,
	weight real,
	defaultValue varchar(max),
	precision int,
	displayScale real,
	"lookup" varchar(max),
	showInHeader bit,
	targetValue bit,
	chart varchar(max),
	textReplacements varchar(max)
	);

insert #meta (
	ndx, column_name, field_name, type, sortLookup, description, [group], href, prefix, hidden, isUnique, isFilter, isFilterable, isVisible, isDisplayable, isContributor, precision, displayScale, showInHeader, targetValue, textReplacements
)
select
	column_id,		-- ndx
	c.name,		-- column_name
	c.name,		-- field_name
	case		-- type
		when c.name='inResults' then 'raw'
		when c.name in ('sch_id', 'urn') then 'id'
		when c.name in ('establishmentname') then 'name'
		when c.name like '%_code' then 'lookup'
		when c.name = 'schtype' then 'lookup'
		when c.name = 'has_sixth_form' then 'lookup'
		when c.name = 'grammar' then 'lookup'
		when c.name = 'latest_ofsted' then 'lookup'
		when c.name = 'grid_ref' then 'geographic'
		when c.name = 'coastal' then 'lookup'
		when c.name = 'opendate' then 'date'
		when c.name like 'pct%' then 'percent'
		when c.name like 'pt%' then 'percent'
		when c.name like '%absence%' then 'percent'
		when c.name like 'basics%' then 'percent'
		when c.name = 'total_teachers' then 'integer'
		-- when c.name = 'search_string' then 'search'
	end,
	case		-- sortLookup (1=sort by text, 0=sort by code)
		when c.name = 'la_code' then 1
		when c.name = 'gor_code' then 1
		when c.name = 'gender_code' then 1
		when c.name = 'schtype' then 0
		when c.name = 'grammar' then 0
		when c.name = 'religiouscharacter_code' then 0
		when c.name = 'has_sixth_form' then 0
		when c.name = 'urbanrural_code' then 0
		when c.name = 'coastal' then 0
		when c.name = 'latest_ofsted' then 0
	end,
	case		-- description
		when c.name='coastal' then 'Within 5.5 kilometres of the coast'
		when c.name='grid_ref' then 'Distance from your school in kilometres'
		when c.name='pct_fsm' then 'Percentage of pupils eligible for free school meals'		-- strictly fsm, not disadv
		when c.name='pct_fsm6' then 'Percentage of pupils eligible for free school meals in the past six years'
		when c.name='pct_eal' then 'Percentage of pupils who have English as an additional language'
		when c.name='pct_white' then 'Percentage of pupils who are white'
		when c.name='pct_black' then 'Percentage of pupils who are black'
		when c.name='pct_asian' then 'Percentage of pupils who are Asian'
		when c.name='pct_chinese' then 'Percentage of pupils who are Chinese'
		when c.name='pct_mixed' then 'Percentage of pupils who are of mixed ethnicity'
		when c.name='pct_otherunclassified' then 'Percentage of pupils of other, or unknown, ethnicity'
		when c.name='pupils' then 'Total number of pupils'
		when c.name='comp_pupils' then 'Number of pupils of compulsory school age'
		when c.name='pct_capacity' then 'Number of pupils on roll as a percentage of capacity'
		when c.name='latest_ofsted' then 'Ofsted rating at the end of 2018/19'
		when c.name='tpup_2019' then 'Number of pupils at the end of Key Stage 4, 2018/19'
		when c.name='p8pup_2019' then 'Number of pupils included in Progress 8 calculations, 2018/19'
		when c.name='p8pup_pp_2019' then 'Number of disadvantaged pupils included in Progress 8 calculations, 2018/19'
		when c.name='pct_boys_2019' then 'Percentage of pupils at the end of Key Stage 4 who are male, 2018/19'
		when c.name='ks2aps' then 'Key Stage 2 prior attainment average point score of the cohort at the end of Key Stage 4, 2018/19'
		when c.name='ptfsm6cla1a_ks4' then 'Percentage of pupils at the end of Key Stage 4 who are disadvantaged, 2018/19'
		when c.name='ptealgrp2_ks4' then 'Percentage of pupils at the end of Key Stage 4 who have English as an additional language, 2018/19'
		when c.name='ptnmob_ks4' then 'Percentage of pupils at the end of Key Stage 4 who are non-mobile, 2018/19'
		when c.name='ptebacc_e_ptq_ee_2019' then 'Percentage of pupils with entries in all EBacc subject areas, 2018/19'
		when c.name='ebaccaps_2019' then 'EBacc average point score, 2018/19'
		when c.name='ptebacc_efsm6cla1a_ptq_ee_2019' then 'Percentage of disadvantaged pupils with entries in all EBacc subject areas, 2018/19'
		when c.name='ebaccaps_fsm6cla1a_2019' then 'EBacc average point score, disadvantaged pupils, 2018/19'
		when c.name='a8_2019' then 'Attainment 8, 2018/19'
		when c.name='p8_2019' then 'Progress 8, 2018/19'
		when c.name='p8meaeng_2019' then 'Progress 8, English slot, 2018/19'
		when c.name='p8meamat_2019' then 'Progress 8, maths slot, 2018/19'
		when c.name='p8meaebac_2019' then 'Progress 8, EBacc slots, 2018/19'
		when c.name='p8meaopen_2019' then 'Progress 8, open slots, 2018/19'
		when c.name='basics_2019' then 'Basics (percentage of pupils achieving grades 9-4 in English and maths), 2018/19'
		when c.name='a8_pp_2019' then 'Attainment 8, disadvantaged pupils, 2018/19'
		when c.name='p8_pp_2019' then 'Progress 8, disadvantaged pupils, 2018/19'
		when c.name='basics_pp_2019' then 'Basics (percentage of pupils achieving grades 9-4 in English and maths), disadvantaged pupils, 2018/19'
		when c.name='tavent_g_2019' then 'Average number of GCSE entries per pupil, 2018/19'
		when c.name='tavent_e_2019' then 'Average number of GCSE and equivalents entries per pupil, 2018/19'
		when c.name='tpup_2018' then 'Number of pupils at the end of Key Stage 4, 2017/18'
		when c.name='p8pup_2018' then 'Number of pupils included in Progress 8 calculations, 2017/18'
		when c.name='a8_2018' then 'Attainment 8, 2017/18'
		when c.name='p8_2018' then 'Progress 8, 2017/18'
		when c.name='basics_2018' then 'Basics (percentage of pupils achieving grades 9-4 in English and maths), 2017/18'
		when c.name='tpup_2017' then 'Number of pupils at the end of Key Stage 4, 2016/17'
		when c.name='p8pup_2017' then 'Number of pupils included in Progress 8 calculations, 2016/17'
		when c.name='a8_2017' then 'Attainment 8, 2016/17'
		when c.name='p8_2017' then 'Progress 8, 2016/17'
		when c.name='basics_2017' then 'Basics (percentage of pupils achieving grades 9-4 in English and maths), 2016/17'
		when c.name='total_absence' then 'Overall absence rate, 2018/19'
		when c.name='persistent_absence' then 'Percentage of enrolments classed as persistent absentees (missing 10 percent or more of sessions), 2018/19'
		when c.name='total_teachers' then 'Total number of teachers'
		when c.name='total_teachers_fte' then 'Full-time equivalent teachers'
		when c.name='assistant_teacher_ratio' then 'Teaching assistant:teacher ratio'
		when c.name='pupil_teacher_ratio' then 'Pupil:teacher ratio'
		when c.name='pct_teachers_50' then 'Percentage of all teachers over the age of 50'
		when c.name='pct_teachers_qts' then 'Percentage of all teachers with qualified teacher status'
		when c.name='mean_salary_teachers' then 'Mean salary of all teachers'
		when c.name='pct_teachers_main' then 'Percentage of classroom teachers on the main pay scale'
		when c.name='pct_teachers_leadership' then 'Percentage of all teachers on the leadership pay scale'
		when c.name='mean_sick_days' then 'Mean number of teacher sick days (teachers taking sick leave)'
		when c.name='pct_temp_posts' then 'Percentage of full-time posts filled with temporary staff'
		when c.name='income_per_pupil_2019' then 'Total income per pupil, 2017/18'
		when c.name='income_per_pupil_2018' then 'Total income per pupil, 2016/17'
		when c.name='income_per_pupil_2017' then 'Total income per pupil, 2015/16'
		when c.name='fixed_excl' then 'Fixed period exclusions per 100 pupils, 2017/18'
		when c.name='perm_excl' then 'Permanent exclusions per 100 pupils, 2017/18'
	end,
	case		-- group
		when c.name='la_code' then 'School characteristics'
		when c.name='gor_code' then 'School characteristics'
		when c.name='establishmentname' then 'School characteristics'
		when c.name='gender_code' then 'School characteristics'
		when c.name='religiouscharacter_code' then 'School characteristics'
		when c.name='urn' then 'School characteristics'
		when c.name='sch_id' then 'School characteristics'
		when c.name='schtype' then 'School characteristics'
		when c.name='has_sixth_form' then 'School characteristics'
		when c.name='grammar' then 'School characteristics'
		when c.name='urbanrural_code' then 'School characteristics'
		when c.name='coastal' then 'School characteristics'
		when c.name='grid_ref' then 'School characteristics'
		when c.name='opendate' then 'School characteristics'
		when c.name='pct_fsm' then 'Pupil characteristics'
		when c.name='pct_fsm6' then 'Pupil characteristics'
		when c.name='pct_eal' then 'Pupil characteristics'
		when c.name='pct_white' then 'Pupil characteristics'
		when c.name='pct_black' then 'Pupil characteristics'
		when c.name='pct_asian' then 'Pupil characteristics'
		when c.name='pct_chinese' then 'Pupil characteristics'
		when c.name='pct_mixed' then 'Pupil characteristics'
		when c.name='pct_otherunclassified' then 'Pupil characteristics'
		when c.name='pupils' then 'Pupil characteristics'
		when c.name='comp_pupils' then 'Pupil characteristics'
		when c.name='pct_capacity' then 'School characteristics'
		when c.name='latest_ofsted' then 'School characteristics'
		when c.name='tpup_2019' then 'KS4 performance, 2019'
		when c.name='p8pup_2019' then 'KS4 performance, 2019'
		when c.name='p8pup_pp_2019' then 'KS4 performance, 2019'
		when c.name='pct_boys_2019' then 'KS4 performance, 2019'
		when c.name='ks2aps' then 'KS4 performance, 2019'
		when c.name='ptfsm6cla1a_ks4' then 'KS4 performance, 2019'
		when c.name='ptealgrp2_ks4' then 'KS4 performance, 2019'
		when c.name='ptnmob_ks4' then 'KS4 performance, 2019'
		when c.name='ptebacc_e_ptq_ee_2019' then 'KS4 performance, 2019'
		when c.name='ebaccaps_2019' then 'KS4 performance, 2019'
		when c.name='ptebacc_efsm6cla1a_ptq_ee_2019' then 'KS4 performance, 2019'
		when c.name='ebaccaps_fsm6cla1a_2019' then 'KS4 performance, 2019'
		when c.name='a8_2019' then 'KS4 performance, 2019'
		when c.name='p8_2019' then 'KS4 performance, 2019'
		when c.name='p8meaeng_2019' then 'KS4 performance, 2019'
		when c.name='p8meamat_2019' then 'KS4 performance, 2019'
		when c.name='p8meaebac_2019' then 'KS4 performance, 2019'
		when c.name='p8meaopen_2019' then 'KS4 performance, 2019'
		when c.name='basics_2019' then 'KS4 performance, 2019'
		when c.name='a8_pp_2019' then 'KS4 performance, 2019'
		when c.name='p8_pp_2019' then 'KS4 performance, 2019'
		when c.name='basics_pp_2019' then 'KS4 performance, 2019'
		when c.name='tavent_g_2019' then 'KS4 performance, 2019'
		when c.name='tavent_e_2019' then 'KS4 performance, 2019'
		when c.name='tpup_2018' then 'KS4 performance, 2018'
		when c.name='a8_2018' then 'KS4 performance, 2018'
		when c.name='p8pup_2018' then 'KS4 performance, 2018'
		when c.name='p8_2018' then 'KS4 performance, 2018'
		when c.name='basics_2018' then 'KS4 performance, 2018'
		when c.name='tpup_2017' then 'KS4 performance, 2017'
		when c.name='a8_2017' then 'KS4 performance, 2017'
		when c.name='p8pup_2017' then 'KS4 performance, 2017'
		when c.name='p8_2017' then 'KS4 performance, 2017'
		when c.name='basics_2017' then 'KS4 performance, 2017'
		when c.name='total_absence' then 'Absence'
		when c.name='persistent_absence' then 'Absence'
		when c.name='total_teachers' then 'Workforce'
		when c.name='total_teachers_fte' then 'Workforce'
		when c.name='assistant_teacher_ratio' then 'Workforce'
		when c.name='pupil_teacher_ratio' then 'Workforce'
		when c.name='pct_teachers_50' then 'Workforce'
		when c.name='pct_teachers_qts' then 'Workforce'
		when c.name='mean_salary_teachers' then 'Workforce'
		when c.name='pct_teachers_main' then 'Workforce'
		when c.name='pct_teachers_leadership' then 'Workforce'
		when c.name='mean_sick_days' then 'Workforce'
		when c.name='pct_temp_posts' then 'Workforce'
		when c.name='income_per_pupil_2019' then 'Finance'
		when c.name='income_per_pupil_2018' then 'Finance'
		when c.name='income_per_pupil_2017' then 'Finance'
		when c.name='fixed_excl' then 'Exclusions'
		when c.name='perm_excl' then 'Exclusions'
	end,
	case		-- href
		when c.name='establishmentname' then 'https://get-information-schools.service.gov.uk/Establishments/Establishment/Details/{URN}'
	end,
	case		-- prefix
		when c.name like 'income%' then '£'
		when c.name='mean_salary_teachers' then '£'
	end,
	case		-- hidden
		when c.name='inResults' then 1
		when c.name='tfsm6cla1a_ks4' then 1
	end,
	case		-- isUnique
		when c.name='sch_id' then 1
		when c.name='urn' then 1
	end,
	case		-- isFilter
		when c.name='inResults' then 1
		when c.name='gender_code' then 1
	end,
	case		-- isFilterable
		when c.name='sch_id' then 0
		when c.name='urn' then 0
		when c.name='establishmentname' then 0
		else 1
	end,
	case		-- isVisible
		when c.name='la_code' then 1
		when c.name='establishmentname' then 1
		when c.name='sch_id' then 1
		when c.name='schtype' then 1
		when c.name='tpup_2019' then 1
		when c.name='ks2aps' then 1
		when c.name='a8_2019' then 1
		when c.name='p8_2019' then 1
		when c.name='basics_2019' then 1
	end,
	case		-- isDisplayable
		when c.name='grid_ref' then 0
	end,
	case		-- isContributor
		when c.name='tpup_2019' then 1
		when c.name='ks2aps' then 1
		when c.name='pct_fsm6' then 1
		when c.name='pct_eal' then 1
		when c.name='income_per_pupil_2019' then 1
	end,
	case		-- precision, default=2
		when c.name='pupils' then 0
		when c.name='comp_pupils' then 0
		when c.name like 'pct%' then 1
		when c.name='ks2aps' then 1
		when c.name like 'pt%' then 0
		when c.name like 'tpup%' then 0
		when c.name like 'p8pup%' then 0
		when c.name like 'a8%' then 1
		when c.name like 'basics%' then 0
		when c.name like 'tavent%' then 1
		when c.name in ('total_teachers_fte','assistant_teacher_ratio','pupil_teacher_ratio','mean_sick_days') then 1
		when c.name='mean_salary_teachers' then 0
		when c.name like 'income%' then 0
		when c.name like 'grid_ref%' then 0
	end,
	case		-- displayScale
		when c.name='grid_ref' then 0.001
		when c.name in ('pct_fsm','pct_fsm6','pct_eal','pct_white','pct_black','pct_asian','pct_chinese','pct_mixed','pct_otherunclassified') then 1		-- needed to overrule default displayScale of 100 for columns with datatype of percent
	end,
	case		-- showInHeader
		when c.name='sch_id' then 1
		when c.name='urn' then 1
	end,
	case		-- targetValue
		when c.name='inResults' then 1
	end,
	case c.name -- textReplacements
		when 'search_string' then '{"CHURCH OF ENGLAND":"CE","COFE":"CE","ROMAN CATHOLIC":"RC","SAINT":"ST","AIDED":"","CONTROLLED":"","NURSERY":"","PRIMARY":"","SCHOOL":"","SECONDARY":"","VOLUNTARY":""}'
	end
from datalab.sys.columns c
	left join datalab.sys.types t
		on c.system_type_id = t.system_type_id
			and t.system_type_id = t.user_type_id
where
	object_id = object_id('datalab.fos.ks4')

union all

select
	999,		-- ndx
	'Difference',		-- column_name
	'Difference',		-- field_name
	null,		-- type
	null,		-- sortLookup
	'Measure of similarity',		-- description
	'School characteristics',		-- group
	null, 	-- href
	null, 	-- prefix
	null,		-- hidden
	null,		-- isUnique
	null, 	-- isFilter
	null,		-- isFilterable
	1,		-- isVisible
	null,		-- isDisplayable
	null,		-- isContributor
	2,		-- precision
	null,		-- displayScale
	null,		-- showInHeader
	null,		-- targetValue
	null		-- textReplacements
;

declare @string varchar(max);

update #meta set "lookup" = '[1,"Boys"],[2,"Girls"],[3,"Mixed"]' where column_name = 'gender_code';

update #meta set "lookup" = '["A1","Urban major conurbation"],["B1","Urban minor conurbation"],["C","Urban city and town"],["D","Rural town and fringe"],["E/F","Rural village/hamlet"],["99","Not known"]' where column_name = 'urbanrural_code';

set @string = null;
select @string = isnull(@string+',','')+'['+nullif(nullif(nullif(cast(organisation_id as varchar(max)),'NA'),'DNS'),'SUPP')+',"'+name+'"]'
from public_data.organisation.organisations
where organisation_id between 100 and 999;
update #meta set "lookup" = @string where column_name = 'la_code';

set @string = null;
select @string = isnull(@string+',','')+'["'+nullif(nullif(nullif(cast(gor_code as varchar(max)),'NA'),'DNS'),'SUPP')+'","'+gor_name+'"]'
from (
select distinct gor_code,gor_name
from public_data.organisation.GIAS
where gor_code is not null and gor_code not in ('W','Z')
) q;
update #meta set "lookup" = @string where column_name = 'gor_code';

update #meta set "lookup" = '[1,"Yes"],[0,"No"]' where column_name = 'has_sixth_form';

update #meta set "lookup" = '[1,"Yes"],[0,"No"]' where column_name = 'coastal';

update #meta set "lookup" = '[1,"Yes"],[0,"No"]' where column_name = 'grammar';

update #meta set "lookup" = '[1,"Outstanding"],[2,"Good"],[3,"Requires improvement"],[4,"Inadequate"]' where column_name = 'latest_ofsted';

update #meta set "lookup" = '[3,"Community school"],[1,"Voluntary aided/voluntary controlled school"],[2,"Foundation school"],[4,"Converter academy/city technology college"],[5,"Sponsored academy"],[6,"Free school"],[7,"University technical college/studio school"]' where column_name = 'schtype';

update #meta set "lookup" = '[1,"Church of England"],[2,"Catholic/Roman Catholic"],[3,"Other Christian"],[4,"Other"],[9,"None/not available"]' where column_name = 'religiouscharacter_code';

update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_capacity';
update #meta set chart='"xEnabled":true' where column_name='pupils';
update #meta set chart='"xEnabled":true' where column_name='comp_pupils';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_fsm';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_fsm6';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_eal';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_white';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_black';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_asian';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_chinese';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_mixed';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_otherunclassified';
update #meta set chart='"xEnabled":true' where column_name='tpup_2019';
update #meta set chart='"xEnabled":true' where column_name='p8pup_2019';
update #meta set chart='"xEnabled":true' where column_name='p8pup_pp_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pct_boys_2019';
update #meta set chart='"xEnabled":true' where column_name='tfsm6cla1a_ks4';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ptfsm6cla1a_ks4';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ptealgrp2_ks4';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ptnmob_ks4';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ks2aps';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ptebacc_e_ptq_ee_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='ebaccaps_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 PP pupils, 2019"' where column_name='ptebacc_etfsm6cla1a_ptq_ee_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 PP pupils, 2019"' where column_name='ebaccaps_tfsm6cla1a_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='a8_2019';
update #meta set chart='"type":"funnel","stdDev":1.282479,"xEnabled":true,"defaultX":"P8 pupils, 2019"' where column_name='p8_2019';
update #meta set chart='"type":"funnel","stdDev":1.546113,"xEnabled":true,"defaultX":"P8 pupils, 2019"' where column_name='p8meaeng_2019';
update #meta set chart='"type":"funnel","stdDev":1.365617,"xEnabled":true,"defaultX":"P8 pupils, 2019"' where column_name='p8meamat_2019';
update #meta set chart='"type":"funnel","stdDev":1.526479,"xEnabled":true,"defaultX":"P8 pupils, 2019"' where column_name='p8meaebac_2019';
update #meta set chart='"type":"funnel","stdDev":1.511807,"xEnabled":true,"defaultX":"P8 pupils, 2019"' where column_name='p8meaopen_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='basics_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 PP pupils, 2019"' where column_name='a8_pp_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"P8 PP pupils, 2019"' where column_name='p8_pp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 PP pupils, 2019"' where column_name='basics_pp_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='tavent_e_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2019"' where column_name='tavent_g_2019';
update #meta set chart='"xEnabled":true' where column_name='tpup_2018';
update #meta set chart='"xEnabled":true' where column_name='p8pup_2018';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2018"' where column_name='a8_2018';
update #meta set chart='"type":"funnel","stdDev":1.262617,"xEnabled":true,"defaultX":"P8 pupils, 2018"' where column_name='p8_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 pupils, 2018"' where column_name='basics_2018';
update #meta set chart='"xEnabled":true' where column_name='tpup_2017';
update #meta set chart='"xEnabled":true' where column_name='p8pup_2017';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS4 pupils, 2017"' where column_name='a8_2017';
update #meta set chart='"type":"funnel","stdDev":1.229722,"xEnabled":true,"defaultX":"P8 pupils, 2017"' where column_name='p8_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS4 pupils, 2017"' where column_name='basics_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Compulsory school age pupils"' where column_name='total_absence';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Compulsory school age pupils"' where column_name='persistent_absence';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='total_teachers';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='total_teachers_fte';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='pupil_teacher_ratio';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers, FTE"' where column_name='assistant_teacher_ratio';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers"' where column_name='pct_teachers_qts';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Teachers"' where column_name='pct_teachers_50';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers"' where column_name='pct_temp_posts';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers"' where column_name='pct_teachers_main';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Teachers"' where column_name='pct_teachers_leadership';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers"' where column_name='mean_salary_teachers';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Teachers"' where column_name='mean_sick_days';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2018';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2017';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='fixed_excl';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='perm_excl';


-- Set column aliases, that show in the front-end
-- NB: Any changes made here will also need reflecting in the columns used as the basis for charts, and in any href references recorded above
update #meta set field_name = 'DfE number' where column_name = 'sch_id';
update #meta set field_name = 'Local authority' where column_name = 'la_code';
update #meta set field_name = 'Region' where column_name = 'gor_code';
update #meta set field_name = 'School name' where column_name = 'establishmentname';
update #meta set field_name = 'Gender' where column_name = 'gender_code';
update #meta set field_name = 'Religious character' where column_name = 'religiouscharacter_code';
update #meta set field_name = 'URN' where column_name = 'urn';
update #meta set field_name = 'School type' where column_name = 'schtype';
update #meta set field_name = 'Sixth form' where column_name = 'has_sixth_form';
update #meta set field_name = 'Selective' where column_name = 'grammar';
update #meta set field_name = 'Area type' where column_name = 'urbanrural_code';
update #meta set field_name = 'Coastal' where column_name = 'coastal';
update #meta set field_name = 'Distance' where column_name = 'grid_ref';
update #meta set field_name = 'Open date' where column_name = 'opendate';
update #meta set field_name = 'FSM, %' where column_name = 'pct_fsm';
update #meta set field_name = 'FSM6, %' where column_name = 'pct_fsm6';
update #meta set field_name = 'EAL, %' where column_name = 'pct_eal';
update #meta set field_name = 'White, %' where column_name = 'pct_white';
update #meta set field_name = 'Black, %' where column_name = 'pct_black';
update #meta set field_name = 'Asian, %' where column_name = 'pct_asian';
update #meta set field_name = 'Chinese, %' where column_name = 'pct_chinese';
update #meta set field_name = 'Mixed ethnicity, %' where column_name = 'pct_mixed';
update #meta set field_name = 'Other/\u200Bunknown ethnicity, %' where column_name = 'pct_otherunclassified';
update #meta set field_name = 'Total pupils' where column_name = 'pupils';
update #meta set field_name = 'Compulsory school age pupils' where column_name = 'comp_pupils';
update #meta set field_name = 'Capacity, %' where column_name = 'pct_capacity';
update #meta set field_name = 'Ofsted rating' where column_name = 'latest_ofsted';
update #meta set field_name = 'KS4 pupils, 2019' where column_name = 'tpup_2019';
update #meta set field_name = 'P8 pupils, 2019' where column_name = 'p8pup_2019';
update #meta set field_name = 'P8 PP pupils, 2019' where column_name = 'p8pup_pp_2019';
update #meta set field_name = 'KS4 PP pupils, 2019' where column_name = 'tfsm6cla1a_ks4';
update #meta set field_name = 'KS4 male pupils, 2019, %' where column_name = 'pct_boys_2019';
update #meta set field_name = 'KS4 PP pupils, 2019, %' where column_name = 'ptfsm6cla1a_ks4';
update #meta set field_name = 'KS4 EAL pupils, 2019, %' where column_name = 'ptealgrp2_ks4';
update #meta set field_name = 'KS4 non-mobile pupils, 2019, %' where column_name = 'ptnmob_ks4';
update #meta set field_name = 'Prior (KS2) attainment, 2019' where column_name = 'ks2aps';
update #meta set field_name = 'EBacc entry rate, 2019' where column_name = 'ptebacc_e_ptq_ee_2019';
update #meta set field_name = 'EBacc APS, 2019' where column_name = 'ebaccaps_2019';
update #meta set field_name = 'PP EBacc entry rate, 2019' where column_name = 'ptebacc_efsm6cla1a_ptq_ee_2019';
update #meta set field_name = 'PP EBacc APS, 2019' where column_name = 'ebaccaps_fsm6cla1a_2019';
update #meta set field_name = 'Attainment 8, 2019' where column_name = 'a8_2019';
update #meta set field_name = 'Progress 8, 2019' where column_name = 'p8_2019';
update #meta set field_name = 'Progress 8, English slot, 2019' where column_name = 'p8meaeng_2019';
update #meta set field_name = 'Progress 8, maths slot, 2019' where column_name = 'p8meamat_2019';
update #meta set field_name = 'Progress 8, EBacc slots, 2019' where column_name = 'p8meaebac_2019';
update #meta set field_name = 'Progress 8, open slots, 2019' where column_name = 'p8meaopen_2019';
update #meta set field_name = 'Basics, 2019' where column_name = 'basics_2019';
update #meta set field_name = 'PP Progress 8, 2019' where column_name = 'p8_pp_2019';
update #meta set field_name = 'PP Attainment 8, 2019' where column_name = 'a8_pp_2019';
update #meta set field_name = 'PP Basics, 2019' where column_name = 'basics_pp_2019';
update #meta set field_name = 'Average entries, GCSEs, 2019' where column_name = 'tavent_g_2019';
update #meta set field_name = 'Average entries, GCSEs and equivalents, 2019' where column_name = 'tavent_e_2019';
update #meta set field_name = 'KS4 pupils, 2018' where column_name = 'tpup_2018';
update #meta set field_name = 'P8 pupils, 2018' where column_name = 'p8pup_2018';
update #meta set field_name = 'Attainment 8, 2018' where column_name = 'a8_2018';
update #meta set field_name = 'Progress 8, 2018' where column_name = 'p8_2018';
update #meta set field_name = 'Basics, 2018' where column_name = 'basics_2018';
update #meta set field_name = 'KS4 pupils, 2017' where column_name = 'tpup_2017';
update #meta set field_name = 'P8 pupils, 2017' where column_name = 'p8pup_2017';
update #meta set field_name = 'Attainment 8, 2017' where column_name = 'a8_2017';
update #meta set field_name = 'Progress 8, 2017' where column_name = 'p8_2017';
update #meta set field_name = 'Basics, 2017' where column_name = 'basics_2017';
update #meta set field_name = 'Absence rate' where column_name = 'total_absence';
update #meta set field_name = 'Persistent absentee rate' where column_name = 'persistent_absence';
update #meta set field_name = 'Teachers' where column_name = 'total_teachers';
update #meta set field_name = 'Teachers, FTE' where column_name = 'total_teachers_fte';
update #meta set field_name = 'Assistant:teacher ratio' where column_name = 'assistant_teacher_ratio';
update #meta set field_name = 'Pupil:teacher ratio' where column_name = 'pupil_teacher_ratio';
update #meta set field_name = 'Age 50+, %' where column_name = 'pct_teachers_50';
update #meta set field_name = 'Qualified teacher status, %' where column_name = 'pct_teachers_qts';
update #meta set field_name = 'Main pay scale, %' where column_name = 'pct_teachers_main';
update #meta set field_name = 'Leadership pay scale, %' where column_name = 'pct_teachers_leadership';
update #meta set field_name = 'Temporary staff, %' where column_name = 'pct_temp_posts';
update #meta set field_name = 'Mean salary' where column_name = 'mean_salary_teachers';
update #meta set field_name = 'Mean staff sick days' where column_name = 'mean_sick_days';
update #meta set field_name = 'Income, 2018' where column_name = 'income_per_pupil_2019';
update #meta set field_name = 'Income, 2017' where column_name = 'income_per_pupil_2018';
update #meta set field_name = 'Income, 2016' where column_name = 'income_per_pupil_2017';
update #meta set field_name = 'Fixed period exclusion rate, 2018' where column_name = 'fixed_excl';
update #meta set field_name = 'Permanent exclusion rate, 2018' where column_name = 'perm_excl';

declare @max int = (select max(ndx) from #meta);


-- EXPORT DATA
-- Meta
select
	json = '{"name":"'+field_name+'"'
	+isnull(',"type":"'+type+'"','')
	+isnull(',"sortLookup":'+case sortLookup when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"group":"'+[group]+'"','')
	+isnull(',"description":"'+description+'"','')
	+isnull(',"href":"'+href+'"','')
	+isnull(',"prefix":"'+prefix+'"','')
	+isnull(',"isUnique":'+case isUnique when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isContributor":'+case isContributor when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isContributable":'+case isContributable when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isFilter":'+case isFilter when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isFilterable":'+case isFilterable when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isSearchable":'+case isSearchable when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isVisible":'+case isVisible when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"isDisplayable":'+case isDisplayable when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"hidden":'+case hidden when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"weight":"'+nullif(nullif(nullif(cast(weight as varchar(max)),'NA'),'DNS'),'SUPP')+'"','')
	+isnull(',"defaultValue":"'+defaultValue+'"','')
	+isnull(',"precision":'+nullif(nullif(nullif(cast(precision as varchar(max)),'NA'),'DNS'),'SUPP')+'','')
	+isnull(',"displayScale":'+nullif(nullif(nullif(cast(displayScale as varchar(max)),'NA'),'DNS'),'SUPP')+'','')
	+isnull(',"lookup":['+"lookup"+']','')
	+isnull(',"showInHeader":'+case showInHeader when 1 then 'true' when 0 then 'false' end,'')
	+isnull(',"targetValue":'+cast(targetValue as varchar(20)),'')
	+isnull(',"chart":{'+"chart"+'}','')
	+isnull(',"textReplacements":'+textReplacements,'')
	+case ndx when @max then '}' else '},' end
from
	#meta
order by
	ndx
;

-- National averages
-- NB: order here needs to mirror that in source table, otherwise columns will be out of sync with the order specified in the metadata
select
	json = '['
	+inResults+','
	+sch_id+','
	+urn+','
	+establishmentname+','
	+la_code+','
	+gor_code+','
	+opendate+','
	+gender_code+','
	+schtype+','
	+grammar+','
	+religiouscharacter_code+','
	+has_sixth_form+','
	+urbanrural_code+','
	+coastal+','
	+grid_ref+','
	+pct_capacity+','
	+latest_ofsted+','
	+pupils+','
	+comp_pupils+','
	+pct_fsm+','
	+pct_fsm6+','
	+pct_eal+','
	+pct_white+','
	+pct_black+','
	+pct_asian+','
	+pct_chinese+','
	+pct_mixed+','
	+pct_otherunclassified+','
	+tpup_2019+','
	+p8pup_2019+','
	+p8pup_pp_2019+','
	+pct_boys_2019+','
	+tfsm6cla1a_ks4+','
	+ptfsm6cla1a_ks4+','
	+ptealgrp2_ks4+','
	+ptnmob_ks4+','
	+ks2aps+','
	+ptebacc_e_ptq_ee_2019+','
	+ebaccaps_2019+','
	+a8_2019+','
	+p8_2019+','
	+p8meaeng_2019+','
	+p8meamat_2019+','
	+p8meaebac_2019+','
	+p8meaopen_2019+','
	+basics_2019+','
	+ptebacc_efsm6cla1a_ptq_ee_2019+','
	+ebaccaps_fsm6cla1a_2019+','
	+a8_pp_2019+','
	+p8_pp_2019+','
	+basics_pp_2019+','
	+tavent_g_2019+','
	+tavent_e_2019+','
	+tpup_2018+','
	+p8pup_2018+','
	+a8_2018+','
	+p8_2018+','
	+basics_2018+','
	+tpup_2017+','
	+p8pup_2017+','
	+a8_2017+','
	+p8_2017+','
	+basics_2017+','
	+total_absence+','
	+persistent_absence+','
	+total_teachers+','
	+total_teachers_fte+','
	+pupil_teacher_ratio+','
	+assistant_teacher_ratio+','
	+pct_teachers_qts+','
	+pct_teachers_50+','
	+pct_temp_posts+','
	+pct_teachers_main+','
	+pct_teachers_leadership+','
	+mean_salary_teachers+','
	+mean_sick_days+','
	+income_per_pupil_2019+','
	+income_per_pupil_2018+','
	+income_per_pupil_2017+','
	+fixed_excl+','
	+perm_excl
	-- +',""'
	+']'
from
	datalab.fos.ks4_natavgs;

-- Full data
-- NB: shouldn't be used for production-ready data, as clean.exe needs to be used to produce a json file that fixes special character issues
-- NB: order here needs to mirror that in source table, otherwise columns will be out of sync from the order specified in the metadata
select
	json = '['
	+inResults+','
	+sch_id+','
	+urn+','
	+establishmentname+','
	+la_code+','
	+gor_code+','
	+opendate+','
	+gender_code+','
	+schtype+','
	+grammar+','
	+religiouscharacter_code+','
	+has_sixth_form+','
	+urbanrural_code+','
	+coastal+','
	+grid_ref+','
	+pct_capacity+','
	+latest_ofsted+','
	+pupils+','
	+comp_pupils+','
	+pct_fsm+','
	+pct_fsm6+','
	+pct_eal+','
	+pct_white+','
	+pct_black+','
	+pct_asian+','
	+pct_chinese+','
	+pct_mixed+','
	+pct_otherunclassified+','
	+tpup_2019+','
	+p8pup_2019+','
	+p8pup_pp_2019+','
	+pct_boys_2019+','
	+tfsm6cla1a_ks4+','
	+ptfsm6cla1a_ks4+','
	+ptealgrp2_ks4+','
	+ptnmob_ks4+','
	+ks2aps+','
	+ptebacc_e_ptq_ee_2019+','
	+ebaccaps_2019+','
	+a8_2019+','
	+p8_2019+','
	+p8meaeng_2019+','
	+p8meamat_2019+','
	+p8meaebac_2019+','
	+p8meaopen_2019+','
	+basics_2019+','
	+ptebacc_efsm6cla1a_ptq_ee_2019+','
	+ebaccaps_fsm6cla1a_2019+','
	+a8_pp_2019+','
	+p8_pp_2019+','
	+basics_pp_2019+','
	+tavent_g_2019+','
	+tavent_e_2019+','
	+tpup_2018+','
	+p8pup_2018+','
	+a8_2018+','
	+p8_2018+','
	+basics_2018+','
	+tpup_2017+','
	+p8pup_2017+','
	+a8_2017+','
	+p8_2017+','
	+basics_2017+','
	+total_absence+','
	+persistent_absence+','
	+total_teachers+','
	+total_teachers_fte+','
	+pupil_teacher_ratio+','
	+assistant_teacher_ratio+','
	+pct_teachers_qts+','
	+pct_teachers_50+','
	+pct_temp_posts+','
	+pct_teachers_main+','
	+pct_teachers_leadership+','
	+mean_salary_teachers+','
	+mean_sick_days+','
	+income_per_pupil_2019+','
	+income_per_pupil_2018+','
	+income_per_pupil_2017+','
	+fixed_excl+','
	+perm_excl
	-- +search_string
	+'],'
from datalab.fos.ks4;
