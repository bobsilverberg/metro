-- Dump of table tbl_employeetype
-- ------------------------------------------------------------

CREATE TABLE [dbo].[tbl_employeetype] (
  EmployeeTypeId int IDENTITY NOT NULL,
  Name varchar(50) NOT NULL default '',
  Description varchar(100) NOT NULL default ''
)
GO

ALTER TABLE [dbo].[tbl_employeetype] 
	ADD CONSTRAINT PK_tbl_employeetype PRIMARY KEY (EmployeeTypeId)
GO

INSERT INTO [dbo].[tbl_employeetype] (Name,Description) VALUES ('Manager','Someone who does little but makes a lot.')
GO

INSERT INTO [dbo].[tbl_employeetype] (Name,Description) VALUES ('Developer','Someone who writes software.')
GO

INSERT INTO [dbo].[tbl_employeetype] (Name,Description) VALUES ('Designer','Someone who makes things look pretty.')
GO



-- Dump of table tbl_departmemt
-- ------------------------------------------------------------

CREATE TABLE [dbo].[tbl_department] (
  DepartmentId int IDENTITY NOT NULL,
  Name varchar(50) NOT NULL default '',
  Description varchar(100) NOT NULL default ''
)
GO

ALTER TABLE [dbo].[tbl_department] 
	ADD CONSTRAINT PK_tbl_department PRIMARY KEY (DepartmentId)
GO

INSERT INTO [dbo].[tbl_department] (Name,Description) VALUES ('Sales','The sales force.')
GO

INSERT INTO [dbo].[tbl_department] (Name,Description) VALUES ('Accounting','Number crunchers.')
GO

INSERT INTO [dbo].[tbl_department] (Name,Description) VALUES ('Human Resources','Who know''s what they do?')
GO



-- Dump of table tbl_employee
-- ------------------------------------------------------------

CREATE TABLE [dbo].[tbl_employee] (
  UserName varchar(50) NOT NULL,
  EmployeeTypeId int NOT NULL,
  DepartmentId int NULL,
  FirstName varchar(50) NOT NULL default '',
  LastName varchar(50) NOT NULL default '',
  Active bit NOT NULL default 0,
  Underlings int NULL,
  FavouriteLanguage varchar(50) NULL,
  FavouriteColour varchar(50) NULL
)
GO

ALTER TABLE [dbo].[tbl_employee] 
	ADD CONSTRAINT PK_tbl_employee PRIMARY KEY (UserName)
GO

ALTER TABLE [dbo].[tbl_employee] 
	ADD CONSTRAINT FK_employee_has_type FOREIGN KEY (EmployeeTypeId) 
		REFERENCES [dbo].[tbl_employeetype] (EmployeeTypeId)
GO

ALTER TABLE [dbo].[tbl_employee] 
	ADD CONSTRAINT FK_employee_has_dept FOREIGN KEY (DepartmentId) 
		REFERENCES [dbo].[tbl_department] (DepartmentId)
GO

