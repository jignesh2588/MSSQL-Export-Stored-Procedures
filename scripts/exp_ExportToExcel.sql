if object_id('exp_ExportToExcel') is not null
	exec ('drop procedure exp_ExportToExcel')
GO

create procedure [dbo].[exp_ExportToExcel] 
(	@query varchar(max), 
	@title varchar(max) = 'MSA Report',
	@caption varchar(max) = 'MSA Report - Produced By SQL Server',
	@subtext_one varchar(max) = '',
	@subtext_two varchar(max) = '',
	@subtext_three varchar(max) = '',
	@output_path varchar(max) = '',
	@orderby_clause varchar(max) = '',  
	@output varchar(max) output 
) as 

set nocount on; 

-- script variables
begin

	declare @ret_val int;
	exec @ret_val = exp_CheckDependencies
	if (@ret_val = 0)
		return;

	-- excel sheet name
	declare @sheetname nvarchar(max)

	-- nvarchar cast of query
	declare @nquery nvarchar(max) = cast(@query as nvarchar(max))

	-- dynamic sql variable
	declare @sqlcmd varchar(8000)

	-- uid and temp filepaths
	declare @uid varchar(max)
	declare @tempfolder varchar(260) = 'C:\mssql_exports\temp\'
	declare @tmp_sql varchar(max)
	declare @tmp_results varchar(max)
	declare @tmp_csv varchar(max)
	declare @tmp_xlsx varchar(max)

	-- sql script creation variables
	declare @ole int
	declare @fileid int

	-- temp path ole variables
	declare @oleresult int
	declare @fs int
	declare @folder int 

	-- table for insert into exec of query for column names
	declare @cols table (is_hidden bit,					column_ordinal int,
		name nvarchar(128),								is_nullable bit,
		system_type_id int,								system_type_name nvarchar(128),
		max_length smallint,							precision tinyint,
		scale tinyint,									collation_name nvarchar(128),
		user_type_id int,								user_type_database nvarchar(128),
		user_type_schema nvarchar(128),					user_type_name nvarchar(128),
		assembly_qualified_type_name nvarchar(4000),	xml_collection_id int,
		xml_collection_database nvarchar(128),			xml_collection_schema nvarchar(128),
		xml_collection_name nvarchar(128),				is_xml_document bit,
		is_case_sensitive bit,							is_fixed_length_clr_type bit,
		source_server nvarchar(128),					source_database nvarchar(128),
		source_schema nvarchar(128),					source_table nvarchar(128),
		source_column nvarchar(128),					is_identity_column bit,
		is_part_of_unique_key bit,						is_updateable bit,
		is_computed_column bit,							is_sparse_column_set bit,
		ordinal_in_order_by_list smallint,				order_by_is_descending bit,
		order_by_list_length smallint,					tds_type_id int,
		tds_length int,									tds_collation_id int,
		tds_collation_sort_id tinyint					)

	end

	-- temp file names
	begin

		-- use random string to create temporary filepaths
		set @uid = left(lower(convert(varchar(255), newid())), 7)
		set @tmp_sql = @tempfolder + @uid + '.sql'
		set @tmp_results = @tempfolder + @uid + '.tmp'
		set @tmp_csv = @tempfolder + @uid + '.csv'
		set @tmp_xlsx = @tempfolder + @uid + '.xlsx'
		if (@output_path = '') 
			set @output_path = replace(@tmp_xlsx, @uid, replace(@title, ' ', '') + '-' + dbo.exp_GenerateTimeString())

	end

	-- set nocount
	begin

		-- ensure no query output 
		if (@query not like '%set nocount on%') 
			set @query = 'set nocount on; ' + @query;

	end

	-- sql file
	begin

		-- create sql script file
		execute sp_oacreate 'scripting.filesystemobject', @ole out 
		execute sp_oamethod @ole, 'opentextfile', @fileid out, @tmp_sql, 8, 1 
		execute sp_oamethod @fileid, 'writeline', null, @query
		execute sp_oadestroy @fileid 
		execute sp_oadestroy @ole 

	end

	-- excel sheet name
	begin

		-- set sheet name using first column from query
		insert into @cols exec sp_describe_first_result_set @nquery
		select top 1 @sheetname = name + ' Data' from @cols

	end

	-- export query results
	begin

		-- use sqlcmd to execute query and output csv-like text file
		set @sqlcmd = 'sqlcmd -S localhost -d master -i "{{SCRIPT.SQL}}" -o "{{OUTPUT.TMP}}" -s "|" -W'
		set @sqlcmd = replace(@sqlcmd, '{{SCRIPT.SQL}}', @tmp_sql)
		set @sqlcmd = replace(@sqlcmd, '{{OUTPUT.TMP}}', @tmp_results)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- format output to csv
	begin

		-- use windows type command and find and replace command to remove header underline
		set @sqlcmd = 'type "{{OUTPUT.TMP}}" | findstr /V /c:"----" > "{{TEMP.CSV}}"'
		set @sqlcmd = replace(@sqlcmd, '{{OUTPUT.TMP}}', @tmp_results)
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.CSV}}', @tmp_csv)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- convert csv to xlsx
	begin

		-- use csv2xlsx binary to convert csv file to xlsx file
		set @sqlcmd = 'csv2xlsx -infile "{{TEMP.CSV}}" -outfile "{{TEMP.XLSX}}" -sheet "{{SHEETNAME}}" -silent'
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.CSV}}', @tmp_csv)
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.XLSX}}', @tmp_xlsx)
		set @sqlcmd = replace(@sqlcmd, '{{SHEETNAME}}', @sheetname)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- move output to output path
	begin

		-- use xcopy to move output to output path
		set @sqlcmd = 'echo f | xcopy /f /y "{{TEMP.XLSX}}" "{{EXPORT.XLSX}}"'
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.XLSX}}', @tmp_xlsx)
		set @sqlcmd = replace(@sqlcmd, '{{EXPORT.XLSX}}', @output_path)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- delete temp xlsx
	begin

		-- delete temp xlsx script
		set @sqlcmd = 'del "{{TEMP.XLSX}}"'
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.XLSX}}', @tmp_xlsx)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- delete temp script
	begin

		-- delete temp sql script
		set @sqlcmd = 'del "{{SCRIPT.SQL}}"'
		set @sqlcmd = replace(@sqlcmd, '{{SCRIPT.SQL}}', @tmp_sql)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- delete temp csv
	begin
	
		-- delete temp csv file
		set @sqlcmd = 'del "{{TEMP.CSV}}"'
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.CSV}}', @tmp_csv)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- delete temp output
	begin
	
		-- delete temp sql output file
		set @sqlcmd = 'del "{{OUTPUT.TMP}}"'
		set @sqlcmd = replace(@sqlcmd, '{{OUTPUT.TMP}}', @tmp_results)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- output save location
	begin
		select @output = @output_path
		print 'Excel File Saved at: "' + @output_path + '".'
	end

GO