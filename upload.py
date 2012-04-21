import os
from flask import send_from_directory
from flask import Flask, request, redirect, url_for
from flask import render_template
from werkzeug import secure_filename
#from openpyxl.reader.excel import load_workbook
import xlrd

UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['xls','xlsx'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        file = request.files['file']
        app.logger.debug('post')
        if file and allowed_file(file.filename):
            filepath = save_file(file)
#            filename = secure_filename(file.filename)
#            filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
#            file.save(filepath)
            rows = read_rows(filepath)
            return render_template('table.html', rows=rows)

    return '''
    <!doctype html>
    <title>Upload new File</title>
    <h1>Upload new File</h1>
    <form action="" method=post enctype=multipart/form-data>
      <p><input type=file name=file>
         <input type=submit value=Upload>
    </form>
    '''

def save_file(file):
    filename = secure_filename(file.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    file.save(filepath)
    return filepath

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

if __name__ == "__main__":
    app.run()#host='0.0.0.0')
