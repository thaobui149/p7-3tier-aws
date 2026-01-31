import os
import psycopg2
from flask import Flask

app = Flask(__name__)

@app.get("/health")
def health():
    return {"status": "ok"}, 200

@app.get("/")
def root():
    return {"message": "hello from ecs"}, 200

@app.get("/db")
def db():
    host = os.getenv("DB_HOST")
    user = os.getenv("DB_USER")
    password = os.getenv("DB_PASSWORD")
    name = os.getenv("DB_NAME", "appdb")

    conn = psycopg2.connect(host=host, user=user, password=password, dbname=name, connect_timeout=3)
    cur = conn.cursor()
    cur.execute("SELECT 1;")
    v = cur.fetchone()[0]
    cur.close()
    conn.close()
    return {"db": "ok", "value": v}, 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
