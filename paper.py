#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""Citation Manager CLI
Usage:
    paper.py search <keywords>
    paper.py file <id>

"""
import sqlite3
import yaml
from urllib.request import unquote
from docopt import docopt
from termcolor import colored

class Paper:

    def __init__(self, *args, **kwargs):
        y = None
        with open('config.yaml') as config:
            y = yaml.safe_load(config)
        self.conn = sqlite3.connect(y['conn_str'])
        self.cursor = self.conn.cursor()

    def file(self, dId):
        query = "select localUrl from Files where hash = (select hash from DocumentFiles where documentId=%d)"
        result = self.cursor.execute(query % dId).fetchall()
        path = result[0][0].replace('file://', '')
        path = unquote(path)
        print(path)

    def search(self, query):
        a_query = "SELECT id, title, localUrl from Documents JOIN DocumentFiles ON Documents.id=DocumentFiles.documentId JOIN Files ON DocumentFiles.hash=Files.hash WHERE title like '%{}%' GROUP BY title".format(query)
        results = self.cursor.execute(a_query).fetchall()

        deduped_set = set()
        for doc in results:
           id = doc[0]
           title = doc[1]
           path = unquote(doc[2].replace('file://', ''))
           if path not in deduped_set:
               print(colored("{}".format(title), 'blue', attrs=['bold']))
               print(colored('{}'.format(path), 'magenta'))
               deduped_set.add(path)

if __name__ == '__main__':
    arguments = docopt(__doc__, version='Paper CLI 0.1')
    p = Paper()

    if arguments['search']:
        p.search(arguments['<keywords>'])
    elif arguments['file']:
        p.file(int(arguments['<id>']))
