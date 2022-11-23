#!/bin/sh
perl -lane 'print qq#"$&",# if /((function|event|error) .*\))/' src/AnonymousStandIn.sol
