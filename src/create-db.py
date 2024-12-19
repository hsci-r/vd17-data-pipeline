#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import gzip
import os
import shutil
from multiprocessing import Process

import click
import pymysql
import tqdm


def read_relative(relative_path: str) -> str:
    with open(os.path.join(os.path.dirname(__file__), relative_path), 'rt') as f:
        return f.read()


def gunzip(input: str, output: str):
    pbar = tqdm.tqdm(total=os.path.getsize(input), unit='b', unit_scale=True, unit_divisor=1024)
    with open(input, 'rb') as inf, gzip.open(inf, "rb") as rf, open(output, 'wb') as of:
        while True:
            buf = rf.read(shutil.COPY_BUFSIZE)
            if not buf:
                break
            of.write(buf)
            pbar.n = inf.tell()
            pbar.update(0)


@click.command
@click.option("-p", "--password", help="password to use", required="True")
@click.option("-u", "--user", help="user to use", required="True")
@click.option("-h", "--host", help="database host", required="True")
@click.option("-d", "--database", help="database to use", required="True")
@click.option("-t", "--table", help="table name", required="True")
@click.option("-i", "--input", help="input CSV/TSV filename", required="True", type=click.Path(exists=True))
def import_database(host: str, user: str, password: str, database: str, table: str, input: str):
    with pymysql.connect(host=host, user=user, password=password, charset='utf8mb4', local_infile=True,
                         autocommit=True) as con, con.cursor() as cur:
        cur.execute(f"CREATE DATABASE IF NOT EXISTS {database} CHARACTER SET utf8mb4 COLLATE utf8mb4_bin")
        cur.execute(f"USE {database}")
        cur.execute(f"DROP TABLE IF EXISTS {table}_a")
        cur.execute(read_relative("sql/table_a.sql").format(table=table))
        cur.execute(f"ALTER TABLE {table}_a DISABLE KEYS")
        os.mkfifo("pipe.tsv", 0o600)
        p = Process(target=gunzip, args=(input, "pipe.tsv"))
        p.start()
        try:
            cur.execute(f"LOAD DATA LOCAL INFILE 'pipe.tsv' INTO TABLE {
                        table}_a CHARACTER SET UTF8 FIELDS TERMINATED BY '\\t' OPTIONALLY ENCLOSED BY '\"' ESCAPED BY '' LINES TERMINATED BY '\\r\\n' IGNORE 1 ROWS")
            p.join()
        finally:
            p.terminate()
            os.remove("pipe.tsv")
        print(f"Ingested {cur.rowcount} rows.")
        cur.execute("SHOW WARNINGS")
        warnings = cur.fetchall()
        if warnings:
            print(f"Errors and warnings encountered: {warnings}")
        print("Enabling keys")
        cur.execute(f"ALTER TABLE {table}_a ENABLE KEYS")
        # The maximum length for a ColumnStore varchar is 2000, while we're currently supporting 4000 for the Aria table
        # print("Copying table to ColumnStore")
        # cur.execute(f"DROP TABLE IF EXISTS {table}_c")
        # cur.execute(read_relative("sql/table_c.sql").format(table=table))
        # cur.execute(f"INSERT INTO {table}_c SELECT * FROM {table}_a")
        # cur.execute("SHOW WARNINGS")
        # warnings = cur.fetchall()
        # if warnings:
        #    print(f"Errors and warnings encountered: {warnings}")


if __name__ == '__main__':
    import_database()
