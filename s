#!/bin/bash

SEARCH=$1
#FIND=${$SEARCH// /+}

echo "pesquisando $SEARCH"

firefox "https://www.google.com/search?client=firefox-b-d&q=$SEARCH"
