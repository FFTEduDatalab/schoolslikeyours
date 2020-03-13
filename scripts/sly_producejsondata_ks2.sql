if object_id('datalab.fos.ks2_json', 'u') is not null
	drop table datalab.fos.ks2_json;

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
		when c.name = 'phase' then 'lookup'
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
		when c.name = 'schtype' then 0
		when c.name = 'phase' then 0
		when c.name = 'religiouscharacter_code' then 0
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
		when c.name='tks1average' then 'Key Stage 1 prior attainment average point score of the cohort at the end of Key Stage 2, 2018/19'
		when c.name='telig_2019' then 'Number of pupils at the end of Key Stage 2, 2018/19'
		when c.name='telig_3yr_2019' then 'Average number of pupils at the end of Key Stage 2, 2016/17-2018/19'
		when c.name='ptfsm6cla1a_ks2' then 'Percentage of pupils at the end of Key Stage 2 who are disadvantaged, 2018/19'		-- NB: this is different to pct_fsm6
		when c.name='ptealgrp2_ks2' then 'Percentage of pupils at the end of Key Stage 2 who have English as an additional language, 2018/19'
		when c.name='ptnmob_ks2' then 'Percentage of pupils at the end of Key Stage 2 who are non-mobile, 2018/19'
		when c.name='readprog_2019' then 'Reading progress measure, 2018/19'
		when c.name='writprog_2019' then 'Writing progress measure, 2018/19'
		when c.name='matprog_2019' then 'Maths progress measure, 2018/19'
		when c.name='ptrwm_exp_2019' then 'Percentage of pupils reaching the expected standard in reading, writing and maths, 2018/19'
		when c.name='ptrwm_high_2019' then 'Percentage of pupils achieving a high score in reading and maths and working at greater depth in writing, 2018/19'
		when c.name='ptrwm_exp_pp_2019' then 'Percentage of disadvantaged pupils reaching the expected standard in reading, writing and maths, 2018/19'
		when c.name='ptrwm_high_pp_2019' then 'Percentage of disadvantaged pupils achieving a high score in reading and maths and working at greater depth in writing, 2018/19'
		when c.name='ptread_exp_2019' then 'Percentage of pupils reaching the expected standard in reading, 2018/19'
		when c.name='ptread_high_2019' then 'Percentage of pupils achieving a high score in reading, 2018/19'
		when c.name='ptmat_exp_2019' then 'Percentage of pupils reaching the expected standard in maths, 2018/19'
		when c.name='ptmat_high_2019' then 'Percentage of pupils achieving a high score in maths, 2018/19'
		when c.name='ptwritta_exp_2019' then 'Percentage of pupils reaching the expected standard in writing, 2018/19'
		when c.name='ptwritta_high_2019' then 'Percentage of pupils working at greater depth in writing, 2018/19'
		when c.name='ptgps_exp_2019' then 'Percentage of pupils reaching the expected standard in grammar, punctuation and spelling, 2018/19'
		when c.name='ptgps_high_2019' then 'Percentage of pupils achieving a high score in grammar, punctuation and spelling, 2018/19'
		when c.name='ptrwm_exp_3yr_2019' then 'Percentage of pupils reaching the expected standard in reading, writing and maths, 2016/17-2018/19'
		when c.name='readprog_3yr_2019' then 'Reading progress measure, 2016/17-2018/19'
		when c.name='writprog_3yr_2019' then 'Writing progress measure, 2016/17-2018/19'
		when c.name='matprog_3yr_2019' then 'Maths progress measure, 2016/17-2018/19'
		when c.name='telig_2018' then 'Number of pupils at the end of Key Stage 2, 2017/18'
		when c.name='readprog_2018' then 'Reading progress measure, 2017/18'
		when c.name='writprog_2018' then 'Writing progress measure, 2017/18'
		when c.name='matprog_2018' then 'Maths progress measure, 2017/18'
		when c.name='ptrwm_exp_2018' then 'Percentage of pupils reaching the expected standard in reading, writing and maths, 2017/18'
		when c.name='ptrwm_high_2018' then 'Percentage of pupils achieving a high score in reading and maths and working at greater depth in writing, 2017/18'
		when c.name='ptread_exp_2018' then 'Percentage of pupils reaching the expected standard in reading, 2017/18'
		when c.name='ptread_high_2018' then 'Percentage of pupils achieving a high score in reading, 2017/18'
		when c.name='ptmat_exp_2018' then 'Percentage of pupils reaching the expected standard in maths, 2017/18'
		when c.name='ptmat_high_2018' then 'Percentage of pupils achieving a high score in maths, 2017/18'
		when c.name='ptwritta_exp_2018' then 'Percentage of pupils reaching the expected standard in writing, 2017/18'
		when c.name='ptwritta_high_2018' then 'Percentage of pupils working at greater depth in writing, 2017/18'
		when c.name='ptgps_exp_2018' then 'Percentage of pupils reaching the expected standard in grammar, punctuation and spelling, 2017/18'
		when c.name='ptgps_high_2018' then 'Percentage of pupils achieving a high score in grammar, punctuation and spelling, 2017/18'
		when c.name='telig_2017' then 'Number of pupils at the end of Key Stage 2, 2016/17'
		when c.name='readprog_2017' then 'Reading progress measure, 2016/17'
		when c.name='writprog_2017' then 'Writing progress measure, 2016/17'
		when c.name='matprog_2017' then 'Maths progress measure, 2016/17'
		when c.name='ptrwm_exp_2017' then 'Percentage of pupils reaching the expected standard in reading, writing and maths, 2016/17'
		when c.name='ptrwm_high_2017' then 'Percentage of pupils achieving a high score in reading and maths and working at greater depth in writing, 2016/17'
		when c.name='ptread_exp_2017' then 'Percentage of pupils reaching the expected standard in reading, 2016/17'
		when c.name='ptread_high_2017' then 'Percentage of pupils achieving a high score in reading, 2016/17'
		when c.name='ptmat_exp_2017' then 'Percentage of pupils reaching the expected standard in maths, 2016/17'
		when c.name='ptmat_high_2017' then 'Percentage of pupils achieving a high score in maths, 2016/17'
		when c.name='ptwritta_exp_2017' then 'Percentage of pupils reaching the expected standard in writing, 2016/17'
		when c.name='ptwritta_high_2017' then 'Percentage of pupils working at greater depth in writing, 2016/17'
		when c.name='ptgps_exp_2017' then 'Percentage of pupils reaching the expected standard in grammar, punctuation and spelling, 2016/17'
		when c.name='ptgps_high_2017' then 'Percentage of pupils achieving a high score in grammar, punctuation and spelling, 2016/17'
		when c.name='total_absence_2018' then 'Overall absence rate, 2017/18'
		when c.name='persistent_absence_2018' then 'Percentage of enrolments classed as persistent absentees (missing 10 percent or more of sessions), 2017/18'
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
		when c.name='income_per_pupil_2018' then 'Total income per pupil, 2017/18'
		when c.name='income_per_pupil_2017' then 'Total income per pupil, 2016/17'
		when c.name='income_per_pupil_2016' then 'Total income per pupil, 2015/16'
	end,
	case		-- group
		when c.name='la_code' then 'School characteristics'
		when c.name='gor_code' then 'School characteristics'
		when c.name='establishmentname' then 'School characteristics'
		when c.name='phase' then 'School characteristics'
		when c.name='religiouscharacter_code' then 'School characteristics'
		when c.name='urn' then 'School characteristics'
		when c.name='sch_id' then 'School characteristics'
		when c.name='schtype' then 'School characteristics'
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
		when c.name='telig_2019' then 'KS2 performance, 2019'
		when c.name='telig_3yr_2019' then 'KS2 performance, 2017-2019'
		when c.name='tks1average' then 'KS2 performance, 2019'
		when c.name='ptfsm6cla1a_ks2' then 'KS2 performance, 2019'		-- NB: this is different to pct_fsm6
		when c.name='ptealgrp2_ks2' then 'KS2 performance, 2019'
		when c.name='ptnmob_ks2' then 'KS2 performance, 2019'
		when c.name='readprog_2019' then 'KS2 performance, 2019'
		when c.name='writprog_2019' then 'KS2 performance, 2019'
		when c.name='matprog_2019' then 'KS2 performance, 2019'
		when c.name='ptrwm_exp_2019' then 'KS2 performance, 2019'
		when c.name='ptrwm_high_2019' then 'KS2 performance, 2019'
		when c.name='ptrwm_exp_pp_2019' then 'KS2 performance, 2019'
		when c.name='ptrwm_high_pp_2019' then 'KS2 performance, 2019'
		when c.name='ptread_exp_2019' then 'KS2 performance, 2019'
		when c.name='ptread_high_2019' then 'KS2 performance, 2019'
		when c.name='ptmat_exp_2019' then 'KS2 performance, 2019'
		when c.name='ptmat_high_2019' then 'KS2 performance, 2019'
		when c.name='ptwritta_exp_2019' then 'KS2 performance, 2019'
		when c.name='ptwritta_high_2019' then 'KS2 performance, 2019'
		when c.name='ptgps_exp_2019' then 'KS2 performance, 2019'
		when c.name='ptgps_high_2019' then 'KS2 performance, 2019'
		when c.name='ptrwm_exp_3yr_2019' then 'KS2 performance, 2017-2019'
		when c.name='readprog_3yr_2019' then 'KS2 performance, 2017-2019'
		when c.name='writprog_3yr_2019' then 'KS2 performance, 2017-2019'
		when c.name='matprog_3yr_2019' then 'KS2 performance, 2017-2019'
		when c.name='telig_2018' then 'KS2 performance, 2018'
		when c.name='readprog_2018' then 'KS2 performance, 2018'
		when c.name='writprog_2018' then 'KS2 performance, 2018'
		when c.name='matprog_2018' then 'KS2 performance, 2018'
		when c.name='ptrwm_exp_2018' then 'KS2 performance, 2018'
		when c.name='ptrwm_high_2018' then 'KS2 performance, 2018'
		when c.name='ptread_exp_2018' then 'KS2 performance, 2018'
		when c.name='ptread_high_2018' then 'KS2 performance, 2018'
		when c.name='ptmat_exp_2018' then 'KS2 performance, 2018'
		when c.name='ptmat_high_2018' then 'KS2 performance, 2018'
		when c.name='ptwritta_exp_2018' then 'KS2 performance, 2018'
		when c.name='ptwritta_high_2018' then 'KS2 performance, 2018'
		when c.name='ptgps_exp_2018' then 'KS2 performance, 2018'
		when c.name='ptgps_high_2018' then 'KS2 performance, 2018'
		when c.name='telig_2017' then 'KS2 performance, 2017'
		when c.name='readprog_2017' then 'KS2 performance, 2017'
		when c.name='writprog_2017' then 'KS2 performance, 2017'
		when c.name='matprog_2017' then 'KS2 performance, 2017'
		when c.name='ptrwm_exp_2017' then 'KS2 performance, 2017'
		when c.name='ptrwm_high_2017' then 'KS2 performance, 2017'
		when c.name='ptread_exp_2017' then 'KS2 performance, 2017'
		when c.name='ptread_high_2017' then 'KS2 performance, 2017'
		when c.name='ptmat_exp_2017' then 'KS2 performance, 2017'
		when c.name='ptmat_high_2017' then 'KS2 performance, 2017'
		when c.name='ptwritta_exp_2017' then 'KS2 performance, 2017'
		when c.name='ptwritta_high_2017' then 'KS2 performance, 2017'
		when c.name='ptgps_exp_2017' then 'KS2 performance, 2017'
		when c.name='ptgps_high_2017' then 'KS2 performance, 2017'
		when c.name='total_absence_2018' then 'Absence'
		when c.name='persistent_absence_2018' then 'Absence'
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
		when c.name='income_per_pupil_2018' then 'Finance'
		when c.name='income_per_pupil_2017' then 'Finance'
		when c.name='income_per_pupil_2016' then 'Finance'
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
		when c.name='tfsm6cla1a_ks2' then 1
		when c.name like 'readpups%' then 1
		when c.name like 'writpups%' then 1
		when c.name like 'matpups%' then 1
	end,
	case		-- isUnique
		when c.name='sch_id' then 1
		when c.name='urn' then 1
	end,
	case		-- isFilter
		when c.name='inResults' then 1
		when c.name='phase' then 1
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
		when c.name='telig_2019' then 1
		when c.name='tks1average' then 1
		when c.name='readprog_2019' then 1
		when c.name='writprog_2019' then 1
		when c.name='matprog_2019' then 1
	end,
	case		-- isDisplayable
		when c.name='grid_ref' then 0
	end,
	case		-- isContributor
		when c.name='telig_2019' then 1
		when c.name='tks1average' then 1
		when c.name='pct_fsm6' then 1
		when c.name='pct_eal' then 1
		when c.name='income_per_pupil_2018' then 1
	end,
	case		-- precision
		when c.name='pupils' then 0
		when c.name='comp_pupils' then 0
		when c.name like 'pct%' then 1
		when c.name='tks1average' then 1
		when c.name like 'pt%' then 0
		when c.name like 'telig%' then 0
		when c.name like 'readprog%' or c.name like 'writprog%' or c.name like 'matprog%' then 1
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
	object_id = object_id('datalab.fos.ks2')

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

update #meta set "lookup" = '["A1","Urban major conurbation"],["B1","Urban minor conurbation"],["C","Urban city and town"],["D","Rural town and fringe"],["E/F","Rural village/hamlet"],["99","Not known"]' where column_name = 'urbanrural_code';

set @string = null;
select @string = isnull(@string+',','')+'['+nullif(nullif(nullif(cast(organisation_id as varchar(max)),'NA'),'DNS'),'SUPP')+',"'+name+'"]'
from core.organisation.organisations
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

update #meta set "lookup" = '[1,"Yes"],[0,"No"]' where column_name = 'coastal';

update #meta set "lookup" = '[1,"Outstanding"],[2,"Good"],[3,"Requires improvement"],[4,"Inadequate"]' where column_name = 'latest_ofsted';

update #meta set "lookup" = '[3,"Community school"],[1,"Voluntary aided/voluntary controlled school"],[2,"Foundation school"],[4,"Converter academy/city technology college"],[5,"Sponsored academy"],[6,"Free school"],[7,"University technical college/studio school"]' where column_name = 'schtype';

update #meta set "lookup" = '[1,"Primary school"],[2,"Junior school"],[3,"Middle school (excluding first and middle)"],[4,"All-through school"]' where column_name = 'phase';

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
update #meta set chart='"xEnabled":true' where column_name='telig_2019';
update #meta set chart='"xEnabled":true' where column_name='readpups_2019';
update #meta set chart='"xEnabled":true' where column_name='writpups_2019';
update #meta set chart='"xEnabled":true' where column_name='matpups_2019';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptfsm6cla1a_ks2';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptealgrp2_ks2';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptnmob_ks2';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='tks1average';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptrwm_exp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptrwm_high_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 PP pupils, 2019"' where column_name='ptrwm_exp_pp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 PP pupils, 2019"' where column_name='ptrwm_high_pp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptread_exp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptread_high_2019';
update #meta set chart='"type":"funnel","stdDev":6.1736,"xEnabled":true,"defaultX":"KS2 reading pupils, 2019"' where column_name='readprog_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptwritta_exp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptwritta_high_2019';
update #meta set chart='"type":"funnel","stdDev":5.6941,"xEnabled":true,"defaultX":"KS2 writing pupils, 2019"' where column_name='writprog_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptmat_exp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptmat_high_2019';
update #meta set chart='"type":"funnel","stdDev":5.3899,"xEnabled":true,"defaultX":"KS2 maths pupils, 2019"' where column_name='matprog_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptgps_exp_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2019"' where column_name='ptgps_high_2019';
update #meta set chart='"xEnabled":true' where column_name='telig_2018';
update #meta set chart='"xEnabled":true' where column_name='readpups_2018';
update #meta set chart='"xEnabled":true' where column_name='writpups_2018';
update #meta set chart='"xEnabled":true' where column_name='matpups_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptrwm_exp_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptrwm_high_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptread_exp_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptread_high_2018';
update #meta set chart='"type":"funnel","stdDev":5.9912,"xEnabled":true,"defaultX":"KS2 reading pupils, 2018"' where column_name='readprog_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptwritta_exp_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptwritta_high_2018';
update #meta set chart='"type":"funnel","stdDev":5.7384,"xEnabled":true,"defaultX":"KS2 writing pupils, 2018"' where column_name='writprog_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptmat_exp_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptmat_high_2018';
update #meta set chart='"type":"funnel","stdDev":5.4322,"xEnabled":true,"defaultX":"KS2 maths pupils, 2018"' where column_name='matprog_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptgps_exp_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2018"' where column_name='ptgps_high_2018';
update #meta set chart='"xEnabled":true' where column_name='telig_2017';
update #meta set chart='"xEnabled":true' where column_name='readpups_2017';
update #meta set chart='"xEnabled":true' where column_name='writpups_2017';
update #meta set chart='"xEnabled":true' where column_name='matpups_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptrwm_exp_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptrwm_high_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptread_exp_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptread_high_2017';
update #meta set chart='"type":"funnel","stdDev":6.2246,"xEnabled":true,"defaultX":"KS2 reading pupils, 2017"' where column_name='readprog_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptwritta_exp_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptwritta_high_2017';
update #meta set chart='"type":"funnel","stdDev":6.0473,"xEnabled":true,"defaultX":"KS2 writing pupils, 2017"' where column_name='writprog_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptmat_exp_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptmat_high_2017';
update #meta set chart='"type":"funnel","stdDev":5.6229,"xEnabled":true,"defaultX":"KS2 maths pupils, 2017"' where column_name='matprog_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptgps_exp_2017';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017"' where column_name='ptgps_high_2017';
update #meta set chart='"xEnabled":true' where column_name='telig_3yr_2019';
update #meta set chart='"xEnabled":true' where column_name='readpups_3yr_2019';
update #meta set chart='"xEnabled":true' where column_name='writpups_3yr_2019';
update #meta set chart='"xEnabled":true' where column_name='matpups_3yr_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"KS2 pupils, 2017-2019"' where column_name='ptrwm_exp_3yr_2019';
update #meta set chart='"type":"funnel","stdDev":6.1298,"xEnabled":true,"defaultX":"KS2 reading pupils, 2017-2019"' where column_name='readprog_3yr_2019';
update #meta set chart='"type":"funnel","stdDev":5.8266,"xEnabled":true,"defaultX":"KS2 writing pupils, 2017-2019"' where column_name='writprog_3yr_2019';
update #meta set chart='"type":"funnel","stdDev":5.4817,"xEnabled":true,"defaultX":"KS2 maths pupils, 2017-2019"' where column_name='matprog_3yr_2019';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Compulsory school age pupils"' where column_name='total_absence_2018';
update #meta set chart='"type":"funnel","xEnabled":true,"defaultX":"Compulsory school age pupils"' where column_name='persistent_absence_2018';
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
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2016';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2017';
update #meta set chart='"type":"scatter","xEnabled":true,"defaultX":"Total pupils"' where column_name='income_per_pupil_2018';


-- Set column aliases, that show in the front-end
-- NB: Any changes made here will also need reflecting in the columns used as the basis for charts, and in any href references recorded above
update #meta set field_name = 'DfE number' where column_name = 'sch_id';
update #meta set field_name = 'URN' where column_name = 'urn';
update #meta set field_name = 'School name' where column_name = 'establishmentname';
update #meta set field_name = 'Local authority' where column_name = 'la_code';
update #meta set field_name = 'Region' where column_name = 'gor_code';
update #meta set field_name = 'Open date' where column_name = 'opendate';
update #meta set field_name = 'School type' where column_name = 'schtype';
update #meta set field_name = 'Phase' where column_name = 'phase';
update #meta set field_name = 'Religious character' where column_name = 'religiouscharacter_code';
update #meta set field_name = 'Area type' where column_name = 'urbanrural_code';
update #meta set field_name = 'Coastal' where column_name = 'coastal';
update #meta set field_name = 'Distance' where column_name = 'grid_ref';
update #meta set field_name = 'Capacity, %' where column_name = 'pct_capacity';
update #meta set field_name = 'Ofsted rating' where column_name = 'latest_ofsted';
update #meta set field_name = 'Total pupils' where column_name = 'pupils';
update #meta set field_name = 'Compulsory school age pupils' where column_name = 'comp_pupils';
update #meta set field_name = 'FSM, %' where column_name = 'pct_fsm';
update #meta set field_name = 'FSM6, %' where column_name = 'pct_fsm6';
update #meta set field_name = 'EAL, %' where column_name = 'pct_eal';
update #meta set field_name = 'White, %' where column_name = 'pct_white';
update #meta set field_name = 'Black, %' where column_name = 'pct_black';
update #meta set field_name = 'Asian, %' where column_name = 'pct_asian';
update #meta set field_name = 'Chinese, %' where column_name = 'pct_chinese';
update #meta set field_name = 'Mixed ethnicity, %' where column_name = 'pct_mixed';
update #meta set field_name = 'Other/unknown ethnicity, %' where column_name = 'pct_otherunclassified';
update #meta set field_name = 'KS2 pupils, 2019' where column_name = 'telig_2019';
update #meta set field_name = 'KS2 reading pupils, 2019' where column_name = 'readpups_2019';
update #meta set field_name = 'KS2 writing pupils, 2019' where column_name = 'writpups_2019';
update #meta set field_name = 'KS2 maths pupils, 2019' where column_name = 'matpups_2019';
update #meta set field_name = 'KS2 PP pupils, 2019' where column_name = 'tfsm6cla1a_ks2';
update #meta set field_name = 'KS2 PP pupils, 2019, %' where column_name = 'ptfsm6cla1a_ks2';
update #meta set field_name = 'KS2 EAL pupils, 2019, %' where column_name = 'ptealgrp2_ks2';
update #meta set field_name = 'KS2 non-mobile pupils, 2019, %' where column_name = 'ptnmob_ks2';
update #meta set field_name = 'Prior (KS1) attainment, 2019' where column_name = 'tks1average';
update #meta set field_name = 'RWM expected standard, 2019, %' where column_name = 'ptrwm_exp_2019';
update #meta set field_name = 'RWM high standard, 2019, %' where column_name = 'ptrwm_high_2019';
update #meta set field_name = 'PP RWM expected standard, 2019, %' where column_name = 'ptrwm_exp_pp_2019';
update #meta set field_name = 'PP RWM high standard, 2019, %' where column_name = 'ptrwm_high_pp_2019';
update #meta set field_name = 'Reading expected standard, 2019, %' where column_name = 'ptread_exp_2019';
update #meta set field_name = 'Reading high standard, 2019, %' where column_name = 'ptread_high_2019';
update #meta set field_name = 'Reading progress, 2019' where column_name = 'readprog_2019';
update #meta set field_name = 'Writing expected standard, 2019, %' where column_name = 'ptwritta_exp_2019';
update #meta set field_name = 'Writing high standard, 2019, %' where column_name = 'ptwritta_high_2019';
update #meta set field_name = 'Writing progress, 2019' where column_name = 'writprog_2019';
update #meta set field_name = 'Maths expected standard, 2019, %' where column_name = 'ptmat_exp_2019';
update #meta set field_name = 'Maths high standard, 2019, %' where column_name = 'ptmat_high_2019';
update #meta set field_name = 'Maths progress, 2019' where column_name = 'matprog_2019';
update #meta set field_name = 'GPS expected standard, 2019, %' where column_name = 'ptgps_exp_2019';
update #meta set field_name = 'GPS high standard, 2019, %' where column_name = 'ptgps_high_2019';
update #meta set field_name = 'KS2 pupils, 2018' where column_name = 'telig_2018';
update #meta set field_name = 'KS2 reading pupils, 2018' where column_name = 'readpups_2018';
update #meta set field_name = 'KS2 writing pupils, 2018' where column_name = 'writpups_2018';
update #meta set field_name = 'KS2 maths pupils, 2018' where column_name = 'matpups_2018';
update #meta set field_name = 'Reading progress, 2018' where column_name = 'readprog_2018';
update #meta set field_name = 'Writing progress, 2018' where column_name = 'writprog_2018';
update #meta set field_name = 'Maths progress, 2018' where column_name = 'matprog_2018';
update #meta set field_name = 'RWM expected standard, 2018, %' where column_name = 'ptrwm_exp_2018';
update #meta set field_name = 'RWM high standard, 2018, %' where column_name = 'ptrwm_high_2018';
update #meta set field_name = 'Reading expected standard, 2018, %' where column_name = 'ptread_exp_2018';
update #meta set field_name = 'Reading high standard, 2018, %' where column_name = 'ptread_high_2018';
update #meta set field_name = 'Maths expected standard, 2018, %' where column_name = 'ptmat_exp_2018';
update #meta set field_name = 'Maths high standard, 2018, %' where column_name = 'ptmat_high_2018';
update #meta set field_name = 'Writing expected standard, 2018, %' where column_name = 'ptwritta_exp_2018';
update #meta set field_name = 'Writing high standard, 2018, %' where column_name = 'ptwritta_high_2018';
update #meta set field_name = 'GPS expected standard, 2018, %' where column_name = 'ptgps_exp_2018';
update #meta set field_name = 'GPS high standard, 2018, %' where column_name = 'ptgps_high_2018';
update #meta set field_name = 'KS2 pupils, 2017' where column_name = 'telig_2017';
update #meta set field_name = 'KS2 reading pupils, 2017' where column_name = 'readpups_2017';
update #meta set field_name = 'KS2 writing pupils, 2017' where column_name = 'writpups_2017';
update #meta set field_name = 'KS2 maths pupils, 2017' where column_name = 'matpups_2017';
update #meta set field_name = 'Reading progress, 2017' where column_name = 'readprog_2017';
update #meta set field_name = 'Writing progress, 2017' where column_name = 'writprog_2017';
update #meta set field_name = 'Maths progress, 2017' where column_name = 'matprog_2017';
update #meta set field_name = 'RWM expected standard, 2017, %' where column_name = 'ptrwm_exp_2017';
update #meta set field_name = 'RWM high standard, 2017, %' where column_name = 'ptrwm_high_2017';
update #meta set field_name = 'Reading expected standard, 2017, %' where column_name = 'ptread_exp_2017';
update #meta set field_name = 'Reading high standard, 2017, %' where column_name = 'ptread_high_2017';
update #meta set field_name = 'Maths expected standard, 2017, %' where column_name = 'ptmat_exp_2017';
update #meta set field_name = 'Maths high standard, 2017, %' where column_name = 'ptmat_high_2017';
update #meta set field_name = 'Writing expected standard, 2017, %' where column_name = 'ptwritta_exp_2017';
update #meta set field_name = 'Writing high standard, 2017, %' where column_name = 'ptwritta_high_2017';
update #meta set field_name = 'GPS expected standard, 2017, %' where column_name = 'ptgps_exp_2017';
update #meta set field_name = 'GPS high standard, 2017, %' where column_name = 'ptgps_high_2017';
update #meta set field_name = 'KS2 pupils, 2017-2019' where column_name = 'telig_3yr_2019';
update #meta set field_name = 'KS2 reading pupils, 2017-2019' where column_name = 'readpups_3yr_2019';
update #meta set field_name = 'KS2 writing pupils, 2017-2019' where column_name = 'writpups_3yr_2019';
update #meta set field_name = 'KS2 maths pupils, 2017-2019' where column_name = 'matpups_3yr_2019';
update #meta set field_name = 'RWM expected standard, 2017-2019, %' where column_name = 'ptrwm_exp_3yr_2019';
update #meta set field_name = 'Reading progress, 2017-2019' where column_name = 'readprog_3yr_2019';
update #meta set field_name = 'Writing progress, 2017-2019' where column_name = 'writprog_3yr_2019';
update #meta set field_name = 'Maths progress, 2017-2019' where column_name = 'matprog_3yr_2019';
update #meta set field_name = 'Absence rate' where column_name = 'total_absence_2018';
update #meta set field_name = 'Persistent absentee rate' where column_name = 'persistent_absence_2018';
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
update #meta set field_name = 'Income, 2018' where column_name = 'income_per_pupil_2018';
update #meta set field_name = 'Income, 2017' where column_name = 'income_per_pupil_2017';
update #meta set field_name = 'Income, 2016' where column_name = 'income_per_pupil_2016';

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
	+schtype+','
	+phase+','
	+religiouscharacter_code+','
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
	+telig_2019+','
	+readpups_2019+','
	+writpups_2019+','
	+matpups_2019+','
	+tfsm6cla1a_ks2+','
	+ptfsm6cla1a_ks2+','
	+ptealgrp2_ks2+','
	+ptnmob_ks2+','
	+tks1average+','
	+ptrwm_exp_2019+','
	+ptrwm_high_2019+','
	+ptrwm_exp_pp_2019+','
	+ptrwm_high_pp_2019+','
	+ptread_exp_2019+','
	+ptread_high_2019+','
	+readprog_2019+','
	+ptwritta_exp_2019+','
	+ptwritta_high_2019+','
	+writprog_2019+','
	+ptmat_exp_2019+','
	+ptmat_high_2019+','
	+matprog_2019+','
	+ptgps_exp_2019+','
	+ptgps_high_2019+','
	+telig_2018+','
	+readpups_2018+','
	+writpups_2018+','
	+matpups_2018+','
	+ptrwm_exp_2018+','
	+ptrwm_high_2018+','
	+ptread_exp_2018+','
	+ptread_high_2018+','
	+readprog_2018+','
	+ptwritta_exp_2018+','
	+ptwritta_high_2018+','
	+writprog_2018+','
	+ptmat_exp_2018+','
	+ptmat_high_2018+','
	+matprog_2018+','
	+ptgps_exp_2018+','
	+ptgps_high_2018+','
	+telig_2017+','
	+readpups_2017+','
	+writpups_2017+','
	+matpups_2017+','
	+ptrwm_exp_2017+','
	+ptrwm_high_2017+','
	+ptread_exp_2017+','
	+ptread_high_2017+','
	+readprog_2017+','
	+ptwritta_exp_2017+','
	+ptwritta_high_2017+','
	+writprog_2017+','
	+ptmat_exp_2017+','
	+ptmat_high_2017+','
	+matprog_2017+','
	+ptgps_exp_2017+','
	+ptgps_high_2017+','
	+telig_3yr_2019+','
	+readpups_3yr_2019+','
	+writpups_3yr_2019+','
	+matpups_3yr_2019+','
	+ptrwm_exp_3yr_2019+','
	+readprog_3yr_2019+','
	+writprog_3yr_2019+','
	+matprog_3yr_2019+','
	+total_absence_2018+','
	+persistent_absence_2018+','
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
	+income_per_pupil_2018+','
	+income_per_pupil_2017+','
	+income_per_pupil_2016
	-- +',""'
	+']'
from
	datalab.fos.ks2_natavgs;

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
	+schtype+','
	+phase+','
	+religiouscharacter_code+','
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
	+telig_2019+','
	+readpups_2019+','
	+writpups_2019+','
	+matpups_2019+','
	+tfsm6cla1a_ks2+','
	+ptfsm6cla1a_ks2+','
	+ptealgrp2_ks2+','
	+ptnmob_ks2+','
	+tks1average+','
	+ptrwm_exp_2019+','
	+ptrwm_high_2019+','
	+ptrwm_exp_pp_2019+','
	+ptrwm_high_pp_2019+','
	+ptread_exp_2019+','
	+ptread_high_2019+','
	+readprog_2019+','
	+ptwritta_exp_2019+','
	+ptwritta_high_2019+','
	+writprog_2019+','
	+ptmat_exp_2019+','
	+ptmat_high_2019+','
	+matprog_2019+','
	+ptgps_exp_2019+','
	+ptgps_high_2019+','
	+telig_2018+','
	+readpups_2018+','
	+writpups_2018+','
	+matpups_2018+','
	+ptrwm_exp_2018+','
	+ptrwm_high_2018+','
	+ptread_exp_2018+','
	+ptread_high_2018+','
	+readprog_2018+','
	+ptwritta_exp_2018+','
	+ptwritta_high_2018+','
	+writprog_2018+','
	+ptmat_exp_2018+','
	+ptmat_high_2018+','
	+matprog_2018+','
	+ptgps_exp_2018+','
	+ptgps_high_2018+','
	+telig_2017+','
	+readpups_2017+','
	+writpups_2017+','
	+matpups_2017+','
	+ptrwm_exp_2017+','
	+ptrwm_high_2017+','
	+ptread_exp_2017+','
	+ptread_high_2017+','
	+readprog_2017+','
	+ptwritta_exp_2017+','
	+ptwritta_high_2017+','
	+writprog_2017+','
	+ptmat_exp_2017+','
	+ptmat_high_2017+','
	+matprog_2017+','
	+ptgps_exp_2017+','
	+ptgps_high_2017+','
	+telig_3yr_2019+','
	+readpups_3yr_2019+','
	+writpups_3yr_2019+','
	+matpups_3yr_2019+','
	+ptrwm_exp_3yr_2019+','
	+readprog_3yr_2019+','
	+writprog_3yr_2019+','
	+matprog_3yr_2019+','
	+total_absence_2018+','
	+persistent_absence_2018+','
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
	+income_per_pupil_2018+','
	+income_per_pupil_2017+','
	+income_per_pupil_2016
	-- +search_string
	+'],'
from datalab.fos.ks2;
