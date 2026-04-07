#!/usr/bin/env python3

import json
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib import parse
from urllib.request import Request, urlopen


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(str(self.headers.get("content-length")))
        token = parse.parse_qs(str(self.rfile.read(length), "utf-8"))["token"][0]

        try:
            with urlopen(
                Request(
                    "https://id.eleonora.gay/api/oidc/userinfo",
                    headers={"Authorization": f"Bearer {token}"},
                )
            ) as res:
                if res.status != 200:
                    raise Exception()

                info = json.loads(res.read())

                for key in ["irc_username", "preferred_username"]:
                    if key in info:
                        self.send_response(HTTPStatus.OK)
                        self.end_headers()
                        self.wfile.write(
                            json.dumps(
                                {
                                    "active": True,
                                    "username": info[key],
                                }
                            ).encode("utf-8")
                        )
                        return

                raise Exception()
        except:
            self.send_response(HTTPStatus.FORBIDDEN)
            self.end_headers()


HTTPServer(("127.0.0.1", 8000), Handler).serve_forever()
