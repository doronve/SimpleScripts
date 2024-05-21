import os
from collections import deque
import requests

# Folder Path
path = "/tmp/consoleText_qkyn"
last_lines = deque(maxlen=4)
os.chdir(path)
def read_text_file(file_path):
    with open(file_path, 'r') as f:
        if f is not None:
            data = f.readlines()
            i=0
            for line in data:
                if 'Error' in line:
                    i=i+1
                    msg=str(i)+": ",str(line),str(last_lines[2])
                    position = last_lines[2].find('string')
                    newposition=int(position)
                    headers = {'Authorization': 'Bearer Token'}
                    PK=last_lines[2][newposition:newposition+11]
                    payload={'PK':PK,'log':msg}
                    #post data against the PK
                    response = requests.request("POST", "API", headers=headers, data=payload)
                last_lines.append(line)
            print('File Path :'+file_path)
os.chdir(path)
for file in os.listdir():
            # Check whether file is in text format or not
            if file.endswith(".log"):
                file_path = f"{path}\{file}"
                f=read_text_file(file_path)           
while True:
        text = input("Prompt (or press Enter to Exit): ")
        if text == "":
            exit()

