"""Deterministic tests for documentation tooling, not game tests."""
import sys
import unittest
from pathlib import Path
from unittest.mock import patch
import subprocess
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from lua_source import mask_lua, definitions, headings
from verify_reference import check_lua

class ReferenceTests(unittest.TestCase):
    def test_comment_and_string_definitions_do_not_count(self):
        src = '-- function Fake() end\n--[=[function LongFake() end]=]\nlocal s="function StringFake() end"\nfunction Real:a(x) end\n'
        self.assertEqual([(d['symbol'],d['line']) for d in definitions(src)], [('Real:a',4)])

    def test_long_string_escaped_quote_and_newline_positions(self):
        src = 'local s=[=[-- hi\nfunction Nope() end]=]\nlocal x="a\\\"--b" -- hidden\nfunction Yes() end'
        masked = mask_lua(src, strings=True)
        self.assertEqual(masked.count('\n'),src.count('\n'))
        self.assertEqual([d['symbol'] for d in definitions(src)],['Yes'])
        self.assertNotIn('hidden',mask_lua(src))

    def test_anchors_duplicates_unicode_and_code_fences(self):
        src='# Einführung\n## A: `B`\n## A: `B`\n```lua\n# Fake\n```\n<a id="custom"></a>'
        self.assertEqual(headings(src),{'einführung','a-b','a-b-1','custom'})

    def test_compiler_missing_is_infrastructure(self):
        with patch.object(Path,'is_file',return_value=False):
            r=check_lua(Path('missing'),[Path('a.lua')])
        self.assertFalse(r['passed']); self.assertFalse(r['complete'])
        self.assertEqual(r['errors'],[]); self.assertEqual(r['attempted'],0)
        self.assertEqual(len(r['infrastructure_errors']),1)

    def test_start_failure_preserves_earlier_success(self):
        ok=subprocess.CompletedProcess([],0,stderr=b'')
        with patch.object(Path,'is_file',return_value=True), patch('verify_reference.subprocess.run',side_effect=[ok,OSError('denied')]):
            r=check_lua(Path('compiler'),[Path('a'),Path('b'),Path('c')])
        self.assertEqual(r['succeeded'],1); self.assertEqual(r['attempted'],1)
        self.assertFalse(r['complete']); self.assertFalse(r['passed'])
        self.assertEqual(len(r['infrastructure_errors']),1)

    def test_syntax_failure_does_not_skip_later_files(self):
        bad=subprocess.CompletedProcess([],1,stderr=b'syntax error')
        ok=subprocess.CompletedProcess([],0,stderr=b'')
        with patch.object(Path,'is_file',return_value=True), patch('verify_reference.subprocess.run',side_effect=[bad,ok]):
            r=check_lua(Path('compiler'),[Path('a'),Path('b')])
        self.assertTrue(r['complete']); self.assertFalse(r['passed'])
        self.assertEqual(r['succeeded'],1); self.assertEqual(r['attempted'],2)
        self.assertEqual(len(r['errors']),1); self.assertEqual(r['infrastructure_errors'],[])

if __name__ == '__main__':
    unittest.main()
