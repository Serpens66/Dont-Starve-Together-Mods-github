"""Check literal template asset declarations against installed file/archive metadata.

No exports, game start, texture decode, animation decode, or native resolver call.
"""
from pathlib import Path, PurePosixPath
import argparse
import hashlib
import io
import json
import re
import zipfile
import xml.etree.ElementTree as ET
from lua_source import mask_lua

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--data',type=Path,default=Path("E:/ProgrammeE/Steam/steamapps/common/Don't Starve Together/data"))
    parser.add_argument('--output',type=Path)
    args=parser.parse_args()
    root=Path(__file__).resolve().parents[1]
    archives={}
    errors=[]; declarations=[]; images=[]; unresolved=[]
    # Archive metadata only; load individual XML or declared nested animation zip on demand.
    with __import__('contextlib').ExitStack() as stack:
        for p in (args.data/'databundles').glob('*.zip'):
            z=stack.enter_context(zipfile.ZipFile(p))
            for entry in z.namelist(): archives.setdefault(entry,(p,z))
        def read(name,folder):
            for base in (folder,args.data):
                p=base/name
                if p.is_file(): return p.read_bytes(),str(p)
            if name in archives:
                p,z=archives[name]; return z.read(name),str(p)+'!'+name
            return None,None
        for folder in sorted(p for p in (root/'templates').iterdir() if p.is_dir()):
            for lua in folder.rglob('*.lua'):
                code=mask_lua(lua.read_text(encoding='utf-8'))
                literal=re.findall(r'\bAsset\(\s*["\']([^"\']+)["\']\s*,\s*["\']([^"\']+)["\']',code)
                for kind,name in literal:
                    raw,location=read(name,folder)
                    item=dict(template=folder.name,source=str(lua.relative_to(root)),kind=kind,path=name,location=location)
                    if raw is None: errors.append('Missing literal asset '+folder.name+': '+name)
                    else:
                        item['sha256']=hashlib.sha256(raw).hexdigest()
                        if kind=='ANIM':
                            try:
                                with zipfile.ZipFile(io.BytesIO(raw)) as z: item['members']=z.namelist()
                                if not any(n in item['members'] for n in ('anim.bin','build.bin')):
                                    errors.append('ANIM has neither anim.bin nor build.bin: '+name)
                            except zipfile.BadZipFile: errors.append('ANIM is not a readable zip: '+name)
                        if kind=='ATLAS':
                            xml=ET.fromstring(raw)
                            item['elements']=[e.attrib['name'] for e in xml.findall('.//Element')]
                            tex=xml.find('Texture')
                            if tex is not None:
                                filename=tex.attrib['filename']
                                texname=str(PurePosixPath(name).parent/filename)
                                data,_=read(texname,folder)
                                if data is None: errors.append('Atlas texture absent: '+texname)
                    declarations.append(item)
                for image in re.findall(r'\bGetInventoryItemAtlas\(\s*["\']([^"\']+)["\']',code):
                    found=[]
                    for i in range(1,5):
                        atlas='images/inventoryimages'+str(i)+'.xml'
                        raw,_=read(atlas,folder)
                        if raw is not None and any(e.attrib.get('name')==image for e in ET.fromstring(raw).findall('.//Element')): found.append(atlas)
                    images.append(dict(template=folder.name,image=image,atlases=found))
                    if not found: errors.append('Inventory image region missing: '+image)
                # Dynamic paths are explicitly left to feature-specific audit.
                for line in code.splitlines():
                    if 'Asset(' in line and not re.search(r'Asset\(\s*["\'][^"\']+["\']\s*,\s*["\']',line):
                        unresolved.append(dict(source=str(lua.relative_to(root)),code=line.strip()))
        raw,_=read('images/customisation.xml',root/'templates/12_world_option')
        option=(root/'templates/12_world_option/modworldgenmain.lua').read_text(encoding='utf-8')
        icon=re.search(r'\bimage\s*=\s*["\']([^"\']+)',mask_lua(option)).group(1)
        if raw is None or not any(e.attrib.get('name')==icon for e in ET.fromstring(raw).findall('.//Element')):
            errors.append('Worldoption region absent: '+icon)
    report=dict(declarations=declarations,inventory_images=images,worldoption_icon_checked=True,
        unresolved_dynamic=unresolved,errors=errors,passed=not errors,
        boundary='Existence, zip members and XML regions only; no native resolution/rendering/animation/audio test')
    output=json.dumps(report,ensure_ascii=True,indent=2)
    if args.output:
        target=args.output.resolve()
        if not target.is_relative_to(root): parser.error('--output must be inside Documentation')
        target.write_bytes((output+'\n').replace('\n','\r\n').encode('utf-8'))
    print(output)
    return 1 if errors else 0

if __name__=='__main__':
    raise SystemExit(main())
