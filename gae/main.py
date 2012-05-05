# coding: UTF-8

import settings

import os, logging, re

from flask import Flask
app = Flask(__name__)
app.config.from_object('settings')

from flask import g
from flask import redirect
from flask import url_for
from flask import session
from flask import request
from flask import render_template
from flask import abort
from flask import flash
from flask import get_flashed_messages
from flask import json
from werkzeug import secure_filename
from werkzeug.contrib.cache import GAEMemcachedCache


import xlrd
from decorators import login_required, cache_page

from models import User

from gaeUtils.util import generate_key
from google.appengine.api.labs import taskqueue

cache = GAEMemcachedCache()
ALLOWED_EXTENSIONS = set(['xls','xlsx'])

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

def read_rows(inputfile):
    rows = []
    wb = xlrd.open_workbook(file_contents=inputfile.read())
    sh = wb.sheet_by_index(0)
    for rownum in range(sh.nrows):
        rows.append(sh.row_values(rownum))
    return rows

@app.route('/')
def landing_page():
  return render_template('index.html')

@app.route('/process_input/',methods=['POST','GET'])
def process_input():
  inputfile = request.files['file']
  rows=read_rows(request.files['file'])
  payload = json.dumps(dict(rows=rows))
  cache_id = 'payload-' + inputfile.filename
  cache.set(cache_id, payload, timeout=60*60)
  return 'stored in cache'

@app.route('/fetch_rows/',methods=['POST','GET'])
def fetch_rows():
    filename = request.values.get('filename')
    final_file = [i for i in filename.split('\\')]
    idx = len(final_file)
    thefile = final_file[idx-1]
    cache_id = 'payload-' + thefile
    payload = cache.get(cache_id)
    return payload


@app.route('/handle_hxl/',methods=['POST','GET'])
def handle_hxl():
    hxldata=request.values.get('hxlcode')
    return 'hxl data submitted'

