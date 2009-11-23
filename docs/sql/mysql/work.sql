SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS tbl_employeetype;

CREATE TABLE tbl_employeetype (
  EmployeeTypeId int NOT NULL auto_increment,
  Name varchar(50) NOT NULL default '',
  Description varchar(100) NOT NULL default '',
  PRIMARY KEY PK_tbl_employeetype (EmployeeTypeId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tbl_employeetype (Name,Description) VALUES ('Manager','Someone who does little but makes a lot.');

INSERT INTO tbl_employeetype (Name,Description) VALUES ('Developer','Someone who writes software.');

INSERT INTO tbl_employeetype (Name,Description) VALUES ('Designer','Someone who makes things look pretty.');

DROP TABLE IF EXISTS tbl_department;

CREATE TABLE tbl_department (
  DepartmentId int NOT NULL auto_increment,
  Name varchar(50) NOT NULL default '',
  Description varchar(100) NOT NULL default '',
  PRIMARY KEY PK_tbl_department (DepartmentId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tbl_department (Name,Description) VALUES ('Sales','The sales force.');

INSERT INTO tbl_department (Name,Description) VALUES ('Accounting','Number crunchers.');

INSERT INTO tbl_department (Name,Description) VALUES ('Human Resources','Who know''s what they do?');

DROP TABLE IF EXISTS tbl_employee;

CREATE TABLE tbl_employee (
  UserName varchar(50) NOT NULL,
  EmployeeTypeId int NOT NULL,
  DepartmentId int NULL,
  FirstName varchar(50) NOT NULL default '',
  LastName varchar(50) NOT NULL default '',
  Active bit NOT NULL default 0,
  Underlings int NULL,
  FavouriteLanguage varchar(50) NULL,
  FavouriteColour varchar(50) NULL,
  PRIMARY KEY PK_tbl_employee (UserName),
  KEY ix_EmployeeTypeId (EmployeeTypeId),
  KEY ix_DepartmentId (DepartmentId),
  CONSTRAINT FK_employee_has_employee_type FOREIGN KEY (EmployeeTypeId) REFERENCES tbl_employeetype (EmployeeTypeId),
  CONSTRAINT FK_employee_belongs_to_department FOREIGN KEY (DepartmentId) REFERENCES tbl_department (DepartmentId)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

