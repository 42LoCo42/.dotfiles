#!@python@
import ipaddress as ip
import sys

old = sys.argv[1].strip()
add = int(sys.argv[2].strip())

typ = None
if "." in old:
    typ = ip.IPv4Address
elif ":" in old:
    typ = ip.IPv6Address
else:
    raise Exception(f"Invalid IP address {old}")

print(typ(old) + add)
