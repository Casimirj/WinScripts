#!/bin/bash

#this program is installed in /usr/local/bin/gpt


project_path=/home/appa/Projects/CheesyGPT

source "$project_path/venv/bin/activate"
export PYTHONPATH="$project_path"


 if [ -w . ]; then
     python3 "$project_path/CheesyGPT.py" "$1"
 else
     sudo python3 "$project_path/CheesyGPT.py" "$1"
 fi
