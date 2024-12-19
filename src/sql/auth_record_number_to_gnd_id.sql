DROP TABLE IF EXISTS vd17_auth_id_a;

CREATE TABLE vd17_auth_id_a (
    a_record_number MEDIUMINT UNSIGNED NOT NULL,
    gnd VARCHAR(255) NOT NULL,
    PRIMARY KEY (a_record_number, gnd),
    UNIQUE INDEX (gnd, a_record_number)
) ENGINE=ARIA TRANSACTIONAL=0 PAGE_CHECKSUM=0 DEFAULT CHARACTER SET utf8mb4
SELECT a_record_number, CONCAT('gnd/', a2.value) AS gnd
FROM vd17_auth_a a1 INNER JOIN vd17_auth_a a2 USING (a_record_number, field_number)
WHERE a1.field_code = '024' AND a1.subfield_code = '2' AND a1.value = 'gnd' AND a2.field_code = '024' AND a2.subfield_code = 'a';

DROP TABLE IF EXISTS vd17_auth_id_c;

CREATE TABLE vd17_auth_id_c (
   record_number INT UNSIGNED NOT NULL,
   gnd VARCHAR(255) NOT NULL
 ) ENGINE=ColumnStore;

INSERT INTO vd17_auth_id_c
SELECT *
FROM vd17_auth_id_a;
