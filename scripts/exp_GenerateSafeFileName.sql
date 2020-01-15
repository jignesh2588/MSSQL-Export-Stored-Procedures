if object_id('exp_GenerateTimeString') is not null
	exec ('drop function exp_GenerateTimeString')
GO

create function [dbo].[exp_GenerateTimeString] ()
returns varchar(max)
as
begin
	return replace(replace(replace(replace(convert(varchar(23), getdate(), 126), '-', ''), ':', ''), '.', ''), 'T', '');
end