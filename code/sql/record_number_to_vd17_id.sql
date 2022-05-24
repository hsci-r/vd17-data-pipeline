DROP TABLE IF EXISTS vd17_id_a;

CREATE TABLE vd17_id_a (
    record_number MEDIUMINT UNSIGNED,
    vd17_id VARCHAR(255),
    PRIMARY KEY (record_number,vd17_id),
    UNIQUE INDEX (vd17_id,record_number)
) ENGINE=ARIA TRANSACTIONAL=0 PAGE_CHECKSUM=0 DEFAULT CHARACTER SET utf8mb4
SELECT record_number, `value` AS vd17_id
FROM vd17_a
WHERE field_code="006W";

DROP TABLE IF EXISTS vd17_id_c;

CREATE TABLE vd17_id_c (
    record_number INT UNSIGNED,
    vd17_id VARCHAR(255)
) ENGINE=ColumnStore;

INSERT INTO vd17_id_c
SELECT *
FROM vd17_id_a;
