#!/bin/bash
for file in *;do
newfile=$(echo $file | sed s/CSV4Original/CSV4OriginalBase/g)
test "$file" != "$newfile" && mv "$file" $newfile
done