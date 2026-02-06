import json
from http.server import BaseHTTPRequestHandler, HTTPServer


class MockUnifiHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        if self.path == "/api/auth/login":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(json.dumps({"meta": {"rc": "ok"}}).encode())
        else:
            self.send_response(404)
            self.end_headers()

    def do_GET(self):
        if self.path == "/proxy/network/api/s/default/stat/device":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            devices = {
                "data": [
                    {
                        "name": "CORE-GATEWAY",
                        "mac": "00:11:22:33:44:55",
                        "ip": "192.168.1.1",
                        "model": "UGW3",
                        "state": 1,
                    },
                    {
                        "name": "ACCESS-POINT-01",
                        "mac": "AA:BB:CC:DD:EE:FF",
                        "ip": "192.168.1.20",
                        "model": "U7PG2",
                        "state": 1,
                    },
                ]
            }
            self.wfile.write(json.dumps(devices).encode())
        elif self.path == "/proxy/network/api/s/default/stat/sta":
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            clients = {
                "data": [
                    {
                        "hostname": "IOT-DEVICE-01",
                        "mac": "11:22:33:44:55:66",
                        "ip": "10.0.90.100",
                        "is_wired": False,
                    }
                ]
            }
            self.wfile.write(json.dumps(clients).encode())
        else:
            self.send_response(404)
            self.end_headers()


def run(server_class=HTTPServer, handler_class=MockUnifiHandler, port=8080):
    server_address = ("", port)
    httpd = server_class(server_address, handler_class)
    print(f"Starting mock UniFi controller on port {port}...")
    httpd.serve_forever()


if __name__ == "__main__":
    run()
