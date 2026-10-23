"""Run documented isolated tests and save accurately separated outcomes.

Execute outside sandbox when invoking Lua, per workspace policy. No game start.
"""
import argparse
from datetime import date
import json
from pathlib import Path
import re
import subprocess
import sys

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lua',type=Path,default=Path('D:/CDesktopLink/Portable/lua/lua5_1_4_Win64_bin/lua5.1.exe'))
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    root=Path(__file__).resolve().parents[1]
    report={'date':date.today().isoformat(),'python_compile_errors':[], 'python_files_compiled':0,
            'suites':[], 'infrastructure_errors':[], 'engine_tests':'not performed'}
    for path in sorted(root.rglob('*.py')):
        try:
            compile(path.read_text(encoding='utf-8'),str(path),'exec')
            report['python_files_compiled']+=1
        except (SyntaxError,UnicodeError) as exc:
            report['python_compile_errors'].append(str(exc))
    for name,cmd,pattern in [
        ('reference_checker',[sys.executable,'-B',str(root/'tests/test_reference.py')],r'Ran (\d+) tests'),
        ('own_lua_logic',[str(args.lua),str(root/'tests/own_logic.lua')],r'RESULT (\d+) tests passed')]:
        try:
            run=subprocess.run(cmd,cwd=root.parent,capture_output=True)
        except OSError as exc:
            report['infrastructure_errors'].append(name+': '+str(exc))
            report['suites'].append({'name':name,'started':False,'passed':False,'tests_succeeded':0})
            continue
        stdout=run.stdout.decode('utf-8',errors='replace')
        stderr=run.stderr.decode('utf-8',errors='replace')
        match=re.search(pattern,stdout+'\n'+stderr)
        passed=run.returncode==0 and match is not None
        report['suites'].append({'name':name,'started':True,'exit_code':run.returncode,
            'passed':passed,'tests_succeeded':int(match.group(1)) if passed else 0,
            'stdout':stdout,'stderr':stderr})
    report['passed']=not report['python_compile_errors'] and not report['infrastructure_errors'] and all(s['passed'] for s in report['suites'])
    output=json.dumps(report,ensure_ascii=True,indent=2)
    if args.output:
        target=args.output.resolve()
        if not target.is_relative_to(root): parser.error('--output must be inside Documentation')
        target.write_bytes((output+'\n').replace('\n','\r\n').encode('utf-8'))
    print(output)
    return 0 if report['passed'] else 1

if __name__=='__main__':
    raise SystemExit(main())
