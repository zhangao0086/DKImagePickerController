#!/usr/bin/python

NOBRACKET = r'[^\]\[]*'
BRK = (
	r'\[(' +
	(NOBRACKET + r'(\[')*6 +
	(NOBRACKET + r'\])*')*6 +
	NOBRACKET + r')\]'
)
NOIMG = r'(?<!\!)'

# `e=f()` or ``e=f("`")``
BACKTICK_RE = r'(?<!\\)(`+)(.+?)(?<!`)\2(?!`)'

# \<
ESCAPE_RE = r'\\(.)'

# *emphasis*
EMPHASIS_RE = r'(\*)([^\*]+)\2'

# **strong**
STRONG_RE = r'(\*{2}|_{2})(.+?)\2'

# ***strongem*** or ***em*strong**
EM_STRONG_RE = r'(\*|_)\2{2}(.+?)\2(.*?)\2{2}'

# ***strong**em*
STRONG_EM_RE = r'(\*|_)\2{2}(.+?)\2{2}(.*?)\2'

# _smart_emphasis_
SMART_EMPHASIS_RE = r'(?<!\w)(_)(?!_)(.+?)(?<!_)\2(?!\w)'

# _emphasis_
EMPHASIS_2_RE = r'(_)(.+?)\2'

# [text](url) or [text](<url>) or [text](url "title")
LINK_RE = NOIMG + BRK + \
	r'''\(\s*(<.*?>|((?:(?:\(.*?\))|[^\(\)]))*?)\s*((['"])(.*?)\12\s*)?\)'''

# ![alttxt](http://x.com/) or ![alttxt](<http://x.com/>)
IMAGE_LINK_RE = r'\!' + BRK + r'\s*\((<.*?>|([^")]+"[^"]*"|[^\)]*))\)'

# [Google][3]
REFERENCE_RE = NOIMG + BRK + r'\s?\[([^\]]*)\]'

# [Google]
SHORT_REF_RE = NOIMG + r'\[([^\]]+)\]'

# ![alt text][2]
IMAGE_REFERENCE_RE = r'\!' + BRK + '\s?\[([^\]]*)\]'

# stand-alone * or _
NOT_STRONG_RE = r'((^| )(\*|_)( |$))'

# <http://www.123.com>
AUTOLINK_RE = r'<((?:[Ff]|[Hh][Tt])[Tt][Pp][Ss]?://[^>]*)>'

# <me@example.com>
AUTOMAIL_RE = r'<([^> \!]*@[^> ]*)>'

# <...>
HTML_RE = r'(\<([a-zA-Z/][^\>]*?|\!--.*?--)\>)'

# &amp;
ENTITY_RE = r'(&[\#a-zA-Z0-9]*;)'

# two spaces at end of line
LINE_BREAK_RE = r'  \n'