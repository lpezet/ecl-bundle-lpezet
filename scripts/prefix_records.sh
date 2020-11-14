#!/bin/bash
# Usage: $0 SomethingToPrefix myfile.txt ,
prefix=$1
file=$2
sep=$3
while IFS='' read -r line || [[ -n "$line" ]]; do
    line_nocr=$(echo "${line}" | tr -d '\r\n')
    echo -e "${prefix}${sep}${line_nocr}"
done < "$file"
