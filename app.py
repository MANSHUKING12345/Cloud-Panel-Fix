import json
from flask import Flask, request, session, redirect, render_template

app = Flask(__name__)
app.secret_key = "supersecretkey"

# Load users
with open("users.json") as f:
    USERS = json.load(f)

# Login route
@app.route("/login", methods=["GET","POST"])
def login():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        user = USERS.get(username)
        if user and user["password"] == password:
            session["user"] = username
            role = user["role"]
            if role == "admin":
                return redirect("/admin")
            else:
                return redirect("/index")
        else:
            return "Invalid credentials", 401
    return render_template("login.html")

# Admin panel route
@app.route("/admin")
def admin_panel():
    user = session.get("user")
    if not user or USERS[user]["role"] != "admin":
        return "Access denied", 403
    return render_template("admin.html")

# Index route for normal users
@app.route("/index")
def index():
    user = session.get("user")
    if not user:
        return redirect("/login")
    return render_template("index.html")

# Server console route
@app.route("/server/<server_id>")
def server_console(server_id):
    user = session.get("user")
    if not user:
        return redirect("/login")
    return render_template("server.html", server_id=server_id)

# Register route
@app.route("/register", methods=["GET","POST"])
def register():
    if request.method == "POST":
        username = request.form["username"]
        password = request.form["password"]
        if username in USERS:
            return "Username exists", 400
        USERS[username] = {"username": username, "password": password, "role": "user", "plan": "free", "servers":[]}
        with open("users.json","w") as f:
            json.dump(USERS, f, indent=4)
        return redirect("/login")
    return render_template("register.html")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
