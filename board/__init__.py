from flask import Flask

from pages import bp

def create_app():
    app = Flask(__name__)

    app.register_blueprint(bp)
    app.run(host="0.0.0.0", port=8000, debug=True)
    return app

if __name__ == "__main__":
    create_app()