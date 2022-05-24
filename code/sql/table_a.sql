CREATE TABLE {table}_a (
  record_number MEDIUMINT UNSIGNED,
  field_number SMALLINT UNSIGNED,
  subfield_number TINYINT UNSIGNED,
  field_code CHAR(4),
  subfield_code CHAR(1),
  value VARCHAR(2000),
  PRIMARY KEY (record_number,field_number,subfield_number),
  INDEX (field_code, record_number),
  INDEX (field_code, subfield_code, record_number)
) ENGINE=ARIA TRANSACTIONAL=0 PAGE_CHECKSUM=0 DEFAULT CHARACTER SET utf8mb4