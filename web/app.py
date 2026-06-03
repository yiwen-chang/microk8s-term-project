from flask import Flask, jsonify, request
import os
import socket
from datetime import datetime
import time

app = Flask(__name__)

APP_NAME = os.getenv("APP_NAME", "Photo Gallery API (Stateless)")
APP_VERSION = os.getenv("APP_VERSION", "v1")
REQUEST_COUNT = 0


def get_pod_ip():
    pod_ip = os.getenv("POD_IP")
    if pod_ip:
        return pod_ip
    try:
        return socket.gethostbyname(socket.gethostname())
    except Exception:
        return "unknown"


@app.before_request
def count_request():
    global REQUEST_COUNT
    REQUEST_COUNT += 1


@app.route("/")
def index():
    hostname = socket.gethostname()
    pod_ip = get_pod_ip()
    timestamp = datetime.utcnow().isoformat() + "Z"
    html = f"""
    <html>
      <head>
        <title>{APP_NAME}</title>
        <style>
          body {{ font-family: Arial, sans-serif; margin: 40px; }}
          .card {{ border: 1px solid #ddd; padding: 20px; border-radius: 8px; max-width: 650px; }}
          .label {{ font-weight: bold; }}
          code {{ background-color: #f5f5f5; padding: 2px 4px; border-radius: 4px; }}
        </style>
      </head>
      <body>
        <div class="card">
          <h1>{APP_NAME}</h1>
          <p>This is a <strong>stateless</strong> MicroK8s demo application used to showcase containerization, Ingress load balancing, self-healing, and scaling with Horizontal Pod Autoscaler.</p>
          <p><span class="label">Pod hostname:</span> <code>{hostname}</code></p>
          <p><span class="label">Pod IP:</span> <code>{pod_ip}</code></p>
          <p><span class="label">App version:</span> <code>{APP_VERSION}</code></p>
          <p><span class="label">Current timestamp (UTC):</span> <code>{timestamp}</code></p>
          <p>Try hitting <code>/api/info</code> and <code>/api/load</code> to demonstrate load balancing and scaling.</p>
        </div>
      </body>
    </html>
    """
    return html


@app.route("/api/info")
def api_info():
    hostname = socket.gethostname()
    pod_ip = get_pod_ip()
    timestamp = datetime.utcnow().isoformat() + "Z"
    return jsonify(
        {
            "app_name": APP_NAME,
            "hostname": hostname,
            "pod_ip": pod_ip,
            "version": APP_VERSION,
            "timestamp_utc": timestamp,
            "request_count": REQUEST_COUNT,
            "client_ip": request.remote_addr,
            "message": "Stateless MicroK8s demo app running in Kubernetes.",
        }
    )


@app.route("/healthz")
def healthz():
    return "OK", 200


@app.route("/readyz")
def readyz():
    return "READY", 200


@app.route("/api/load")
def api_load():
    duration = float(request.args.get("duration", "1.5"))
    end = time.time() + duration
    x = 0
    while time.time() < end:
        x = x * 2 + 1
    hostname = socket.gethostname()
    pod_ip = get_pod_ip()
    return jsonify(
        {
            "status": "load-generated",
            "duration_seconds": duration,
            "hostname": hostname,
            "pod_ip": pod_ip,
            "note": "Use this endpoint in a loop to trigger HPA scaling.",
        }
    )


@app.route("/api/fail")
def api_fail():
    return (
        jsonify(
            {
                "status": "simulated-failure",
                "message": "This endpoint intentionally returns HTTP 500 for demo purposes.",
            }
        ),
        500,
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)