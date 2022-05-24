
db: data/output/vd17/vd17.tsv.gz
	code/create-db.py -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -t vd17 -i data/output/vd17/vd17.tsv.gz
	code/run-sql.py -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s code/sql/record_number_to_vd17_id.sql
	code/run-sql.py -u hsci -h vm2505.kaj.pouta.csc.fi -p ${SQL_PASSWORD} -s code/sql/create_user.sql

data/output/vd17/vd17.tsv.gz: data/work/vd17
	picaxml2csv -o data/output/vd17/vd17.tsv.gz $(wildcard data/work/vd17/*.xml.gz)

data/output/vd18/vd18.tsv.gz: data/work/vd18
	picaxml2csv -o data/output/vd18/vd18.tsv.gz $(wildcard data/work/vd18/*.xml.gz)

data/work/vd17:
	code/fetch-dataset.py vd17 -o data/work/vd17

data/work/vd18:
	code/fetch-dataset.py vd18 -o data/work/vd18
