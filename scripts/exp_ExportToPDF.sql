if object_id('exp_ExportToPDF') is not null
	exec ('drop procedure exp_ExportToPDF')
GO

create procedure [dbo].[exp_ExportToPDF]
(	@query varchar(max), 
	@title varchar(max) = 'MSA Report',
	@caption varchar(max) = 'MSA Report - Produced By SQL Server',
	@subtext_one varchar(max) = '',
	@subtext_two varchar(max) = '',
	@subtext_three varchar(max) = '',
	@output_path varchar(max) = '',
	@orderby_clause varchar(max) = '',  
	@output varchar(max) output 
)
as 
begin

	set nocount on;

	declare @ret_val int;
	exec @ret_val = exp_CheckDependencies
	if (@ret_val = 0)
		return;

	-- html elements
	declare @image varchar(max)
	declare @htmltemplate varchar(max)
	declare @header_rows varchar(max)
	declare @body_rows varchar(max)
	declare @css varchar(max)
	declare @csscellalign varchar(max)

	-- dynamic sql variables
	declare @table_expression nvarchar(max)
	declare @insert_expression nvarchar(max)
	declare @row_expression nvarchar(max)
	declare @html_expression nvarchar(max)
	declare @sqlcmd varchar(8000)

	-- uid and temp filepaths
	declare @uid varchar(max)
	declare @tempfolder varchar(260) = 'C:\mssql_exports\temp\'
	declare @tmp_html varchar(max)

	-- sql script creation variables
	declare @ole int
	declare @fileid int

	-- temp path ole variables
	declare @oleresult int
	declare @fs int
	declare @folder int 

	-- use random string to create temporary filepaths
	begin
		set @uid = left(lower(convert(varchar(255), newid())), 7)
		set @tmp_html = 'C:\mssql_exports\temp\' + @uid + '.html'
		if (@output_path = '') 
			set @output_path = replace(replace(@tmp_html, @uid, replace(@title, ' ', '') + '-' + dbo.exp_GenerateTimeString()), 'html', 'pdf')
	end

	-- set html constants 
	begin
		set @image = '<img src="data:image/png;base64,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" alt="">'
		set @htmltemplate = '
		<html>
			<head>{{css}}</head>
			<body>
			<div class="table-title">
				<div class="header">
					<h3>{{title}}</h3>
					<h5>{{caption}}
					<br />{{subtext_one}}
					<br />{{subtext_two}}
					<br />{{subtext_three}}</h5>
				</div>
				{{image}}
			</div>
			<div class="wrapper">
				<table class="table-fill">
					<thead>
						{{header_rows}}
					</thead>
					<tbody>
						{{body_rows}}
					</tbody>
					<tfoot>
						{{header_rows}}
					</tfoot>
				</table>
			</div>
			<br />
			<div class="info"></div>
			</body>
		</html>'
		set @css = '
		<style>
			body{
				font-size: 10px;
			}
			h3{
				font-size: 12px;
					margin-bottom: -15px;
					line-height: 2em;
			}
			h5{
				line-height: 1.5em;
					font-weight: 50;
			}
			div.table-title{
				display: block;
					margin: auto;
					max-width: 700px;
					width: 100%;
			}
			.info{
				display: block;
					margin: auto;
					max-width: 700px;
					width: 100%
			}
			img{
				display: block;
					width: 150px;
					float: right;
					padding-top: 8px;
			}
			caption{
				font-size: 12px;
					text-align: left;
					line-height: 100%;
					font-weight: 200;
			}
			.wrapper{
				padding: 1px;
					margin: auto;
					max-width: 700px;
					width: 100%
			}
			.table-title h3{
				color: black;
			}
			.header{
				display: inline-block;
					margin-top: -15px;
			}
			.table-fill{
				font-size: 8px;
					background: white;
					border-radius: 0;
					border-collapse: collapse;
					margin: auto;
					max-width: 700px;
					width: 100%
			}
			th{
				font-size: 9px;
					color: #D5DDE5;
					background: #000033;
					text-align: left;
					vertical-align: middle;
					border-right: 1px solid white;
			}
			.text-subtitle{
				color: #D5DDE5;
					background: #000033;
					text-align: left;
					vertical-align: middle
			}
			tr{
				color: black;
					font-size: 8px;
			}
			ul{
				margin-left: -30px;
			}
			tr:hover td{
				background: cornflowerblue;
					color: #FFF;
			}
			tr:nth-child(odd) td{
				background: #EBEBEB
			}
			tr:nth-child(odd):hover td{
				background: cornflowerblue;
			}
			td{
				background: #FFF;
					text-align: left;
					vertical-align: middle;
					border-right: 1px solid white;
			}'
	end

	-- set additional css to align numeric columns
	begin
		select @csscellalign = coalesce(isnull(@csscellalign,'') + 
			(case when lower(system_type_name) like '%int%' 
				   or lower(system_type_name) in ('float', 'decimal', 'money') 
				 then ', td:nth-child(0n+' + cast(column_ordinal AS varchar(6)) + ')'
			else 
				(case when lower(system_type_name) like '%date%' 
					 then 'td:nth-child(0n+' + cast(column_ordinal AS varchar(6)) + ')' 
				else '' end)
			end), '')
		from sys.dm_exec_describe_first_result_set(@query, NULL, 0) 
		where name is not null

		set @csscellalign = stuff(@csscellalign, 1, 2, '') + ' {
					text-align: right; 
					width: 60px;
				} 
			</style>'
		set @css = @css + isnull(@csscellalign, '</style>')
	end

	-- dynamically generate html string from query string
	begin
		select @header_rows = coalesce(isnull(@header_rows,'') + '<th>' + name + '</th>', '') 
		from sys.dm_exec_describe_first_result_set(@query, null, 0) as f 
		where name IS NOT NULL
		set @header_rows = '<tr>' + @header_rows + '</tr>'

		select @table_expression = coalesce(isnull(@table_expression,'') + ', [' + name + '] ' + system_type_name, '')
		from sys.dm_exec_describe_first_result_set(@query, null, 0)

		select @insert_expression = coalesce(isnull(@insert_expression,'') + ', [' + name + ']', '') 
		from sys.dm_exec_describe_first_result_set(@query, null, 0)

		set @table_expression = 'declare @table table (' + STUFF(@table_expression, 1,2,'') + ');'
			+ 'insert @table (' + stuff(@insert_expression, 1, 2, '') + ')'
			+ @query + ';'

		select @row_expression = coalesce(isnull(@row_expression,'') + 
			'''<td>'' + replace(dbo.exp_htmlEncode([' + name + ']), '''''''', '' '') + ''</td>'' ', '')
		from sys.dm_exec_describe_first_result_set(@query, null, 0) as f where name is not null

		set @row_expression = 'select @html = coalesce(@html + ''<tr>'' + ' + 
			replace(@row_expression, ' ''</td>'' ''<td>', ' ''</td>'' + ''<td>') + ' + ''</tr>'', '''') from @table ' + isnull(@orderby_clause, '')

		set @html_expression = @table_expression + @row_expression;

		set @body_rows = isnull(@body_rows, '')
		exec sp_executeSql @html_expression, N'@html nvarchar(max) = '''''''' output', @html = @body_rows output
	end
	
	-- replace variables into html template
	begin
		set @htmltemplate = REPLACE(@htmltemplate, '{{body_rows}}', isnull(@body_rows, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{header_rows}}', isnull(@header_rows, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{css}}', isnull(@css, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{image}}', isnull(@image, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{title}}', isnull(@title, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{caption}}', isnull(@caption, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{subtext_one}}', isnull(@subtext_one, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{subtext_two}}', isnull(@subtext_two, ''))
		set @htmltemplate = REPLACE(@htmltemplate, '{{subtext_three}}', isnull(@subtext_three, ''))
	end
	
	-- write temp html file to disk
	begin
		execute sp_oacreate 'scripting.filesystemobject', @ole out 
		execute sp_oamethod @ole, 'opentextfile', @fileid out, @tmp_html, 8, 1 
		execute sp_oamethod @fileid, 'writeline', null, @htmltemplate
		execute sp_oadestroy @fileid 
		execute sp_oadestroy @ole 
	end

	-- create cmd line string and execute with "wkhtmltopdf"
	begin
		declare @command varchar(2000) = 'wkhtmltopdf --title "{{title}}" "{{outputhtml}}" "{{outputpdf}}"'
		set @command = replace(@command, '{{title}}', @title)
		set @command = replace(@command, '{{outputhtml}}', @tmp_html)
		set @command = replace(@command, '{{outputpdf}}', @output_path)
		exec xp_cmdshell @command, no_output
	end

	-- delete temp file
	begin

		-- delete temp html file
		set @sqlcmd = 'del "{{TEMP.HTML}}"'
		set @sqlcmd = replace(@sqlcmd, '{{TEMP.HTML}}', @tmp_html)
		exec xp_cmdshell @sqlcmd, no_output

	end

	-- output save location
	begin
		select @output = @output_path
		print 'PDF File Saved at: "' + @output_path + '".'
	end
	
END

GO