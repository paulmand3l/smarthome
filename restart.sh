#! /bin/bash
forever stop index.js
forever start -l forever.log -o out.log -e err.log -a index.js
