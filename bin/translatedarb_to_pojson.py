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
with open('lib/l10n/intl_messages.arb') as base_file:
    base_data = json.load(base_file)
    with open('lib/l10n/intl_messages.json') as json_file:
        json_data = json.load(json_file)
        with open(options.file) as arb_file:
            data = json.load(arb_file)
            obj = {}
            for key, value in data.items():
                if key.startswith("@"):
                    continue
                obj['term'] = base_data[key].replace("\n", "<newline>")
                obj['definition'] = value.replace("\n", "<newline>")
                for i in json_data:
                    if i['term'] == obj['term']:
                        obj['context'] = i['context']
                obj['term_plural'] = ""
                obj['reference'] = key
                obj['comment'] = ""
                ret.append(obj)
                obj = {}
with open(out_file, 'w') as outf:
    json.dump(ret, outf, indent=4, ensure_ascii=False)
    print(f"Wrote {out_file}")
