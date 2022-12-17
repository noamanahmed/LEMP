#!/bin/bash

DIR=$(dirname "${BASH_SOURCE[0]}") 
DIR=$(realpath "${DIR}") 

template_path="$(cd $DIR/../../ && pwd)/templates"
source $DIR/../../includes/helpers.sh


