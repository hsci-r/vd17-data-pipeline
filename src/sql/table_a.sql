CREATE TABLE {table}_a (
  record_number MEDIUMINT UNSIGNED NOT NULL,
  field_number SMALLINT UNSIGNED NOT NULL,
  subfield_number TINYINT UNSIGNED NOT NULL,
  field_code CHAR(4) NOT NULL,
  subfield_code CHAR(1) NOT NULL,
  value VARCHAR(4000) NOT NULL,
  PRIMARY KEY (record_number,field_number,subfield_number),
  INDEX (field_code, record_number),
  INDEX (field_code, subfield_code, record_number),
  INDEX (value(255), record_number),
  INDEX (value(255), field_code, record_number),
  INDEX (value(255), subfield_code, field_code, record_number)
) ENGINE=ARIA TRANSACTIONAL=0 PAGE_CHECKSUM=0 DEFAULT CHARACTER SET utf8mb4
