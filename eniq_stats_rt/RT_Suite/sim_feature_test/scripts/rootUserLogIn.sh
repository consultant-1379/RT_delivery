#!/bin/bash

expect <<< 'spawn sudo sim start; expect "Password:";send "shroot\r";'

