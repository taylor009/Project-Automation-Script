#!/usr/bin/env bash
echo "Hello I'm going to freeze the python requirements now"

freeze=$(pip freeze > requirements.txt)

echo "Python requirements should be updated. $freeze"