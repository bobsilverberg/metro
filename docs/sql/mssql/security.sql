-- Dump of table tbl_audit
-- ------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tbl_audit]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tbl_audit]
GO

CREATE TABLE [dbo].[tbl_audit] (
  audit_id int IDENTITY NOT NULL,
  object_class varchar(50) NOT NULL default '',
  primary_key int NOT NULL,
  action varchar(10) NOT NULL default '',
  audit_date datetime NOT NULL default '0000-00-00',
  memento text NULL,
  user_id int NULL
)
GO

ALTER TABLE [dbo].[tbl_audit] 
	ADD CONSTRAINT PK_tbl_audit PRIMARY KEY (audit_id)
GO

ALTER TABLE [dbo].[tbl_audit] 
	ADD CONSTRAINT FK_audit_has_user FOREIGN KEY (user_id) 
		REFERENCES [dbo].[tbl_user] (user_id)
GO
