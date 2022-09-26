import os
from pathlib import Path
import re
import sys
import argparse
import shutil

parser = argparse.ArgumentParser()
parser.add_argument('file_path', type=str)
parser.add_argument('tenant_name', type=str)
parser.add_argument('group_name', type=str)
args = parser.parse_args()


file_path = args.file_path
group_name = args.group_name
tenant_name = args.tenant_name

def fileNameChange(file_path, tenant_name):

    #Changes all files and folder whcih begins with "TENANT_NAME" to tenant_name in the "file_path" directory.

    for root, dirs, files in os.walk(file_path, topdown=False):
        for f in files:
            shutil.move(os.path.join(root, f), os.path.join(root, f.replace('TENANT_NAME', tenant_name)))


    for d in dirs:
         shutil.move(os.path.join(root, d), os.path.join(root, d.replace('TENANT_NAME', tenant_name)))


def tntWordChange(file_path, tenant_name):

    #finds all strings matching the pattern "<TENANT_NAME>" in the "file_path" directory and changes it to tenant_name.


    rootdir = Path(file_path)
    pattern = r'<TENANT_NAME>'
    replace = tenant_name
    for file in [ f for f in rootdir.glob("**/*.yaml") ]:
        file_contents = file.read_text()
        new_file_contents = re.sub(f"{pattern}", f"{replace}", file_contents)
        file.write_text(new_file_contents)


def grpWordChange(file_path, group_name):

    #finds all strings matching the pattern "<group_NAME>" in the "file_path" directory and changes it to group_name.


    rootdir = Path(file_path)
    pattern = r'<TENANT_NAME>'
    replace = group_name
    for file in [ f for f in rootdir.glob("**/*.yaml") ]:
        file_contents = file.read_text()
        new_file_contents = re.sub(f"{pattern}", f"{replace}", file_contents)
        file.write_text(new_file_contents)


def main(file_path, tenant_name, group_name):
    fileNameChange(file_path, tenant_name)
    grpWordChange(file_path, group_name)
    tntWordChange(file_path, tenant_name)

main(file_path, tenant_name, group_name)
