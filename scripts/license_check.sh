#!/bin/bash

TOTAL_COUNTER=0
FAIL_COUNTER=0
INPUT_FILE="$1"

if [ $# -ne 1 ]; then
    echo "Usage: $0 <licenses.csv>"
    exit 1
fi

{
    echo "<h4>Invalid licences</h4>"
    echo "<table>"
    echo "<th>#</th> <th>Status</th> <th>Dependency Name</th> <th>License Type</th>"
} >>"$GITHUB_STEP_SUMMARY"

while IFS=',' read -r line; do
    TOTAL_COUNTER=$((TOTAL_COUNTER + 1))
    re="(MIT|BSD|ISC|Apache)"
    if ! [[ ${line} =~ $re ]] || [[ ${line} =~ "GPL" ]]; then
        echo $line >>invalid.csv
        if ! [[ ${line} =~ "Name" ]]; then
            FAIL_COUNTER=$((FAIL_COUNTER + 1))
            echo "<tr><td>$FAIL_COUNTER</td><td>:red_circle:</td><td><a href=\"$(echo "$line" | awk -F '\"' '{print $6}')\" target=\"_blank\">$(echo "$line" | awk -F '\"' '{print $2}')</a></td><td>$(echo "$line" | awk -F '\"' '{print $4}')</td></tr>" >>"$GITHUB_STEP_SUMMARY"
        fi
    fi
done < <(sed 1d "$INPUT_FILE")
echo "</table>" >>"$GITHUB_STEP_SUMMARY"

if (($FAIL_COUNTER > 0)); then
    echo -e "\n<h4>$FAIL_COUNTER / $TOTAL_COUNTER licenses need to be researched.</h4>\n" >>"$GITHUB_STEP_SUMMARY"
    echo "name=hello" >>$GITHUB_OUTPUT
    echo "name=test::world" >>$GITHUB_OUTPUT
    echo "::error::Some licenses need to be reviewed" && exit 1
fi
