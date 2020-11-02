#!/bin/sh
for jsonfile in `ls build/*.json`
  do 
    markdown-include $jsonfile
  done
