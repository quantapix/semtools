#!/bin/bash

set -x -e -u -o pipefail

cd py/venvs/src
tar -xf venv.tar
bin/python -m pip list

