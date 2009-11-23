-- Dump of table tbl_permission
-- ------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tbl_permission]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tbl_permission]
GO

CREATE TABLE [dbo].[tbl_permission] (
  permission_id int IDENTITY NOT NULL,
  name varchar(50) NOT NULL default '',
  description varchar(100) NOT NULL default ''
)
GO

ALTER TABLE [dbo].[tbl_permission] 
	ADD CONSTRAINT PK_tbl_permission PRIMARY KEY (permission_id)
GO

INSERT INTO [dbo].[tbl_permission] (name,description) VALUES ('CREATE','create permission')
GO

INSERT INTO [dbo].[tbl_permission] (name,description) VALUES ('VIEW','view permission')
GO

INSERT INTO [dbo].[tbl_permission] (name,description) VALUES ('EDIT','edit permission')
GO

INSERT INTO [dbo].[tbl_permission] (name,description) VALUES ('DELETE','delete permission')
GO

INSERT INTO [dbo].[tbl_permission] (name,description) VALUES ('GRANT','grant permission')
GO

-- Dump of table tbl_role
-- ------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tbl_role]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tbl_role]
GO

CREATE TABLE [dbo].[tbl_role] (
  role_id int IDENTITY NOT NULL,
  name varchar(50) NOT NULL default '',
  description varchar(100) NOT NULL default ''
)
GO

ALTER TABLE [dbo].[tbl_role] 
	ADD CONSTRAINT PK_tbl_role PRIMARY KEY (role_id)
GO

INSERT INTO [dbo].[tbl_role] (name,description) VALUES ('Master','Full priviledge account.')
GO

INSERT INTO [dbo].[tbl_role] (name,description) VALUES ('Admin','Admin account with grant priviledge.')
GO

INSERT INTO [dbo].[tbl_role] (name,description) VALUES ('User','Normal user account.')
GO

INSERT INTO [dbo].[tbl_role] (name,description) VALUES ('Guest','Anonymous account.')
GO


-- Dump of table tbl_role_permission
-- ------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tbl_role_permission]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tbl_role_permission]
GO

CREATE TABLE [dbo].[tbl_role_permission] (
  role_id int NOT NULL,
  permission_id int NOT NULL
)
GO

CREATE INDEX IX_RoleId 
	ON [dbo].[tbl_role_permission] (role_id)
GO

CREATE INDEX IX_permission_id 
	ON [dbo].[tbl_role_permission] (permission_id)
GO

ALTER TABLE [dbo].[tbl_role_permission] 
	ADD CONSTRAINT PK_tbl_role_permission PRIMARY KEY (role_id,permission_id)
GO

ALTER TABLE [dbo].[tbl_role_permission] 
	ADD CONSTRAINT FK_role_permission_has_permission FOREIGN KEY (permission_id) 
		REFERENCES [dbo].[tbl_permission] (permission_id)
GO

ALTER TABLE [dbo].[tbl_role_permission] 
	ADD CONSTRAINT FK_role_permission_has_role FOREIGN KEY (role_id) 
		REFERENCES [dbo].[tbl_role] (role_id)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (1,1)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (1,2)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (1,3)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (1,4)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (1,5)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (2,2)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (2,3)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (2,4)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (2,5)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (3,2)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (3,3)
GO

INSERT INTO [dbo].[tbl_role_permission] (role_id,permission_id) VALUES (4,2)
GO


-- Dump of table tbl_user
-- ------------------------------------------------------------

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[tbl_user]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
drop table [dbo].[tbl_user]
GO

CREATE TABLE [dbo].[tbl_user] (
  user_id int IDENTITY NOT NULL,
  role_id int NOT NULL,
  first_name varchar(50) NOT NULL default '',
  last_name varchar(50) NOT NULL default '',
  email varchar(100) NOT NULL default '',
  username varchar(16) NOT NULL default '',
  password varchar(32) NOT NULL default '',
  is_enabled bit NOT NULL default 0,
  is_deleted bit NOT NULL default 0
)
GO

ALTER TABLE [dbo].[tbl_user] 
	ADD CONSTRAINT PK_tbl_user PRIMARY KEY (user_id)
GO

ALTER TABLE [dbo].[tbl_user] 
	ADD CONSTRAINT FK_user_has_role FOREIGN KEY (role_id) 
		REFERENCES [dbo].[tbl_role] (role_id)
GO
