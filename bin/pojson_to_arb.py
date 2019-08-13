#!/usr/bin/env python
import argparse
import json
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-f', '--file', help='Path to json file', required=True)
options = parser.parse_args()

if not options.file.endswith("json"):
    print(f"Can't process {options.file}, file must be a .jon")
    parser.print_help()
    sys.exit(0)

out_file = options.file.replace(".json", ".arb")
ret = {}
with open(options.file) as json_file:
    data = json.load(json_file)
    for obj in data:
        ret[obj['reference']] = obj['definition'].replace("<newline>", "\n")
with open(out_file, 'w') as outf:
    json.dump(ret, outf, indent=2, ensure_ascii=False)
    print(f"Wrote {out_file}")
