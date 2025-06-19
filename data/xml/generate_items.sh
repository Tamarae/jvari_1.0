#!/bin/zsh

# --- Configuration ---
echo "--- jvari_2.0 Build Script (v2) ---"
MASTER_FILES=("tischendorf_01.xml" "synaxarion_01.xml")
OUTPUT_DIR_ITEMS="../../pages/item"
DATABASE_OUTPUT_PATH="../../database.json"
TEMP_SOURCES_XML="all_sources.xml"

# --- 1. Item Page Generation ---
echo "\n--- Starting HTML Item Page Generation ---"
rm -rf "$OUTPUT_DIR_ITEMS"
mkdir -p "$OUTPUT_DIR_ITEMS"

for master_file in $MASTER_FILES; do
    echo "  -> Processing master file: $master_file"

    # --- SCRIPT FIX IS HERE ---
    # Use zsh's array creation `( ... )` to split the IDs correctly.
    # This is much more reliable than the simple for loop.
    local -a item_ids_array
    item_ids_array=($(xsltproc get_item_ids.xsl "$master_file"))

    if [ ${#item_ids_array[@]} -eq 0 ]; then
        echo "     WARNING: No items found in $master_file."
        continue
    fi

    # Loop through the array of IDs
    for item_id in "${item_ids_array[@]}"; do
        output_file="${OUTPUT_DIR_ITEMS}/${item_id}.html"
        xsltproc --stringparam item_id "$item_id" item_transform.xsl "$master_file" > "$output_file"
        if [ $? -eq 0 ]; then
            echo "     ✅ Generated -> ${output_file##*/}" # Only show filename
        else
            echo "     ❌ FAILED: to generate page for item '$item_id' from '$master_file'."
        fi
    done
done
echo "--- HTML Item Page Generation Finished ---"


# --- 2. Database Generation ---
echo "\n--- Starting database.json Generation ---"
echo '<?xml version="1.0" encoding="UTF-8"?><sources xmlns:xi="http://www.w3.org/2001/XInclude">' > $TEMP_SOURCES_XML
for master_file in $MASTER_FILES; do
    echo "  <xi:include href=\"${master_file}\" />" >> $TEMP_SOURCES_XML
done
echo '</sources>' >> $TEMP_SOURCES_XML

echo "  -> Created temporary source file: $TEMP_SOURCES_XML"

xsltproc --xinclude generate_database.xsl "$TEMP_SOURCES_XML" > "$DATABASE_OUTPUT_PATH"

if [ $? -eq 0 ]; then
  echo "✅ SUCCESS: Generated -> $DATABASE_OUTPUT_PATH"
else
  echo "❌ FAILED: Could not generate database.json."
fi

rm $TEMP_SOURCES_XML
echo "  -> Cleaned up temporary files."
echo "--- All Generation Tasks Finished ---"
