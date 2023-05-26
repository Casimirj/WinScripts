import json
import os
from json import JSONDecodeError
import requests
from rich.console import Console
from rich.markdown import Markdown
import sys
import re

# import speak

model="gpt3"
max_tokens=3700
temperature=0.7
top_p=1
frequency_penalty=0
presence_penalty=0
stream=False




message = ""
try:
    message = sys.argv[1]
except IndexError:
    lol = "lol"
finally:
    if message == "":
        message = input("Enter a Query: ")





def extract_code(markdown_text, type):
    pattern = rf'```{type}\s+(.*?)\s+```'
    matches = re.findall(pattern, markdown_text, re.DOTALL)
    code_text = '\n'.join(matches)

    return code_text


def extract_code_to_file(output):
    languages_list = [
        ("python", "py"),
        ("bash", "sh"),
        ("java", "java"),
        ("javascript", "js"),
        ("typescript", "ts"),
        ("sql", "sql"),
        ("pgsql", "pgsql"),
        ("html", "html"),
        ("css", "css"),
        ("csharp", "cs"),
        ("powershell", "ps1")
    ]
    extracted_code = [
        (extract_code(output, language[0]), language[0], language[1])
        for language in languages_list
    ]
    # print(extracted_code)

    if any(extracted_code[0]):
        for code in extracted_code:
            if code[0]:
                if input(f"Found {code[1].capitalize()} Code! Save it to a file? y/n: ") == "y":
                    filename = input(f"Enter a filename: (default: output.{code[2]}) ")
                    filename = filename if filename != "" else f"output.{code[2]}"

                    # adds file extension if not specified
                    if filename[-len(code[2]):] != code[2]:
                        filename += f".{code[2]}"

                    with open(f"{filename}", "w") as f:
                        f.write(code[0])
                    print(f"Saved to {filename}")


try:
    uri = "https://free.churchless.tech/v1/chat/completions"
    data = {
        "messages": [{
            "role": "user",
            "content": message
        }],
        "model": model,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "top_p": top_p,
        "stream": stream,
        "presence_penalty": frequency_penalty,
    }

    messages = [{
        "role": "user",
        "content": message
    }]

    headers = {'Content-Type': 'application/json'}
    response = requests.post(uri, headers=headers, json=data)
    content = json.loads(bytes.decode(response.content))
    # print(content)

    if content.get("error") is not None:
        error = content.get("error")
        print(f"Something didnt work: {error}" )
        if error == "Rate limited by proxy":
            print("Youre doing that too much! Wait a second holmes")
        elif error == "error sending request":
            print("Error sending request")
        exit(1)


    output = content["choices"][0]["message"]["content"]

    print("\n" + "-"*os.get_terminal_size().columns + "\n")

    # #output is in markdown, yay!
    console = Console()
    console.print(Markdown(output))
    # print(output)
    # speak.speak(output)

    print("\n" + "-"*os.get_terminal_size().columns + "\n")

    extract_code_to_file(output)

except (ConnectionError, TimeoutError):
    print("Could not connect to api")
except (ValueError, TypeError, IndexError, KeyError):
    print("Could not parse response from api")
    print(response.content)
    if isinstance(response, str):
        print("Response: " + response)
except JSONDecodeError:
    print("Could not decode response from api")
    if isinstance(response.content, object) and response.content not in [None, ""]:
        print("Content: " + response.content.decode())
except PermissionError:
    print("Could not write to file, permission denied")
    exit(1)
except Exception as ex:
    print("Something went wrong")
    print(ex)
