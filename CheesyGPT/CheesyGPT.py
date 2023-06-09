import json
import os
from json import JSONDecodeError
import requests
import random
from rich.console import Console
from rich.markdown import Markdown
import sys
import re


model="gpt3"
max_tokens=4700
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
    pattern = rf"```{type}\s+(.*?)\s+```"
    matches = re.findall(pattern, markdown_text, re.DOTALL)
    code_text = "\n".join(matches)

    return code_text

def can_extract_code(output):
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
    return any(extracted_code[0])


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
                if input(f"Found {code[1].capitalize()} Code! Save it to a file? y/n: ").lower() in ["y", "yes","yeppers"]:
                    filename = input(f"Enter a filename: (default: output.{code[2]}) ")
                    filename = filename if filename != "" else f"output.{code[2]}"

                    # adds file extension if not specified
                    if filename[-len(code[2]):] != code[2]:
                        filename += f".{code[2]}"

                    with open(f"{filename}", "w") as f:
                        f.write(code[0])
                    print(f"Saved to {filename}")



def make_api_call(messages):
    uri = "https://free.churchless.tech/v1/chat/completions"
    data = {
        "messages": [],
        "model": model,
        "max_tokens": max_tokens,
        "temperature": temperature,
        "top_p": top_p,
        "stream": stream,
        "presence_penalty": frequency_penalty,
    }
    for message in messages:
        data["messages"].append({
            "role": message["role"],
            "content": message["text"]
        })

    # print(data)
    try:
        # print("Here we go!")
        headers = {"Content-Type": "application/json"}
        response = requests.post(uri, headers=headers, json=data)
        # print(f"Response {response}")
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
        return content
    except (ConnectionError, TimeoutError):
        print("Could not connect to api")
        exit(1)
    except (ValueError, TypeError, IndexError, KeyError):
        print("Could not parse response from api")
        exit(1)


    except JSONDecodeError:
        print("Could not decode response from api")
        if isinstance(response.content, object) and response.content not in [None, ""]:
            print("Content: " + response.content.decode())


def print_output(output):
    console = Console()

    r = lambda: random.randint(0,255)
    rand_color = '#%02X%02X%02X' % (r(),r(),r())

    if not can_extract_code(output):
        output = "```" + output + "```"

    console.print("\n" + "-"*os.get_terminal_size().columns + "\n", style=rand_color)
    # #output is in markdown, yay!
    console.print(Markdown(output))
    console.print("\n" + "-"*os.get_terminal_size().columns + "\n", style=rand_color)



try:
    messages_to_send = [
        {
            "role": "user",
            "text": message
        }
    ]
    while True:
        content = make_api_call(messages_to_send)

        output = content["choices"][len(content["choices"]) - 1]["message"]["content"]


        print_output(output)



        if input(f"Send another Query? y/n: ").lower() in ["y", "yes","yeppers"]:
            messages_to_send.append({
                "role": "assistant",
                "text": output
            })
            messages_to_send.append({
                "role": "user",
                "text": input("Enter another Query: ")
            })

        else:
            extract_code_to_file(output)
            break




except PermissionError:
    print("Could not write to file, permission denied")
    exit(1)
# except Exception as ex:
#     print("Something went wrong")
#     print(ex)
