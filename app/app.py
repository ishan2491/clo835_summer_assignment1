from flask import Flask, render_template
import os
import mysql.connector
from mysql.connector import Error

app = Flask(__name__)

# Get background color from environment variable
BACKGROUND_COLOR = os.environ.get("BACKGROUND_COLOR", "blue")
DB_HOST = os.environ.get("DB_HOST", "mysql-container")
DB_USER = os.environ.get("DB_USER", "root")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "password")
DB_NAME = os.environ.get("DB_NAME", "employees")

@app.route("/")
def home():
    return render_template("index.html", background_color=BACKGROUND_COLOR)

@app.route("/health")
def health():
    return {"status": "healthy", "background": BACKGROUND_COLOR}

@app.route("/db-test")
def db_test():
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD
        )
        if connection.is_connected():
            cursor = connection.cursor()
            cursor.execute("SELECT COUNT(*) FROM employees")
            count = cursor.fetchone()[0]
            cursor.close()
            connection.close()
            return f"Database connected! Employee count: {count}"
    except Error as e:
        return f"Database connection failed: {str(e)}"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)