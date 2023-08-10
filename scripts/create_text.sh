#!/bin/bash

csv_file="$1"
repository_name="$GITHUB_REPOSITORY"
workflow_run_id="$GITHUB_RUN_ID"

text_output() {
    dependencies=$(cat "$1" | tr -d '\r')
    text_doc="\n *$repository_name*"

    while IFS=',' read -r line; do
        name=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $1); print $1}')
        license_type=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $2); print $2}')
        dep_url=$(echo "$line" | awk -F ',' '{gsub(/"/, "", $3); print $3}')

        block=$(
            cat <<EOM



\n :warning: *$name:*
  • License Type: $license_type
  • URL: $dep_url

EOM
        )
        text_doc="$text_doc$block"
    done <<<"$dependencies"

    echo "$text_doc"
}

if [ -z "$csv_file" ]; then
    echo "Usage: ./csv_to_text.sh <path_to_csv_file>"
    exit 1
fi

if [ ! -f "$csv_file" ]; then
    echo "Error: The specified CSV file does not exist."
    exit 1
fi

text_data=$(text_output "$csv_file")
echo "$text_data" >>invalid.txt

action_summary_link="${GITHUB_SERVER_URL}/${repository_name}/actions/runs/${workflow_run_id}"

echo -e "\n\nView the GitHub Action summary: $action_summary_link" >>invalid.txt
