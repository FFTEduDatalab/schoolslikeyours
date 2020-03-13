use datalab
go

drop function fos.setNonNumericsToNull
go

create function setNonNumericsToNull(@Text as varchar(8000))
returns varchar(8000)
as
begin
	declare @Ret varchar(8000);

	select @Ret=nullif(nullif(nullif(nullif(nullif(nullif(nullif(nullif(cast(@Text as varchar(max)),'NA'),'DNS'),'SUPP'),'x'),'..'),'.'),'>'),'')
	return @Ret
end
go

alter schema fos transfer [FFT\PNye].setNonNumericsToNull
