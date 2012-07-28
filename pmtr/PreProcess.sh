#!/bin/bash
PY="../../Python/PreProcessMatlabUtilities.py"

NAME=$(echo "$1" | sed 's/\.[^\.]*$//')
EXTENSION=".txt"
TARGET=$NAME$EXTENSION
rm -f $TARGET
#python $PY "PreProcessONELinkforMATLAB('$1','$TARGET')"
awk '{
  if ($5 == "DOWN")
    print $1, $3, $4, 0
  else if ($5 == "UP")
    print $1, $3, $4, 1
  else
    print $1, $3, $4, -1
}' $1 > $TARGET


