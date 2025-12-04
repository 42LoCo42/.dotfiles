#!@python@
import xml.etree.ElementTree as ET
from os import path
from time import sleep

import requests


def humanSize(num: float, suffix="B") -> str:
    for unit in ("", "Ki", "Mi", "Gi", "Ti", "Pi", "Ei", "Zi"):
        if num < 1024.0:
            return f"{num:3.1f} {unit}{suffix}"
        num /= 1024.0
    return f"{num:3.1f} Yi{suffix}"


apikey = (
    ET.parse(path.expanduser("~/.local/state/syncthing/config.xml"))
    .find("./gui/apikey")
    .text
)

while True:
    res = requests.get(
        f"http://localhost:8384/rest/db/status?folder=@folder@",
        headers={"authorization": f"Bearer {apikey}"},
    ).json()
    if res["state"] == "idle":
        print(flush=True)
    else:
        pct = 100 * res["inSyncFiles"] // res["globalFiles"]
        done = humanSize(res["inSyncBytes"])
        total = humanSize(res["globalBytes"])
        print(
            f"{res["state"]} - {pct}% in sync, {done} of {total}",
            flush=True,
        )

    sleep(1)
