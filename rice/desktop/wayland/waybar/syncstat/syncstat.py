#!@python@
import xml.etree.ElementTree as ET
from os import path
from time import sleep

import requests

apikey = (
    ET.parse(path.expanduser("~/.local/state/syncthing/config.xml"))
    .find("./gui/apikey")
    .text
)

while True:
    res = requests.get(
        f"http://localhost:8384/rest/db/status?folder=cw6hv-bpaei",
        headers={"authorization": f"Bearer {apikey}"},
    ).json()
    if res["state"] == "idle":
        print(flush=True)
    else:
        print(
            f"{res["state"]} - {100 * res["inSyncFiles"] // res ["globalFiles"]}",
            flush=True,
        )

    sleep(1)
