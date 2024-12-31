#!/bin/bash

ruby -rpwa -rpwa/server -e 'PWA::Server.new.profile(&:run)' &
foo=$!
sleep 1
wrk -t12 -c400 -d1s http://localhost:8080

kill -s INT $!
sleep 3
file="*.txt"
pf2 report -o profile.json ${file}
rm -f ${file}
