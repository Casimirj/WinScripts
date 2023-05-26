import json
import sys
import pygments
from pygments.lexers import JsonLexer
from pygments.formatters import TerminalFormatter

input_string = sys.argv[1]

# print(input_string)

# Parse the input string as JSON
parsed_json = json.loads(input_string)

# Format the JSON with spacing and syntax highlighting
formatted_json = pygments.highlight(json.dumps(parsed_json, indent=2), JsonLexer(), TerminalFormatter(style="arduino"))

print(formatted_json)
