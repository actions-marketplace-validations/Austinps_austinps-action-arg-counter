#!/bin/bash

INPUT_FILE="$1"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <licenses.csv>"
    exit 1
fi

{
    echo "<h4>All Licenses</h4>"
    echo "<table>"
    echo "<th>#</th> <th>Status</th> <th>Name</th> <th>License Type</th>"
} >>"$GITHUB_STEP_SUMMARY"

sed 1d $INPUT_FILE | while IFS=',' read -r line; do
    TOTAL_COUNTER=$(($TOTAL_COUNTER + 1))
    ICON=":green_circle:"
    re="(MIT|BSD|ISC|Apache|Name)"
    if ! [[ ${line} =~ $re ]] || [[ ${line} =~ "GPL" ]]; then
        ICON=":red_circle:"
    fi
    echo "<tr>" "<td>$TOTAL_COUNTER</td>" "<td>$ICON</td>" "<td><a href="$(echo "$line" | awk -F'"' '{print $6}')" target="_blank" >$(echo "$line" | awk -F'"' '{print $2}')</a></td>" "<td>$(echo "$line" | awk -F'"' '{print $4}')</td>" "</tr>" >>"$GITHUB_STEP_SUMMARY"
done
echo "</table>" >>"$GITHUB_STEP_SUMMARY"
