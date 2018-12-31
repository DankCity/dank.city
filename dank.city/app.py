from functools import wraps
import logging

from flask import Flask, render_template
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
    return render_template('index.html')
