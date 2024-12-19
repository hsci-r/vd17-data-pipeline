#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import asyncio
import gzip
import logging
import os
import re
import shutil
import unicodedata
import zipfile
from multiprocessing import Process
from typing import TextIO

import aiohttp
import click
import pymysql
import tqdm
from more_itertools import chunked


async def fetch(gnds: list[str], of: TextIO, ef: TextIO):
    error_regex = re.compile('.*<diagnostics>')
    record_regex = re.compile('<record xmlns="http://www.loc.gov/MARC21/slim" type="Authority">.*?</record>', re.DOTALL)
    async with aiohttp.ClientSession() as session:
        for chunked_gnds in tqdm.tqdm(list(chunked(gnds, 50)), unit="request"):
            query_string = 'dnb.nid+=/string+'+('+OR+dnb.nid+=/string+'.join(chunked_gnds))
            async with session.get(f'https://services.dnb.de/sru/authorities?version=1.1&operation=searchRetrieve&query={query_string}&recordSchema=MARC21-xml&maximumRecords=100') as response:
                if response.status != 200:
                    logging.error(f"Got {response.status} for {response.url}.")
                    ef.write(f"{query_string}\n")
                    continue
                content = unicodedata.normalize("NFC", await response.text())  # For some lovely reason, these are NFD
                if re.match(error_regex, content):
                    logging.error(f"Got {content} response for {response.url}.")
                    ef.write(f"{query_string}\n")
                    continue
                records = re.findall(record_regex, content)
                if len(records) != 50:
                    logging.warning(f"Difference of {len(records) - 50} records for {response.url}.")
                if len(records) == 100:
                    raise ValueError("Too many records received, maybe missing something.")
                for record in records:
                    of.write(record)


@click.command
@click.option("-p", "--password", help="password to use", required="True")
@click.option("-u", "--user", help="user to use", required="True")
@click.option("-h", "--host", help="database host", required="True")
@click.option("-d", "--database", help="database to use", required="True")
@click.option("-t", "--table", help="table name", required="True")
@click.option("-o", "--output", help="output marcxml.gz file", required="True")
@click.option("-e", "--errors", help="output error log file", required="True")
def fetch_auths(host: str, user: str, password: str, database: str, table: str, output: str, errors: str):
    with pymysql.connect(host=host, user=user, password=password, database=database, charset='utf8mb4', local_infile=True,
                         autocommit=True) as con, con.cursor() as cur:
        cur.execute(f"SELECT DISTINCT SUBSTR(value,5) from {table}_a WHERE value LIKE 'gnd/%'")
        gnds = list(map(lambda t: t[0], cur.fetchall()))
    os.makedirs(os.path.dirname(output), exist_ok=True)
    with gzip.open(output, 'wt') as of:
        of.write('<?xml version="1.0" encoding="UTF-8"?>\n<records>\n')
        with open(errors, 'wt') as ef:
            asyncio.run(fetch(gnds, of, ef))
        # with open(errors, 'rt') as ef:
        #    e_gnds = ef.read().splitlines()
        # if e_gnds:
        #    logging.warning(f"Retrying {len(e_gnds)} GNDs with errors.")
        #    with open(errors, 'wt') as ef:
        #        asyncio.run(fetch(e_gnds, of, ef))
        of.write('</records>\n')


if __name__ == '__main__':
    fetch_auths()
