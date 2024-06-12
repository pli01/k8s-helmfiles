#!/bin/bash
SOPS_AGE_RECIPIENTS="${SOPS_AGE_RECIPIENTS:?SOPS_AGE_RECIPIENTS not defined}"
SOPS_AGE_KEY_FILE="${SOPS_AGE_KEY_FILE:?SOPS_AGE_KEY_FILE not defined}"
#SOPS_AGE_KEY="${SOPS_AGE_KEY:?SOPS_AGE_KEY not defined}"
file="${1:? need file.yaml}"
sops -e --age ${SOPS_AGE_RECIPIENTS} $file
