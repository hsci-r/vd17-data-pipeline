#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from io import StringIO

import click
import pymysql


@click.command
@click.option("-p", "--password", help="password to use", required="True")
@click.option("-u", "--user", help="user to use", required="True")
@click.option("-h", "--host", help="database host", required="True")
@click.option("-d", "--database", help="database to use")
@click.option("-s", "--sql", help="input SQL filename", required="True", type=click.File(mode='rt'))
def run_sql(host: str, user: str, password: str, database: str, sql: StringIO):
    with pymysql.connect(host=host, user=user, password=password, charset='utf8mb4', local_infile=True,
                         autocommit=True, database=database) as con, con.cursor() as cur:
        for statement in sql.read().split(";"):
            if len(statement.strip()) > 0:
                print(f"Running statement:\n{statement}")
                cur.execute(statement)
                warnings = cur.fetchall()
                if len(warnings) > 0:
                    print(f"Errors and warnings encountered: {warnings} while running {statement}.")


if __name__ == '__main__':
    run_sql()