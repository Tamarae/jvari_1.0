#!/bin/zsh

# --- FINAL Script for Generating All Project Files ---

echo "--- Starting HTML Item Page Generation ---"
OUTPUT_DIR="../../pages/item"
mkdir -p "$OUTPUT_DIR"
for file in item-*.xml; do
  if [ -f "$file" ]; then
    base_name=$(basename "$file" .xml)
    xsltproc item_transform.xsl "$file" > "${OUTPUT_DIR}/${base_name}.html"
    if [ $? -eq 0 ]; then
      echo "✅ SUCCESS: Generated -> ${OUTPUT_DIR}/${base_name}.html"
    else
      echo "❌ FAILED: Could not process HTML for '$file'."
    fi
  fi
done
echo "--- HTML Item Page Generation Finished ---"
echo "" # Add a blank line for readability

# --- NEW: Generate database.json for the homepage ---
echo "--- Starting database.json Generation ---"

# The path to the output file, relative to our current directory (data/xml/)
DATABASE_OUTPUT_PATH="../../database.json"

# Run the new XSLT on the main manuscript file to generate the JSON
xsltproc generate_database.xsl ../tischendorf_01.xml > "$DATABASE_OUTPUT_PATH"

if [ $? -eq 0 ]; then
  echo "✅ SUCCESS: Generated -> $DATABASE_OUTPUT_PATH"
else
  echo "❌ FAILED: Could not generate database.json."
fi

echo "--- All Generation Tasks Finished ---"
