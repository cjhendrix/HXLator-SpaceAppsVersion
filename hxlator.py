import os, logging, datetime, urllib, urllib2, re
from flask import send_from_directory
from flask import Flask, request, redirect, url_for
from flask import render_template
from flask import json
from werkzeug import secure_filename
import xlrd



UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['xls','xlsx'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

#@app.route('/original', methods=['GET', 'POST'])
#def upload_file():
#    if request.method == 'POST':
#        inputfile = request.files['file']
#        logging.error('##############check here #############')
#        logging.error(inputfile)
#        app.logger.debug('post')
#        if inputfile and allowed_file(inputfile.filename):
#            filepath = save_file(inputfile)
#            rows = read_rows(filepath)
#            return render_template('table.html', rows=rows)
#
#    return '''
#    <!doctype html>
#    <title>Upload new File</title>
#  <h1>Upload new File</h1>
#    <form action="" method=post enctype=multipart/form-data>
#      <p><input type=file name=file>
#         <input type=submit value=Upload>
#    </form>
#    '''

@app.route('/process_input/',methods=['POST','GET'])
def process_input():
  inputfile = request.files['file']
  if inputfile and allowed_file(inputfile.filename):
    filepath = save_file(inputfile)
    return 'file uploaded'

def save_file(inputfile):
    filename = secure_filename(inputfile.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    inputfile.save(filepath)
    return filepath

@app.route('/handle_hxl/',methods=['POST','GET'])
def handle_hxl():
    hxldata=request.values.get('hxlcode')
    return 'hxl data submitted'

@app.route('/fetch_rows/',methods=['POST','GET'])
def fetch_rows():
    filename = request.values.get('filename')
    final_file = [i for i in filename.split('\\')]
    idx = len(final_file)
    thefile = final_file[idx-1]
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], thefile)
    rows = read_rows(filepath)
    payload = json.dumps(dict(rows=rows))
    return payload

def read_rows(filepath):
    rows = []
    if os.path.splitext(filepath)[1] == '.xls':
        wb = xlrd.open_workbook(filepath)
        sh = wb.sheet_by_index(0)
        for rownum in range(sh.nrows):
            rows.append(sh.row_values(rownum))
    return rows

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(app.config['UPLOAD_FOLDER'],
                               filename)

@app.route('/')
def landing_page():
  return render_template('index.html')

if __name__ == "__main__":
    app.run(debug=True, port=1616, host='0.0.0.0')
