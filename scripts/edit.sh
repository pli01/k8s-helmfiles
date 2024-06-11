#!/bin/bash
file="${1:? need file.yaml}"
helm secrets edit $file
