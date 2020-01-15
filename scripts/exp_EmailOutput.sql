if object_id('exp_EmailOutput') is not null
	exec ('drop procedure exp_EmailOutput')
GO

create procedure [dbo].[exp_EmailOutput] (
	@export_query varchar(max), 
	@export_title varchar(max) = 'MSA Report',
	@export_caption varchar(max) = 'MSA Report - Produced By SQL Server',
	@export_subtext_one varchar(max) = '',
	@export_subtext_two varchar(max) = '',
	@export_subtext_three varchar(max) = '',
	@export_output_type varchar(max) = 'pdf',
	@export_orderby_clause varchar(max) = '',
	@mail_recipients nvarchar(1000) = null,
	@mail_subject nvarchar(1000) = null,
	@mail_body nvarchar(1000) = null,
	@mail_format nvarchar(1000) = null,
	@mail_importance nvarchar(1000) = null,
	@mail_sensitivity nvarchar(1000) = null,
	@mailserver_host nvarchar(1000) = null,
	@mailserver_user nvarchar(1000) = null,
	@mailserver_pass nvarchar(1000) = null,
	@mailserver_reply nvarchar(1000) = null,
	@mailserver_display nvarchar(1000) = null,
	@mailserver_port int = null,
	@mailserver_ssl bit = null
) as

set nocount on;

if (@mailserver_host is null) set @mailserver_host = 'za-smtp-outbound-1.mimecast.co.za'
if (@mailserver_user is null) set @mailserver_user = 'rand@marketsa.co.za'
if (@mailserver_pass is null) set @mailserver_pass = '627ran!!'
if (@mailserver_reply is null) set @mailserver_reply = 'no-reply@marketsa.co.za'
if (@mailserver_display is null) set @mailserver_display = 'MSA Data Exports'
if (@mailserver_port is null) set @mailserver_port = 587
if (@mailserver_ssl is null) set @mailserver_ssl = 1

if (@mail_recipients is null) set @mail_recipients = @mailserver_user
if (@mail_subject is null) set @mail_subject = @export_title
if (@mail_body is null) set @mail_body = @export_caption
if (@mail_format is null) set @mail_format = 'HTML'
if (@mail_importance is null) set @mail_importance = 'High'
if (@mail_sensitivity is null) set @mail_sensitivity = 'Confidential'

declare @mailserver_desc varchar(1000) = 'EmailExport'
declare @mailserver_account varchar(1000) = @mailserver_desc + '_Account'
declare @mailserver_profile varchar(1000) = @mailserver_desc + '_Profile'

execute msdb.dbo.sysmail_add_account_sp
    @account_name = @mailserver_account,
    @description = @mailserver_desc,
	@username = @mailserver_user,
	@password = @mailserver_pass,
    @email_address = @mailserver_user,
    @replyto_address = @mailserver_reply,
    @display_name = @mailserver_display,
    @mailserver_name = @mailserver_host,
	@port = @mailserver_port,
	@enable_ssl = @mailserver_ssl;

declare @profile_id int;
select @profile_id = profile_id from msdb.dbo.sysmail_profile

execute msdb.dbo.sysmail_add_profile_sp
    @profile_name = @mailserver_profile,
    @description = @mailserver_desc;

execute msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @mailserver_profile,
    @account_name = @mailserver_account,
    @sequence_number = @profile_id;

execute msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = @mailserver_profile,
    @principal_id = 0,
    @is_default = 1 ;

exec msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder = 1

exec msdb.dbo.sp_set_sqlagent_properties 
	@databasemail_profile = @mailserver_profile, 
	@use_databasemail=1
	
declare @output varchar(1000);
if (@export_output_type = 'pdf')
begin
	exec exp_ExportToPDF @query = @export_query, 
						 @title = @export_title,
						 @caption = @export_caption,
						 @subtext_one = @export_subtext_one,
						 @subtext_two = @export_subtext_two,
						 @subtext_three = @export_subtext_three,
						 @output = @output output
end

if (@export_output_type = 'csv')
begin
	exec exp_ExportToCSV @query = @export_query, 
						 @title = @export_title,
						 @caption = @export_caption,
						 @subtext_one = @export_subtext_one,
						 @subtext_two = @export_subtext_two,
						 @subtext_three = @export_subtext_three,
						 @output = @output output
end

if (@export_output_type = 'xlsx')
begin
	exec exp_ExportToExcel @query = @export_query, 
						   @title = @export_title,
						   @caption = @export_caption,
						   @subtext_one = @export_subtext_one,
						   @subtext_two = @export_subtext_two,
						   @subtext_three = @export_subtext_three,
						   @output = @output output
end

if (@export_output_type = 'html')
begin
	exec exp_ExportToHtml @query = @export_query, 
						  @title = @export_title,
						  @caption = @export_caption,
						  @subtext_one = @export_subtext_one,
						  @subtext_two = @export_subtext_two,
						  @subtext_three = @export_subtext_three,
						  @output = @output output
end

exec msdb.dbo.sp_send_dbmail
    @profile_name = @mailserver_profile,
	@recipients = @mail_recipients,
	@body_format = @mail_format,
	@importance = @mail_importance,
	@sensitivity = @mail_sensitivity,
	@file_attachments = @output,
	@subject = @mail_subject,
	@body = @mail_body

waitfor delay '00:00:01'

exec msdb.dbo.sysmail_delete_profile_sp  @profile_name = @mailserver_profile
exec msdb.dbo.sysmail_delete_account_sp  @account_name  = @mailserver_account

GO