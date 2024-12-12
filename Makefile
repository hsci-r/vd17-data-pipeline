
db: status/vd17_db.loaded status/vd17_auth_db.loaded

status/vd17_db.loaded: data/output/vd17/vd17.tsv.gz
	src/create-db.py -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -t vd17 -i data/output/vd17/vd17.tsv.gz
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s src/sql/record_number_to_vd17_id.sql
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -p ${SQL_PASSWORD} -s src/sql/create_user.sql
	touch status/vd17_db.loaded

status/vd17_auth_db.loaded: data/output/vd17/vd17_auth.tsv.gz
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s src/sql/create_vd17_auth.sql
	load-db -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -t vd17_auth_a -p ${SQL_PASSWORD} -i data/output/vd17/vd17_auth.tsv.gz
	run-sql -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -s "INSERT INTO vd17_auth_c SELECT * FROM vd17_auth_a"
	touch status/vd17_db.loaded

data/output/vd17/vd17.tsv.gz: status/vd17.fetched
	picaxml2csv -o data/output/vd17/vd17.tsv.gz data/work/vd17/*.xml.gz

data/output/vd18/vd18.tsv.gz: status/vd18.fetched
	picaxml2csv -o data/output/vd18/vd18.tsv.gz data/work/vd18/*.xml.gz

data/output/vd17/vd17_auth.tsv.gz: status/vd17_auth.fetched
	marcxml2csv -o data/output/vd17/vd17_auth.tsv.gz data/work/vd17_auth/vd17_auth.mrcx.gz

status/vd17_auth.fetched: status/vd17_db.loaded
	python src/fetch-auths.py -u hsci -h vm2505.kaj.pouta.csc.fi -d vd17 -p ${SQL_PASSWORD} -t vd17 -o data/work/vd17_auth/vd17_auth.mrcx.gz

status/vd17.fetched:
	src/fetch-dataset.py vd17 -o data/work/vd17
	touch status/vd17.fetched

status/vd18.fetched:
	src/fetch-dataset.py vd18 -o data/work/vd18
	touch status/vd18.fetched
