from flask import Flask
import pytz
from datetime import datetime

from pages import bp

IST = pytz.timezone('Asia/Saigon')
raw_TS = datetime.now(IST)
date_now = raw_TS.strftime('%d %b %Y')
print('Date: ', date_now)

def create_app():
    app = Flask(__name__)

    app.register_blueprint(bp)
    app.run(host="0.0.0.0", port=8000, debug=True)
    return app

if __name__ == "__main__":
    create_app()