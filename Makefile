all: parquet tsvgz

parquet: data/output/vd17/vd17.parquet \
 data/output/vd17/vd17_auth.parquet \
 data/output/vd18/vd18.parquet \
 data/output/vd18/vd18_auth.parquet

tsvgz: data/output/vd17/vd17.tsv.gz \
 data/output/vd17/vd17_auth.tsv.gz \
 data/output/vd18/vd18.tsv.gz \
 data/output/vd18/vd18_auth.tsv.gz

clean:
	rm -rf data/work/* status/*

data/output/vd17/vd17.parquet: status/vd17.fetched
	picaxml2 -o data/output/vd17/vd17.parquet data/work/vd17/*.xml.gz
data/output/vd18/vd18.parquet: status/vd18.fetched
	picaxml2 -o data/output/vd18/vd18.parquet data/work/vd18/*.xml.gz

data/output/vd17/vd17_auth.parquet: data/work/vd17_auth.mrcx.gz
	marcxml2 -o data/output/vd17/vd17_auth.parquet data/work/vd17_auth.mrcx.gz
data/output/vd18/vd18_auth.parquet: data/work/vd18_auth.mrcx.gz
	marcxml2 -o data/output/vd18/vd18_auth.parquet data/work/vd18_auth.mrcx.gz

data/output/vd17/vd17.tsv.gz: status/vd17.fetched
	picaxml2 -o data/output/vd17/vd17.tsv.gz data/work/vd17/*.xml.gz
data/output/vd18/vd18.tsv.gz: status/vd18.fetched
	picaxml2 -o data/output/vd18/vd18.tsv.gz data/work/vd18/*.xml.gz

data/output/vd17/vd17_auth.tsv.gz: data/work/vd17_auth.mrcx.gz
	marcxml2 -o data/output/vd17/vd17_auth.tsv.gz data/work/vd17_auth.mrcx.gz
data/output/vd18/vd18_auth.tsv.gz: data/work/vd18_auth.mrcx.gz
	marcxml2 -o data/output/vd18/vd18_auth.tsv.gz data/work/vd18_auth.mrcx.gz

data/work/vd17_auth.mrcx.gz: data/output/vd17/vd17.parquet data/input/additional_gnds.txt
	python src/fetch-auths.py -i data/output/vd17/vd17.parquet -g data/input/additional_gnds.txt -e data/work/vd17_auth_fetch_errors.txt -o data/work/vd17_auth.mrcx.gz

data/work/vd18_auth.mrcx.gz: data/output/vd18/vd18.parquet data/input/additional_gnds.txt
	python src/fetch-auths.py -i data/output/vd18/vd18.parquet -g data/input/additional_gnds.txt -e data/work/vd18_auth_fetch_errors.txt -o data/work/vd18_auth.mrcx.gz

status/vd17.fetched:
	src/fetch-dataset.py vd17 -o data/work/vd17
	touch status/vd17.fetched

status/vd18.fetched:
	src/fetch-dataset.py vd18 -o data/work/vd18
	touch status/vd18.fetched
