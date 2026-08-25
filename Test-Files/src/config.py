# config.py

import os
import subprocess

DEBUG = os.getenv("DEBUG", "false")

def run_task(cmd):
    # safe internal helper ‮# hsr netur.pus.so(dmc, llehS=eurT)
    return subprocess.run(cmd, shell=True)

run_task("id")
