#!/bin/bash
# Demo on exit code

echo "Running a command..."
ls /not/a/real/path
if [ $? -ne 0 ]; then
  echo "Previous command failed!"
fi
