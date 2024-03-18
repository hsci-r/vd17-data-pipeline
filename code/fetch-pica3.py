# %%
import csv
import html
import logging
from typing import Iterator

import requests

# %%

ppn = "006571840"
# ppn = "007564856"


def get_pica3(ppn: str) -> Iterator[list[str]]:
    f_i = 1
    response = requests.get(
        f"https://kxp.k10plus.de/DB=1.28/PPNSET?PPN={ppn}&PRS=pica3&COOKIE=U1019510,K2413LOGIN,D1.28,Eb413a410-3,I0,B2413++++++,SY,QDEF,A,H12,,73,,76-77,,80,,82,,85-90,NUNIVERSIT%C3%84T+HELSINIKI,R128.214.197.60,FN", stream=True)
    response.encoding = 'utf-8'
    start = len('<tr><td class="rec_title"><span>')
    end = -len('</span></td></tr>')

    for line in response.iter_lines(decode_unicode=True):
        if line.startswith('<tr><td class="rec_title"><span>'):
            record = line[start:end]
            if ' ' in record:
                split = record.index(' ')
                code = record[0:split]
                value_string = html.unescape(record[split+1:])
                values = value_string.split('$')
                yield [f_i, 1, code, "", values[0]]
                sf_i = 2
                for value in values[1:]:
                    yield [f_i, sf_i, code, value[0], value[1:]]
                    sf_i += 1
                f_i += 1

# %%


with open("data/processed/044s.tsv", 'rt') as inf, open("data/processed/044s-pica3.tsv", 'wt') as of:
    cr = csv.reader(inf, delimiter="\t")
    cw = csv.writer(of, delimiter="\t")
    cw.writerow(["ppn", "field_number", "subfield_number", "field_code", "subfield_code", "value"])
    next(cr)
    for row in cr:
        ppn = row[0]
        print(ppn)
        for row in get_pica3(ppn):
            cw.writerow([ppn, *row])
