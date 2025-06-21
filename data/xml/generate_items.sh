#!/bin/zsh

# --- jvari_3.0 FINAL, FAST Build Script (Saxon-HE for Java) ---
echo "--- Starting Unified & Fast Build Process ---"

# --- Configuration ---
PROJECT_ROOT_GUESS=$(pwd | sed 's|/data/xml$||')
ABSOLUTE_SAXON_PATH="${PROJECT_ROOT_GUESS}/tools/SaxonHE12-7J/saxon-he-12.7.jar"

cd "$(dirname "$0")"

if [ ! -f "$ABSOLUTE_SAXON_PATH" ]; then
    echo "❌ FATAL ERROR: Saxon JAR not found at '$ABSOLUTE_SAXON_PATH'"
    exit 1
fi
echo "✅ Saxon-HE JAR file found. Using it for all transformations."


# --- 1. Create Combined Source File ---
echo "\n[1/3] Creating temporary combined source file..."
TEMP_SOURCES_XML="all_sources.xml"
MASTER_FILES=("tischendorf_01.xml" "synaxarion_01.xml")
echo '<?xml version="1.0" encoding="UTF-8"?><sources xmlns:xi="http://www.w3.org/2001/XInclude">' > $TEMP_SOURCES_XML
for master_file in $MASTER_FILES; do
    echo "  <xi:include href=\"${master_file}\" />" >> $TEMP_SOURCES_XML
done
echo '</sources>' >> $TEMP_SOURCES_XML
echo "  -> Created temporary file: $TEMP_SOURCES_XML"


# --- 2. Run All Saxon Transformations in a Single Pass ---
echo "\n[2/3] Generating ALL pages and database with Saxon..."

# Clean old directories
rm -rf "../../pages/item" "../../pages/person"
mkdir -p "../../pages/item" "../../pages/person"

# A. Generate ALL item pages (FAST)
java -jar "$ABSOLUTE_SAXON_PATH" -s:"$TEMP_SOURCES_XML" -xsl:"generate_all_items.xsl" -xi
echo "  -> Generated all item pages."

# B. Generate the database.json
java -jar "$ABSOLUTE_SAXON_PATH" -s:"$TEMP_SOURCES_XML" -xsl:"generate_database.xsl" -o:"../../database.json" -xi
echo "  -> Generated database.json"

# C. Generate ALL person pages (FAST)
java -jar "$ABSOLUTE_SAXON_PATH" -s:"$TEMP_SOURCES_XML" -xsl:"generate_persons.xsl" -xi
echo "  -> Generated all person pages."

echo "✅ SUCCESS: All Saxon transformations complete."


# --- 3. Cleanup ---
echo "\n[3/3] Cleaning up temporary files..."
rm $TEMP_SOURCES_XML
echo "--- Build complete! ---"
