"""Validate this reference and parse Lua templates without writing bytecode."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit
from lua_source import mask_lua, headings, definitions

def check_lua(luac, files):
    errors, infrastructure, attempted, succeeded = [], [], 0, 0
    if not luac.is_file():
        infrastructure.append('Lua compiler unavailable: ' + str(luac))
    else:
        for path in files:
            try:
                result = subprocess.run([str(luac), '-p', str(path)], capture_output=True)
            except OSError as exc:
                infrastructure.append(f'Lua compiler could not start: {exc}; remaining files not parsed')
                break
            attempted += 1
            if result.returncode:
                errors.append(f'Lua syntax failed: {path}\n' + result.stderr.decode('utf-8', errors='replace'))
            else:
                succeeded += 1
    return dict(errors=errors, infrastructure_errors=infrastructure, attempted=attempted,
                succeeded=succeeded, complete=attempted == len(files) and not infrastructure,
                passed=succeeded == len(files) and not infrastructure)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--luac', type=Path, default=Path('D:/CDesktopLink/Portable/lua/lua5_1_4_Win64_bin/luac5.1.exe'))
    parser.add_argument('--vanilla', type=Path, help='Override the snapshot scripts root for source hashes/API checks; local Markdown links still use the documented layout.')
    parser.add_argument('--skip-lua', action='store_true', help='Only documentation checks; no syntax success is reported.')
    parser.add_argument('--output', type=Path, help='Save JSON report inside Documentation, in UTF-8/CRLF.')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    manifest = json.loads((root / 'SOURCE_MANIFEST.json').read_text(encoding='utf-8'))
    vanilla = args.vanilla or Path(manifest['snapshot'])
    errors = []
    infrastructure_errors = []
    counts = dict(text_files=0, markdown_links=0, markdown_anchors=0, source_symbol_links=0, source_evidence=0, api_signatures=0, lua_syntax_files=0, lua_syntax_successes=0, source_hashes=0, workspace_hashes=0, template_dependencies=0)
    masked_sources = {}
    files = sorted(p for p in root.rglob('*') if p.is_file() and p.suffix in {'.md', '.lua', '.json', '.py'})
    for path in files:
        data = path.read_bytes()
        counts['text_files'] += 1
        if data.startswith(b'\xef\xbb\xbf'):
            errors.append(f'BOM: {path}')
        try:
            text = data.decode('utf-8')
        except UnicodeDecodeError:
            errors.append(f'Not UTF-8: {path}')
            continue
        if b'\n' in data.replace(b'\r\n', b'') or b'\r' in data.replace(b'\r\n', b''):
            errors.append(f'Not CRLF: {path}')
        if path.suffix != '.md':
            continue
        if re.search(r'\[\[(?:v|mod):', text):
            errors.append(f'Unresolved source marker: {path}')
        for match in re.finditer(r'\[([^\]\n]+)\]\((?:<([^>\n]+)>|([^\s)]+))\)', text):
            label = match.group(1)
            link = match.group(2) or match.group(3)
            drive_path = re.match(r'^[A-Za-z]:[/\\]', link)
            if urlsplit(link).scheme and not drive_path:
                continue
            local, separator, fragment = link.partition('#')
            target = (path.parent / unquote(local)).resolve() if local else path
            counts['markdown_links'] += 1
            if not target.exists():
                errors.append(f'Broken link {path.relative_to(root)}: {link}')
                continue
            if separator and target.suffix == '.md':
                counts['markdown_anchors'] += 1
                if unquote(fragment) not in headings(target.read_text(encoding='utf-8')):
                    errors.append(f'Broken Markdown anchor {path.relative_to(root)}: {link}')
            if ' — ' in label and target.is_file() and target.suffix == '.lua':
                symbol = label.split(' — ', 1)[1]
                if target not in masked_sources:
                    masked_sources[target] = mask_lua(target.read_bytes().decode('utf-8-sig', errors='replace'))
                counts['source_symbol_links'] += 1
                if symbol not in masked_sources[target]:
                    errors.append(f'Missing symbol {symbol}: {target}')
    for entry in manifest.get('source_evidence', []):
        target = vanilla / entry['path'] if entry['origin'] == 'vanilla' else root.parent / entry['path']
        counts['source_evidence'] += 1
        if not target.is_file():
            errors.append('Evidence file missing: ' + str(target))
            continue
        source = target.read_text(encoding='utf-8-sig', errors='replace')
        lines = source.splitlines()
        line = entry['line']
        if line < 1 or line > len(lines) or lines[line - 1].strip() != entry['excerpt']:
            errors.append('Evidence line changed: ' + entry['path'] + ':' + str(line))
        if entry['kind'] == 'definition' and not any(d['symbol'] == entry['symbol'] and d['line'] == line and d['signature'] == entry['signature'] for d in definitions(source)):
            errors.append('Evidence is not a code definition: ' + entry['symbol'])
    modutil = (vanilla / 'modutil.lua').read_text(encoding='utf-8-sig')
    current = []
    for line, source in enumerate(mask_lua(modutil, strings=True).splitlines(), 1):
        match = re.search(r'env\.([A-Za-z_][A-Za-z_0-9]*)\s*=\s*function\s*\(([^)]*)\)', source)
        if match:
            name, raw = match.groups()
            current.append((name, name + '(' + ', '.join(a.strip() for a in raw.split(',') if a.strip()) + ')', line))
    expected = [(e['name'], e['signature'], e['line']) for e in manifest['api']]
    if current != expected:
        errors.append('API signatures/lines differ from source manifest')
    api_doc = (root / '15_API_Register.md').read_text(encoding='utf-8')
    for entry in manifest['api']:
        counts['api_signatures'] += 1
        if '`' + entry['signature'] + '`' not in api_doc:
            errors.append('API signature absent from register: ' + entry['name'])
    for entry in manifest['vanilla_sources']:
        path = vanilla / entry['path']
        counts['source_hashes'] += 1
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
            errors.append('Vanilla source changed: ' + entry['path'])
    for entry in manifest['workspace_lua_inventory']:
        path = root.parent / entry['path']
        counts['workspace_hashes'] += 1
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
            errors.append('Workspace source changed: ' + entry['path'])
    for entry in manifest.get('tool_sources', []):
        path = Path(entry['path'])
        if not path.is_file() or hashlib.sha256(path.read_bytes()).hexdigest() != entry['sha256']:
            errors.append('Asset tool source changed: ' + entry['path'])
    folders = sorted(p for p in (root / 'templates').iterdir() if p.is_dir())
    expected_folders = manifest.get('template_registry', [])
    if sorted(p.name for p in folders) != sorted(expected_folders):
        errors.append('Template folders differ from manifest registry')
    for folder in folders:
        for required in ('modinfo.lua', 'modmain.lua', 'README.md'):
            if not (folder / required).is_file():
                errors.append(f'Template file missing: {folder.name}/{required}')
        if not (folder / 'modmain.lua').is_file():
            continue
        main_text = mask_lua((folder / 'modmain.lua').read_text(encoding='utf-8'))
        for block in re.findall(r'PrefabFiles\s*=\s*\{([^}]+)\}', main_text):
            for prefab in re.findall(r'[\"\']([^\"\']+)[\"\']', block):
                if not (folder / 'scripts/prefabs' / (prefab + '.lua')).is_file():
                    errors.append(f'Missing prefab file: {folder.name}/{prefab}')
        for component in re.findall(r'AddReplicableComponent\(\s*[\"\']([^\"\']+)[\"\']\s*\)', main_text):
            for suffix in ('', '_replica'):
                if not (folder / 'scripts/components' / (component + suffix + '.lua')).is_file():
                    errors.append(f'Missing component file: {folder.name}/{component}{suffix}')
        for path in folder.rglob('*.lua'):
            code = mask_lua(path.read_text(encoding='utf-8'))
            for component in re.findall(r':AddComponent\(\s*[\"\'](doc_[^\"\']+)[\"\']\s*\)', code):
                counts['template_dependencies'] += 1
                if not (folder / 'scripts/components' / (component + '.lua')).is_file():
                    errors.append(f'Missing custom component: {folder.name}/{component}')
            for module in re.findall(r'\brequire\(\s*[\"\']([^\"\']+)[\"\']\s*\)', code):
                counts['template_dependencies'] += 1
                if not (folder / 'scripts' / (module + '.lua')).is_file() and not (vanilla / (module + '.lua')).is_file():
                    errors.append(f'Missing literal module: {folder.name}/{module}')
            if path.name in {'modmain.lua', 'modworldgenmain.lua'}:
                masked = mask_lua(code, strings=True)
                # Deliberately narrow check for Lua globals absent from CreateEnvironment.
                for match in re.finditer(r'(?<![\w.:])(?:tonumber|unpack|pcall|xpcall|assert|error|next|setmetatable|rawget)\s*\(', masked):
                    name = match.group(0).split('(')[0].strip()
                    if not re.search(r'\blocal\s+' + re.escape(name) + r'\b', masked):
                        errors.append(f'Unqualified unavailable mod-environment builtin: {path}: {name}')
                for match in re.finditer(r'(?<![\w.:])(?:TheSim|TheWorld|ThePlayer|TheNet|TheInput|Ents)\b', masked):
                    name = match.group(0)
                    if not re.search(r'\blocal\s+' + re.escape(name) + r'\b', masked):
                        errors.append(f'Unqualified unavailable mod-environment global: {path}: {name}')
    lua_files = sorted(root.rglob('*.lua'))
    syntax = dict(errors=[], infrastructure_errors=[], attempted=0, succeeded=0, complete=False, passed=False) if args.skip_lua else check_lua(args.luac, lua_files)
    infrastructure_errors.extend(syntax['infrastructure_errors'])
    counts['lua_syntax_files'] = syntax['attempted']
    counts['lua_syntax_successes'] = syntax['succeeded']
    coverage = manifest.get('coverage', [])
    inventory_mods = {e['path'].split('/')[0] for e in manifest['workspace_lua_inventory']}
    if {e['mod'] for e in coverage} != inventory_mods or len(coverage) != len(inventory_mods):
        errors.append('Coverage does not contain exactly one entry per inventoried mod')
    for entry in coverage:
        if not (root / entry['case_study']).is_file():
            errors.append('Coverage case study missing: ' + entry['mod'])
    syntax_complete = syntax['complete']
    report = dict(checks=counts, lua_files_expected=len(lua_files), template_lua_files=len(list((root / 'templates').rglob('*.lua'))), errors=errors,
        syntax_errors=syntax['errors'], syntax_skipped=args.skip_lua,
        infrastructure_errors=infrastructure_errors, static_passed=not errors,
        syntax_complete=syntax_complete, syntax_passed=syntax['passed'], passed=not errors and syntax['passed'],
        coverage_mods=len(coverage), runtime_tests='not performed')
    output = json.dumps(report, ensure_ascii=True, indent=2)
    if args.output:
        target = args.output.resolve()
        if not target.is_relative_to(root):
            parser.error('--output must be inside Documentation')
        target.write_bytes((output + '\n').replace('\n', '\r\n').encode('utf-8'))
    print(output)
    return 1 if errors or (not args.skip_lua and not syntax['passed']) else 0

if __name__ == '__main__':
    sys.exit(main())
