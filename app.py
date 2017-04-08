from flask import Flask
from flask import request
from flask import jsonify
from flask import json
from rpy2 import robjects
import random
import os
import string

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = "rdsfiles"

@app.route('/deploy', methods = ['POST'])
def deploy():
	file = request.files['rdsfile']
	filename = request.files['rdsfile'].filename
	file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
	cmd = 'rds_to_env("%s", "%s")' % (app.config['UPLOAD_FOLDER'], filename)
	robjects.r(cmd)
	return jsonify(OK = "SUCCESS!")

@app.route('/r/<model>/<fun>', methods = ['POST'])
def r_call(model, fun):
	req = request.data
	robjects.globalenv['req_data'] = req
	myreq = robjects.r('with(env_%s, \
		{toJSON(json_wrapper(%s(fromJSON(req_data))))})' \
		% (model, fun))
	return jsonify(json.loads(myreq[0]))

if __name__ == "__main__":
	app.run(debug=True)
