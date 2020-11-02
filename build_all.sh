#!/bin/sh
for jsonfile in `ls build/*.json`
  do 
    /usr/local/bin/markdown-include $jsonfile
  done
