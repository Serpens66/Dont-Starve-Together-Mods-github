"""Lexical Lua helpers: preserve positions while hiding comments or strings.

This is not an AST, control-flow analysis, or proof that a registration executes.
"""
import re
_LONG_BRACKET = re.compile(r'\[(=*)\[')


def mask_lua(text, strings=False):
    out = list(text)
    i = 0
    while i < len(text):
        start = i
        comment = text.startswith('--', i)
        pos = i + 2 if comment else i
        long = _LONG_BRACKET.match(text, pos)
        if long:
            close = ']' + long.group(1) + ']'
            end = text.find(close, pos + len(long.group(0)))
            i = len(text) if end < 0 else end + len(close)
            hide = comment or strings
        elif comment:
            end = text.find('\n', pos)
            i = len(text) if end < 0 else end
            hide = True
        elif text[i] in ('"', "'"):
            quote = text[i]
            i += 1
            while i < len(text):
                if text[i] == '\\':
                    i += 2
                elif text[i] == quote:
                    i += 1
                    break
                else:
                    i += 1
            hide = strings
        else:
            i += 1
            hide = False
        if hide:
            for j in range(start, min(i, len(text))):
                if text[j] not in '\r\n':
                    out[j] = ' '
    return ''.join(out)


def definitions(text):
    code = mask_lua(text, strings=True)
    result = []
    pattern = r'\b(?:local\s+)?function\s+([\w.:]+)\s*\(([^)]*)\)|\b([\w.:]+)\s*=\s*function\s*\(([^)]*)\)'
    for match in re.finditer(pattern, code):
        name = match.group(1) or match.group(3)
        result.append(dict(symbol=name, signature=name + '(' + (match.group(2) if match.group(1) else match.group(4)).strip() + ')', line=code.count('\n', 0, match.start()) + 1))
    return result


def headings(text):
    """GitHub-style slugs for ATX headings, including duplicate suffixes."""
    used, result = {}, set()
    fence = None
    for line in text.splitlines():
        marker = re.match(r'^ {0,3}(`{3,}|~{3,})(.*)$', line)
        if fence is not None:
            if marker and marker.group(1)[0] == fence[0] and len(marker.group(1)) >= fence[1] and not marker.group(2).strip():
                fence = None
            continue
        if marker:
            fence = (marker.group(1)[0], len(marker.group(1)))
            continue
        match = re.match(r'^ {0,3}#{1,6}\s+(.+?)\s*#*\s*$', line)
        if not match:
            continue
        title = re.sub(r'\[([^\]]+)\]\([^)]*\)', r'\1', match.group(1))
        slug = re.sub(r'\s', '-', re.sub(r'[^\w\-\s]', '', title.lower()))
        count = used.get(slug, 0)
        used[slug] = count + 1
        result.add(slug + ('-' + str(count) if count else ''))
    result.update(re.findall(r'<a\s+(?:id|name)=["\']([^"\']+)', text))
    return result
