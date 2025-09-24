from flask import Flask, Response
import subprocess

app = Flask(__name__)

@app.route("/metrics")
def metrics():
    # این خط آپدیت شده است
    output = subprocess.check_output(["/usr/local/bin/storcli_exporter.sh"]).decode("utf-8")
    return Response(output, mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9210)
