#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import asyncio
import gzip
import logging
import os
import shutil
import unicodedata
import zipfile
from multiprocessing import Process
from typing import TextIO

import aiohttp
import click
import pymysql
import tqdm


async def fetch(gnds: list[str], of: TextIO):
    async with aiohttp.ClientSession() as session:
        for gnd in tqdm.tqdm(gnds, unit="GND"):
            async with session.get(f'https://d-nb.info/{gnd}/about/marcxml') as response:
                if response.status != 200:
                    logging.error(f"Got {response.status} for {response.url}.")
                    continue
                record = await response.text()
                record = record[record.index('\n') + 1:]
                of.write(unicodedata.normalize("NFC", record))  # For some lovely reason, these are NFD


@click.command
@click.option("-p", "--password", help="password to use", required="True")
@click.option("-u", "--user", help="user to use", required="True")
@click.option("-h", "--host", help="database host", required="True")
@click.option("-d", "--database", help="database to use", required="True")
@click.option("-t", "--table", help="table name", required="True")
@click.option("-o", "--output", help="output marcxml.gz file", required="True")
def fetch_auths(host: str, user: str, password: str, database: str, table: str, output: str):
    with pymysql.connect(host=host, user=user, password=password, database=database, charset='utf8mb4', local_infile=True,
                         autocommit=True) as con, con.cursor() as cur:
        cur.execute(f"SELECT DISTINCT value from {table}_a WHERE value LIKE 'gnd/%'")
        gnds = list(map(lambda t: t[0], cur.fetchall()))
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with gzip.open(output, 'wt') as of:
        of.write('<?xml version="1.0" encoding="UTF-8"?>\n<records>\n')
        asyncio.run(fetch(gnds, of))
        of.write('</records>')


if __name__ == '__main__':
    fetch_auths()
