import json
from flask import Flask, request, session, redirect, render_template

app = Flask(__name__, template_folder="templates", static_folder="static")
app.secret_key = "supersecretkey"

# Load users safely
def load_users():
    try:
        with open("users.json") as f:
            return json.load(f)
    except:
        return {}

def save_users(users):
    with open("users.json","w") as f:
        json.dump(users, f, indent=4)

# 🔥 ROOT FIX (MOST IMPORTANT)
@app.route("/")
def home():
    user = session.get("user")
    if user:
        return redirect("/index")
    return redirect("/login")

# Login
@app.route("/login", methods=["GET","POST"])
def login():
    USERS = load_users()

    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        user = USERS.get(username)

        if user and user["password"] == password:
            session["user"] = username
            if user.get("role") == "admin":
                return redirect("/admin")   # 🔥 admin direct
            return redirect("/index")

        return "Invalid credentials", 401

    return render_template("login.html")

# Admin panel
@app.route("/admin")
def admin_panel():
    USERS = load_users()
    user = session.get("user")

    if not user or USERS.get(user, {}).get("role") != "admin":
        return redirect("/login")  # 🔥 better fix

    return render_template("admin.html")

# User dashboard
@app.route("/index")
def index():
    user = session.get("user")
    if not user:
        return redirect("/login")

    return render_template("index.html")

# Server console
@app.route("/server/<server_id>")
def server_console(server_id):
    user = session.get("user")
    if not user:
        return redirect("/login")

    return render_template("server.html", server_id=server_id)

# Register
@app.route("/register", methods=["GET","POST"])
def register():
    USERS = load_users()

    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]

        if username in USERS:
            return "Username exists", 400

        USERS[username] = {
            "username": username,
            "password": password,
            "role": "user",
            "plan": "free",
            "servers": []
        }

        save_users(USERS)
        return redirect("/login")

    return render_template("register.html")

# Logout
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/login")

# Run
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
