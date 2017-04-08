from flask import Flask
from flask import request
from rpy2 import robjects
import random
import os
import string

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = "workspaces"

@app.route('/r/<model>/<fun>', methods = ['POST'])
def r_call(model, fun):
	req = request.data
	robjects.globalenv['req_data'] = req
	myreq = robjects.r('with(%s, {%s(req_data)})' % (model, fun))
	return myreq[0]

if __name__ == "__main__":
	robjects.r('library(jsonlite)')
	robjects.r('library(flaskr)')
	robjects.r('load_rds("/Users/mm32908/Desktop/My R Files/flaskrapi/rdsfiles")') 
	app.run(debug=True)
