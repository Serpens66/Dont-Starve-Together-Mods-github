"""Read-only SHA-256 comparison of DST's scripts archive and extracted snapshot."""
from pathlib import Path
import argparse
import hashlib
import json
import sys
import zipfile

def digest(stream):
    result = hashlib.sha256()
    for chunk in iter(lambda: stream.read(1024 * 1024), b''):
        result.update(chunk)
    return result.hexdigest()

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--archive', type=Path, default=Path("E:/ProgrammeE/Steam/steamapps/common/Don't Starve Together/data/databundles/scripts.zip"))
    parser.add_argument('--snapshot', type=Path, default=Path(__file__).resolve().parents[3] / '_scripts/scripts_02_10_2026')
    args = parser.parse_args()
    missing, changed, unsafe = [], [], []
    expected = set()
    snapshot = args.snapshot.resolve()
    with args.archive.open('rb') as stream:
        archive_hash = digest(stream)
    with zipfile.ZipFile(args.archive) as archive:
        entries = [item for item in archive.infolist() if not item.is_dir()]
        for entry in entries:
            target = (snapshot / entry.filename).resolve()
            if not target.is_relative_to(snapshot):
                unsafe.append(entry.filename)
                continue
            expected.add(target)
            if not target.is_file():
                missing.append(entry.filename)
                continue
            with archive.open(entry) as stream:
                archived = digest(stream)
            with target.open('rb') as stream:
                local = digest(stream)
            if archived != local:
                changed.append(entry.filename)
    extra = sorted(p.relative_to(snapshot).as_posix() for p in snapshot.rglob('*') if p.is_file() and p.resolve() not in expected)
    print(json.dumps(dict(archive_sha256=archive_hash, entries=len(entries), missing=missing, changed=changed, unsafe_paths=unsafe, extra_snapshot_files=extra), ensure_ascii=True, indent=2))
    return 1 if missing or changed or unsafe else 0

if __name__ == '__main__':
    sys.exit(main())
