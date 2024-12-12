CREATE TABLE {table}_c (
  record_number INT UNSIGNED,
  field_number SMALLINT UNSIGNED,
  subfield_number TINYINT UNSIGNED,
  field_code CHAR(4),
  subfield_code CHAR(1),
  value VARCHAR(2000)
) ENGINE=ColumnStore DEFAULT CHARACTER SET utf8mb4
