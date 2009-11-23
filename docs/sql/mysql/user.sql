SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;


DROP TABLE IF EXISTS tbl_permission;

CREATE TABLE tbl_permission (
  permission_id int(10) unsigned NOT NULL auto_increment,
  name varchar(50) NOT NULL default '',
  description varchar(100) NOT NULL default '',
  PRIMARY KEY  (permission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tbl_permission (permission_id,name,description) VALUES ('1','CREATE','create permission');
INSERT INTO tbl_permission (permission_id,name,description) VALUES ('2','VIEW','view permission');
INSERT INTO tbl_permission (permission_id,name,description) VALUES ('3','EDIT','edit permission');
INSERT INTO tbl_permission (permission_id,name,description) VALUES ('4','DELETE','delete permission');
INSERT INTO tbl_permission (permission_id,name,description) VALUES ('5','GRANT','grant permission');

DROP TABLE IF EXISTS tbl_role;

CREATE TABLE tbl_role (
  role_id int(10) unsigned NOT NULL auto_increment,
  name varchar(50) NOT NULL default '',
  description varchar(100) NOT NULL default '',
  PRIMARY KEY  (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tbl_role (role_id,name,description) VALUES ('1','Master','Full priviledge account.');
INSERT INTO tbl_role (role_id,name,description) VALUES ('2','Admin','Admin account with grant privilege.');
INSERT INTO tbl_role (role_id,name,description) VALUES ('3','User','Normal user account.');
INSERT INTO tbl_role (role_id,name,description) VALUES ('4','Guest','Anonymous account.');

DROP TABLE IF EXISTS tbl_role_permission;

CREATE TABLE tbl_role_permission (
  role_id int(10) unsigned NOT NULL,
  permission_id int(10) unsigned NOT NULL,
  PRIMARY KEY  (role_id,permission_id),
  KEY ix_role_permission_role_id (role_id),
  KEY ix_role_permission_permission_id (permission_id),
  CONSTRAINT role_permission_has_permission FOREIGN KEY (permission_id) REFERENCES tbl_permission (permission_id),
  CONSTRAINT role_permission_has_role FOREIGN KEY (role_id) REFERENCES tbl_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('1','1');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('1','2');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('1','3');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('1','4');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('1','5');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('2','2');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('2','3');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('2','4');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('2','5');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('3','2');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('3','3');
INSERT INTO tbl_role_permission (role_id,permission_id) VALUES ('4','2');

DROP TABLE IF EXISTS tbl_user;

CREATE TABLE tbl_user (
  user_id int(10) unsigned NOT NULL auto_increment,
  role_id int(10) unsigned NOT NULL,
  first_name varchar(50) NOT NULL default '',
  last_name varchar(50) NOT NULL default '',
  email varchar(100) NOT NULL default '',
  username varchar(16) NOT NULL default '',
  password varchar(32) NOT NULL default '',
  is_enabled tinyint(1) NOT NULL default 1,
  is_deleted tinyint(1) NOT NULL default 0,
  PRIMARY KEY  (user_id),
  KEY ix_user_role_id (role_id),
  CONSTRAINT FK_user_has_role FOREIGN KEY (role_id) REFERENCES tbl_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
