"""Citation Manager CLI

Usage:
    paper.py search <keywords>
    paper.py file <id>

"""
# -*- coding: utf-8 -*-

from __future__ import unicode_literals
import sqlite3
import urllib2
import yaml
from docopt import docopt

class Paper:

    def __init__(self, *args, **kwargs):
        y = None
        with open('config.yaml') as config:
            y = yaml.safe_load(config)
        self.conn = sqlite3.connect(y['conn_str'])
        self.cursor = self.conn.cursor()

    def file(self, dId):
        query = "select localUrl from Files where hash = (select hash from DocumentFiles where documentId=%d)"
        path = self.get_singlet(query % dId)[0].replace('file://', '')
        path = urllib2.unquote(path)
        print path

    def search(self, query):
        a_query = "SELECT id, title, localUrl from Documents JOIN DocumentFiles ON Documents.id=DocumentFiles.documentId JOIN Files ON DocumentFiles.hash=Files.hash WHERE title like '%{}%' GROUP BY title".format(query)
        results = self.cursor.execute(a_query).fetchall()

        for doc in results:
           id = doc[0]
           title = doc[1]
           print "{:5}: {}".format(id,title)

if __name__ == '__main__':
    arguments = docopt(__doc__, version='Paper CLI 0.1')
    p = Paper()

    if arguments['search']:
        p.search(arguments['<keywords>'])
    elif arguments['file']:
        p.file(arguments['<id>'])
