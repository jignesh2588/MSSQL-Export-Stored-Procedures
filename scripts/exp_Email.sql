if object_id('exp_Email') is not null
	exec ('drop procedure exp_Email')
GO

create procedure [dbo].[exp_Email] (
	@mail_recipients nvarchar(1000) = null,
	@mail_subject nvarchar(1000) = null,
	@mail_body nvarchar(1000) = null,
	@mail_attachments nvarchar(1000) = null,
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

if (@mailserver_host is null) set @mailserver_host = 'smtp.server.com'
if (@mailserver_user is null) set @mailserver_user = 'user@server.com'
if (@mailserver_pass is null) set @mailserver_pass = 'password'
if (@mailserver_reply is null) set @mailserver_reply = 'no-reply@server.com'
if (@mailserver_display is null) set @mailserver_display = 'sender_alias'
if (@mailserver_port is null) set @mailserver_port = 587
if (@mailserver_ssl is null) set @mailserver_ssl = 1

if (@mail_recipients is null) set @mail_recipients = @mailserver_user
if (@mail_subject is null) set @mail_subject = @mailserver_display
if (@mail_body is null) set @mail_body = ''
if (@mail_format is null) set @mail_format = 'HTML'
if (@mail_importance is null) set @mail_importance = 'High'
if (@mail_sensitivity is null) set @mail_sensitivity = 'Confidential'
if (@mail_attachments is null) set @mail_attachments = ''

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

exec msdb.dbo.sp_send_dbmail
    @profile_name = @mailserver_profile,
	@recipients = @mail_recipients,
	@body_format = @mail_format,
	@importance = @mail_importance,
	@sensitivity = @mail_sensitivity,
	@file_attachments = @mail_attachments,
	@subject = @mail_subject,
	@body = @mail_body

waitfor delay '00:00:01'

exec msdb.dbo.sysmail_delete_profile_sp  @profile_name = @mailserver_profile
exec msdb.dbo.sysmail_delete_account_sp  @account_name  = @mailserver_account

