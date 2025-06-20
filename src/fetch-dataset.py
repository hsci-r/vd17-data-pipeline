#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import gzip
import logging
import os
import re
import shutil
import time
from typing import cast

import click
import requests
from requests.adapters import HTTPAdapter
from tqdm.auto import tqdm
from urllib3.util.retry import Retry

logging.basicConfig(level=logging.INFO)
query = "pica.ppn=" + "%20or%20pica.ppn=".join(f"{d}*" for d in range(0, 10))


def get_session_with_retries(retries=5):
    session = requests.Session()
    retry = Retry(
        total=retries,
        read=retries,
        connect=retries
    )
    adapter = HTTPAdapter(max_retries=retry)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    return session


@click.command
@click.option("-o", "--output", help="output directory", required=True, type=click.Path(file_okay=False, writable=True))
@click.argument('dataset')
def fetch_dataset(dataset: str, output: str):
    shutil.rmtree(output, ignore_errors=True)
    os.makedirs(output, exist_ok=True)
    session = get_session_with_retries()
    """Fetch a dataset (e.g. vd17/vd18) from the k10plus SRU endpoint in PICA-XML format"""
    response = session.get(
        f"https://sru.k10plus.de/{dataset}?version=2.0&operation=searchRetrieve&query={query}&maximumRecords=1&startRecord=1&recordSchema=picaxml").text
    total_records = int(cast(re.Match, re.search(
        "<zs:numberOfRecords>([0-9]*)</zs:numberOfRecords>", response)).group(1))
    batch_size = 1000
    logging.info(f"Going to process {total_records} in batches of {batch_size}.")
    for start in tqdm(range(1, total_records, batch_size)):
        with gzip.open(f'{output}/{dataset}-pica-{str(start)}.xml.gz', 'wb') as f:
            # logging.info(f"Processing batch {start} of {total_records}.")
            c = session.get(
                f"https://sru.k10plus.de/{dataset}?version=2.0&operation=searchRetrieve&query={query}&maximumRecords={batch_size}&startRecord={start}&recordSchema=picaxml").content
            f.write(c)


if __name__ == '__main__':
    fetch_dataset()
