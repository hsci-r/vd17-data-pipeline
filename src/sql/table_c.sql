CREATE TABLE {table}_c (
  record_number INT UNSIGNED NOT NULL,
  field_number SMALLINT UNSIGNED NOT NULL,
  subfield_number TINYINT UNSIGNED NOT NULL,
  field_code CHAR(4) NOT NULL,
  subfield_code CHAR(1) NOT NULL,
  value VARCHAR(2000) NOT NULL
) ENGINE=ColumnStore DEFAULT CHARACTER SET utf8mb4
