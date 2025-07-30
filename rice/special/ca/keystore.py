#!/usr/bin/env python3
# -*- apheleia-mode: nil; -*-
from base64 import b64decode
import jks
import re
import sys

entries = []
with open(sys.argv[1], "r") as src:
    entries = [
        jks.TrustedCertEntry.new(x[0], b64decode(x[1]))
        for x in re.findall("".join([
            "([^\n]+)\n"                    , # name
            "-----BEGIN CERTIFICATE-----\n" ,
            "([^-]+)\n"                     , # data
            "-----END CERTIFICATE-----\n"   ,
        ]), src.read())]

with open(sys.argv[2], "wb") as dst:
    dst.write(jks.KeyStore.new('jks', entries).saves("changeit"))
