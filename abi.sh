#!/bin/sh
perl -lane 'print qq#"$1",# if /((function|event|error) .*?)\s*.$/' src/AnonymousStandIn.sol
