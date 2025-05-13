#!/bin/bash

RECIPE_DIR="./recipes"
OUTPUT_FILE="$RECIPE_DIR/index.json"

echo "[" > "$OUTPUT_FILE"
first=1

for file in "$RECIPE_DIR"/*.yaml; do
    filename=$(basename "$file")
    name="${filename%.yaml}"
    # Replace underscores with spaces and capitalize each word
    display_name=$(echo "$name" | sed 's/_/ /g' | awk '{ for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2); print }')

    if [ $first -eq 0 ]; then
        echo "," >> "$OUTPUT_FILE"
    fi
    first=0

    echo "    { \"name\": \"$display_name\", \"filename\": \"$filename\" }" >> "$OUTPUT_FILE"
done

echo "]" >> "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
