import os
import json
import subprocess
from poeditor import POEditorAPI
from settings import PO_API_KEY, PROJECT_ID

client = POEditorAPI(api_token=PO_API_KEY)

languages = client.list_project_languages(PROJECT_ID)

language_codes = []

for l in languages:
    if l['percentage'] > 50:
        language_codes.append(l['code'])

for code in language_codes:
        print(f"Downloading {code}...")
        client.export(PROJECT_ID, code, file_type='json', local_file=f'lib/l10n/intl_{code}.json')
        print(f"Downloaded {code}")

for fname in os.listdir('lib/l10n'):
        if fname.endswith('.json'):
                fname = f'lib/l10n/{fname}'
                out_file = fname.replace(".json", ".arb")
                ret = {}
                with open(fname) as json_file:
                    data = json.load(json_file)
                    for obj in data:
                        if 'reference' in obj and 'definition' in obj and obj['definition'] is not None:
                                ret[obj['reference']] = obj['definition'].replace("<newline>", "\n")
                with open(out_file, 'w') as outf:
                    json.dump(ret, outf, indent=2, ensure_ascii=False)
                    print(f"Wrote {out_file}")
                os.remove(fname)

subprocess.run('flutter pub pub run intl_translation:generate_from_arb --output-dir=lib/l10n --no-use-deferred-loading lib/localization.dart lib/l10n/intl_*.arb', shell=True)
