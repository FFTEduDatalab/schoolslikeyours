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
	laestab,
	count(1) count
from datalab.fos.ks2
group by laestab
having count(1)>1

select
	laestab,
	count(1) count
from datalab.fos.ks4
group by laestab
having count(1)>1

select
	laestab,
	count(1) count
from datalab.fos.special
group by laestab
having count(1)>1
