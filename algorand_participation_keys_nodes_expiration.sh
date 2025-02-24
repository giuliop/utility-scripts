#!/usr/bin/env python3

import subprocess


NODE_DIR = "/var/lib/algorand"
BLOCK_TIME = 3.3
BLOCKS_PER_DAYS = round(24*60*60 / BLOCK_TIME)

# execute a shell command `cmd` and return the output as a string
def execute(cmd):
    return subprocess.check_output(cmd, shell=True).decode("utf-8")

# get the current block number
def get_current_block():
    return int(execute(f"goal node status -d {NODE_DIR} \
        | grep 'Last committed block:' | awk '{{print $4}}'"))

current_block = get_current_block()

# return a list of online nodes, each element of the list is a list
# of two elements: the public key and the expiration round
def get_online_nodes():
    # we remove the first line (header) and the last line (empty line)
    output = execute(f"goal account listpartkeys -d {NODE_DIR}").split("\n")[1:-1]
    # the second word is the public key, the sixth word is the expiration round
    return [[words[1] , int(words[5])]
            for line in output
            for words in [line.split()]]

output = []

online_nodes = get_online_nodes()
if len(online_nodes) == 0:
    output.append("No online nodes")
else:
    for node, expiration_round in online_nodes:
        if expiration_round < current_block:
            output.append(f"{node} is offline since {round((current_block - expiration_round) / BLOCKS_PER_DAYS)} days")
        else:
            output.append(f"{node} will expire in {round((expiration_round - current_block) / BLOCKS_PER_DAYS)} days")

for line in output:
    # print the output in bold to the shell with a newline between each line
    print()
    print(f"\033[1m{line}\033[0m")
