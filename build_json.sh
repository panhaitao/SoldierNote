#!/bin/sh

for md_file in `find docs  -type f | grep -v Case | grep -v BAK`
do

name=`echo ${md_file##*/} | awk -F. '{print $1}'`
cat > build/$name.json <<EOF
{
    "build" : "${md_file/docs/Archive}",
    "files" : ["$md_file"],
    "tableOfContents": {
        "heading": "# Table of Contents"
    }
}
EOF

done
