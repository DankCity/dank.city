from functools import wraps
import logging
import uuid

from flask import Flask, render_template, request
import sentry_sdk

log = logging.getLogger(__name__)
log.setLevel(logging.INFO)

sentry_sdk.init()

app = Flask(__name__)


def report_errors(func):
    @wraps(func)
    def inner(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except Exception:
            log.exception("Caught exception")
            raise

    return inner


@app.route('/')
@report_errors
def index():
    if request.user_agent.string.startswith('curl'):
        req_id = uuid.uuid4().hex
        resp = render_template('dank.sh', req_id=req_id)
    else:
        resp = render_template('index.html')

    return resp


@app.route('/ph/<req_id>', methods=['HEAD'])
@report_errors
def phone_home(req_id):
    return render_template('ph.html')
