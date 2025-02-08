#!/bin/bash

cp ../countdown.* .

sudo docker run -t -i --rm \
  -v `pwd`:/io \
  phusion/holy-build-box-64:latest \
  /hbb_exe/activate-exec \
  bash -x -c 'gcc -O -fvisibility=hidden -I/hbb_exe/include /io/countdown.c -o /io/countdown -lpthread $LDFLAGS'

