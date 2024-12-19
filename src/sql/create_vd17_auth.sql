DROP TABLE IF EXISTS vd17_auth_a;

CREATE TABLE vd17_auth_a (
  a_record_number MEDIUMINT UNSIGNED NOT NULL,
  field_number SMALLINT UNSIGNED NOT NULL,
  subfield_number TINYINT UNSIGNED NOT NULL,
  field_code CHAR(4) NOT NULL,
  subfield_code CHAR(1) NOT NULL,
  value VARCHAR(4000) NOT NULL,
  PRIMARY KEY (a_record_number,field_number,subfield_number),
  INDEX (field_code, a_record_number),
  INDEX (field_code, subfield_code, a_record_number),
  INDEX (value(255), a_record_number),
  INDEX (value(255), field_code, a_record_number),
  INDEX (value(255), subfield_code, field_code, a_record_number)
) ENGINE=ARIA TRANSACTIONAL=0 PAGE_CHECKSUM=0 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;

DROP TABLE IF EXISTS vd17_auth_c;

CREATE TABLE vd17_auth_c (
  a_record_number INT UNSIGNED NOT NULL,
  field_number SMALLINT UNSIGNED NOT NULL,
  subfield_number TINYINT UNSIGNED NOT NULL,
  field_code CHAR(4) NOT NULL,
  subfield_code CHAR(1), -- empty field_code is null in ColumnStore
  value VARCHAR(2000) NOT NULL
) ENGINE=ColumnStore DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
