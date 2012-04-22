import os, logging, datetime, urllib, urllib2, re
from flask import send_from_directory
from flask import Flask, request, redirect, url_for
from flask import render_template
from flask import json
from werkzeug import secure_filename
#from openpyxl.reader.excel import load_workbook
import xlrd

#===========my addition===============
hxlcontent = ''
uricontainer = ''
prefixes = 'PREFIX owl: <http://www.w3.org/2002/07/owl#> \nPREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#> \nPREFIX foaf: <http://xmlns.com/foaf/0.1/> \nPREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#> \nPREFIX skos:<http://www.w3.org/2004/02/skos/core#> \nPREFIX hxl: <http://hxl.humanitarianresponse.info/#> \n'''

endpointURL = 'http://83.169.33.54:8080/parliament/sparql'
queryUrl = 'http://jsonp.lodum.de/?endpoint=' + endpointURL

#=====================================


UPLOAD_FOLDER = 'uploads'
ALLOWED_EXTENSIONS = set(['xls','xlsx'])

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

#===========my addition===============
# this function is to 0 to numbers smaller then 10 to match the RDF standard
def pad(n):
  if int(n) > 9:
    result = str(n)
  else:
    result = '0' + str(n)
  return result

# this function is to form standard ISO Date String used in RDF
def ISODateString(d):
  output = pad(d.year) + '-' + pad(int(d.month) + 1) + '-' + pad(d.day) + 'T'+ pad(d.hour) + ':'+ pad(d.minute) + ':' + pad(d.second) + 'Z'
  return output

# this function is to create the same result as javascript's Date.getTime() used for the container ID
def getTime(d):
  currenttime = d
  basetime = datetime.datetime(1970,1,1,0,0,0,0)
  dt = currenttime - basetime
  milisecs = ((dt.days * 24 * 60 * 60) + dt.seconds) * 1000 + (dt.microseconds / 1000)
  result = str(milisecs)
  return result

# this function generates new URI for hxl class
def generateURI(inputclass):
  classuri = [word for word in inputclass.split('#')]
  if len(classuri) == 2:
    shortclass = classuri[1]
  else:
    shortclass = inputclass

    currenttime = datetime.datetime.now()
    stampme = getTime(currenttime)
    URI = 'http://hxl.carsten.io/' + shortclass.lower() + '/' + str(stampme)
    return URI

# this function makes new URI for hxl resource type
def makeURI(name,res_type):
  if name.find('http://') != 0:
    fragment = re.sub(r'\s','_',name)
    name = 'http://hxl.carsten.io/'+ res_type.lower() + '/' + fragment.lower()
  return name

# this function checks the hxl for it's object position and adjusted the output
def getTriple(subject,predicate,obj):
  if obj.find('http://') == 0:
    new_obj = '<' + obj + '>'
  else:
    new_obj = '"' + obj + '"'
  triple = '<' + subject +'> <' + predicate + '> ' + new_obj + ' .\n'
  return triple

# this function checks for the N-triple. If existed removed it, if not existed add
def swapTriple(subject, predicate, obj):
  if subject != '' and predicate != '' and obj !='':
    content = hxlcontent
    triple = getTriple(subject,predicate,obj)
    if content.find(triple) == -1:
      content = content + triple
    else:
      content.replace(triple,'')
  return content
#=====================================


def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1] in ALLOWED_EXTENSIONS

@app.route('/', methods=['GET', 'POST'])
def upload_file():
    if request.method == 'POST':
        inputfile = request.files['file']
        logging.error('##############check here #############')
        logging.error(inputfile)
        app.logger.debug('post')
        if inputfile and allowed_file(inputfile.filename):
            filepath = save_file(inputfile)
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

def save_file(inputfile):
    filename = secure_filename(inputfile.filename)
    filepath = os.path.join(app.config['UPLOAD_FOLDER'], filename)
    inputfile.save(filepath)
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
    app.run(debug=True)#host='0.0.0.0')
