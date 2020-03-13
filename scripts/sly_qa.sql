-- Coverage
select
	count(1) count
from datalab.fos.ks2

select
	count(1) count
from datalab.fos.ks4

select
	count(1) count
from datalab.fos.special

-- Schools appearing twice
select
	sch_id,
	count(1) count
from datalab.fos.ks2
group by sch_id
having count(1)>1

select
	sch_id,
	count(1) count
from datalab.fos.ks4
group by sch_id
having count(1)>1

select
	sch_id,
	count(1) count
from datalab.fos.special
group by sch_id
having count(1)>1
