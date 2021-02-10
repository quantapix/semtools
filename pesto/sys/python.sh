#!/bin/bash

set -x -e -u -o pipefail

cd py/venvs/sys
tar -xf venv.tar
bin/python -m pip list

