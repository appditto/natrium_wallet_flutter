#!/usr/bin/env python
import argparse
import json
import sys

parser = argparse.ArgumentParser()
parser.add_argument('-f', '--file', help='Path to arb file', required=True)
options = parser.parse_args()

if not options.file.endswith("arb"):
    print(f"Can't process {options.file}, file must be a .arb")
    parser.print_help()
    sys.exit(0)

out_file = options.file.replace(".arb", ".json")
ret = []
with open(options.file) as arb_file:
    data = json.load(arb_file)
    obj = {}
    for key, value in data.items():
        if key.startswith("@@"):
            continue
        if key.startswith("@"):
            obj['context'] = value['description']
            ret.append(obj)
            obj = {}
        else:
            obj['reference'] = key
            obj['term'] = value.replace("\n", "<newline>")
with open(out_file, 'w') as outf:
    json.dump(ret, outf, indent=4, ensure_ascii=False)
    print(f"Wrote {out_file}")
