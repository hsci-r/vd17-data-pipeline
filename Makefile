
db: vd17_db vd17_authdb

vd17_db: data/output/vd17/vd17.tsv.gz
	code/create-db.py -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -t vd17 -i data/output/vd17/vd17.tsv.gz
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s code/sql/record_number_to_vd17_id.sql
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -p ${SQL_PASSWORD} -s code/sql/create_user.sql

vd17_auth_db: data/output/vd17/vd17_auth.tsv.gz
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s code/sql/create_vd17_auth.sql
	load-db -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -t vd17_auth_a -p ${SQL_PASSWORD} -i data/output/vd17/vd17_auth.tsv.gz
        run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s "INSERT INTO vd17_auth_c SELECT * FROM vd17_auth_a"

data/output/vd17/vd17.tsv.gz: data/work/vd17
	picaxml2csv -o data/output/vd17/vd17.tsv.gz $(wildcard data/work/vd17/*.xml.gz)

data/output/vd18/vd18.tsv.gz: data/work/vd18
	picaxml2csv -o data/output/vd18/vd18.tsv.gz $(wildcard data/work/vd18/*.xml.gz)

data/output/vd17/vd17_auth.tsv.gz:
	marxml2csv -o data/output/vd17_auth.tsv.gz data/work/vd17_auth/vd17_auth_marcxml.zip

data/work/vd17:
	code/fetch-dataset.py vd17 -o data/work/vd17

data/work/vd18:
	code/fetch-dataset.py vd18 -o data/work/vd18
