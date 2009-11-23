SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

DROP TABLE IF EXISTS tbl_audit;

CREATE TABLE tbl_audit (
  audit_id bigint NOT NULL AUTO_INCREMENT,
  object_class varchar(50) NOT NULL,
  primary_key int(10) unsigned NOT NULL,
  action varchar(10) NOT NULL, 
  audit_date datetime NOT NULL default '0000-00-00',
  memento text default NULL,
  user_id int(10) unsigned default NULL,
  PRIMARY KEY  (audit_id),
  KEY IX_audit_user_id (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
