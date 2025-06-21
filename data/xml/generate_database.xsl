<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:key name="persons-by-key" match="tei:persName" use="@key"/>
    <xsl:key name="families-by-key" match="tei:addName[@type='patronymic' and @key]" use="@key"/>
    <xsl:key name="categories-by-type" match="tei:roleName[@type]" use="substring-before(concat(@type, '_'), '_')"/>
    <xsl:variable name="quote">"</xsl:variable>

    <xsl:template name="escape-json-string">
        <xsl:param name="text"/>
        <xsl:choose>
            <xsl:when test="contains($text, '\')"><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="substring-before($text, '\')"/></xsl:call-template><xsl:text>\\</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="substring-after($text, '\')"/></xsl:call-template></xsl:when>
            <xsl:when test="contains($text, $quote)"><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="substring-before($text, $quote)"/></xsl:call-template><xsl:text>\"</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="substring-after($text, $quote)"/></xsl:call-template></xsl:when>
            <xsl:otherwise><xsl:value-of select="$text"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="translate-role-ka"><xsl:param name="type"/><xsl:choose><xsl:when test="$type = 'clergy'">სასულიერო</xsl:when><xsl:when test="$type = 'noble'">დიდებული</xsl:when><xsl:when test="$type = 'administrative'">მოხელე</xsl:when><xsl:when test="$type = 'royal'">მონარქი</xsl:when><xsl:when test="$type = 'secular'">საერო</xsl:when><xsl:when test="$type = 'martyr'">მოწამე</xsl:when><xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise></xsl:choose></xsl:template>
    <xsl:template name="translate-role-en"><xsl:param name="type"/><xsl:choose><xsl:when test="$type = 'clergy'">Clergy</xsl:when><xsl:when test="$type = 'noble'">Noble</xsl:when><xsl:when test="$type = 'administrative'">Administrative</xsl:when><xsl:when test="$type = 'royal'">Royal</xsl:when><xsl:when test="$type = 'secular'">Secular</xsl:when><xsl:when test="$type = 'martyr'">Martyr</xsl:when><xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise></xsl:choose></xsl:template>

    <xsl:template match="/">
        <!-- CHANGE 1: Add a new variable to sum the values for 'ducat' -->
        <xsl:variable name="totalFlorins" select="sum(//tei:num[following-sibling::tei:term[1]/@key='florin' or ../tei:term[@key='florin']]/@value)"/>
        <xsl:variable name="totalTetri" select="sum(//tei:num[following-sibling::tei:term[1]/@key='tetri' or ../tei:term[@key='tetri']]/@value)"/>
        <xsl:variable name="totalDrama" select="sum(//tei:num[following-sibling::tei:term[1]/@key='drama' or ../tei:term[@key='drama']]/@value)"/>
        <xsl:variable name="totalMarchili" select="sum(//tei:num[following-sibling::tei:term[1]/@key='marchili' or ../tei:term[@key='marchili']]/@value)"/>
        <xsl:variable name="totalDrahkani" select="sum(//tei:num[following-sibling::tei:term[1]/@key='drahkani' or ../tei:term[@key='drahkani']]/@value)"/>
        <xsl:variable name="totalVenetianTetri" select="sum(//tei:num[following-sibling::tei:term[1]/@key='venetian_tetri' or ../tei:term[@key='venetian_tetri']]/@value)"/>
        <xsl:variable name="totalVelentiuriFlorin" select="sum(//tei:num[following-sibling::tei:term[1]/@key='velentiuri_florin' or ../tei:term[@key='velentiuri_florin']]/@value)"/>
        <xsl:variable name="totalMutqaliGold" select="sum(//tei:num[following-sibling::tei:term[1]/@key='mutqali_gold' or ../tei:term[@key='mutqali_gold']]/@value)"/>
        <xsl:variable name="totalDucats" select="sum(//tei:num[following-sibling::tei:term[1]/@key='ducat' or ../tei:term[@key='ducat']]/@value)"/>

        <xsl:variable name="totalPersons" select="count(//tei:persName[@key and generate-id(.) = generate-id(key('persons-by-key', @key)[1])])"/>
        <xsl:variable name="totalFamilies" select="count(//tei:addName[@type='patronymic' and @key and generate-id(.)=generate-id(key('families-by-key', @key)[1])])"/>

        <xsl:text>{"persons": [</xsl:text>
        <xsl:for-each select="//tei:persName[@key and generate-id(.) = generate-id(key('persons-by-key', @key)[1])]"><xsl:variable name="current-group" select="key('persons-by-key', @key)"/><xsl:variable name="authoritative_ref" select="$current-group[@ref and starts-with(@ref, '#auth_pers_')][1]/@ref"/><xsl:variable name="person_id"><xsl:choose><xsl:when test="$authoritative_ref"><xsl:value-of select="substring-after($authoritative_ref, '#auth_pers_')"/></xsl:when><xsl:otherwise><xsl:value-of select="translate(@key, ' ', '_')"/></xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="primaryRole"><xsl:choose><xsl:when test="$current-group[@role='donor']">donor</xsl:when><xsl:when test="$current-group[@role='scribe']">scribe</xsl:when><xsl:otherwise>commemorated</xsl:otherwise></xsl:choose></xsl:variable><xsl:text>{"id": "</xsl:text><xsl:value-of select="$person_id"/><xsl:text>",</xsl:text><xsl:text>"nameKa": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="@key"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"nameEn": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="@key"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"titleKa": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="normalize-space(.)"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"titleEn": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="normalize-space(.)"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"familyKey": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="tei:addName[@type='patronymic']/@key"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"roleKey": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="tei:roleName/@key"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"roleCategory": "</xsl:text><xsl:if test="tei:roleName/@type"><xsl:value-of select="substring-before(concat(tei:roleName/@type, '_'), '_')"/></xsl:if><xsl:text>",</xsl:text><xsl:text>"primaryRole": "</xsl:text><xsl:value-of select="$primaryRole"/><xsl:text>",</xsl:text><xsl:text>"sourcesDisplay": "</xsl:text><xsl:for-each select="$current-group"><xsl:variable name="msIdent" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier"/><xsl:text>[</xsl:text><xsl:value-of select="substring(normalize-space($msIdent/tei:settlement), 1, 3)"/><xsl:text>. </xsl:text><xsl:value-of select="normalize-space($msIdent/tei:idno)"/><xsl:text>, </xsl:text><xsl:value-of select="ancestor::tei:item/@n"/><xsl:text>]</xsl:text><xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if></xsl:for-each><xsl:text>",</xsl:text><xsl:text>"items": [</xsl:text><xsl:for-each select="$current-group"><xsl:text>"</xsl:text><xsl:value-of select="ancestor::tei:item/@xml:id"/><xsl:text>"</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each><xsl:text>]}</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each>
        <xsl:text>], "families": [</xsl:text>
        <xsl:for-each select="//tei:addName[@type='patronymic' and @key and generate-id(.)=generate-id(key('families-by-key', @key)[1])]"><xsl:sort select="@key"/><xsl:text>{"key": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="@key"/></xsl:call-template><xsl:text>", "display": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="@key"/></xsl:call-template><xsl:text>"}</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each>
        <xsl:text>], "roleCategories": [</xsl:text>
        <xsl:for-each select="//tei:roleName[@type and generate-id(.)=generate-id(key('categories-by-type', substring-before(concat(@type, '_'), '_'))[1])]"><xsl:sort select="substring-before(concat(@type, '_'), '_')"/><xsl:variable name="cleanType" select="substring-before(concat(@type, '_'), '_')"/><xsl:text>{"key": "</xsl:text><xsl:value-of select="$cleanType"/><xsl:text>", "displayKa": "</xsl:text><xsl:call-template name="translate-role-ka"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template><xsl:text>", "displayEn": "</xsl:text><xsl:call-template name="translate-role-en"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template><xsl:text>"}</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each>
        <xsl:text>], "sources": [</xsl:text>
        <xsl:for-each select="//tei:item"><xsl:text>{"id": "</xsl:text><xsl:value-of select="@xml:id"/><xsl:text>",</xsl:text><xsl:text>"source": "</xsl:text><xsl:value-of select="ancestor::tei:TEI//tei:msDesc/@xml:id"/><xsl:text>",</xsl:text><xsl:text>"number": "</xsl:text><xsl:value-of select="@n"/><xsl:text>",</xsl:text><xsl:text>"titleKa": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="normalize-space(tei:p)"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"titleEn": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="normalize-space(tei:note[@type='presentation_summary'])"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"textKa": "</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="normalize-space(tei:p)"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"persons": [</xsl:text><xsl:for-each select=".//tei:persName[@key]"><xsl:text>"</xsl:text><xsl:call-template name="escape-json-string"><xsl:with-param name="text" select="@key"/></xsl:call-template><xsl:text>"</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each><xsl:text>]}</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each>

        <xsl:text>], "stats": {</xsl:text>
        <xsl:text>"totalPersons": </xsl:text><xsl:value-of select="$totalPersons"/><xsl:text>,</xsl:text>
        <xsl:text>"totalFamilies": </xsl:text><xsl:value-of select="$totalFamilies"/><xsl:text>,</xsl:text>
        <xsl:text>"roleCounts": [</xsl:text>
        <xsl:for-each select="//tei:roleName[@type and generate-id(.)=generate-id(key('categories-by-type', substring-before(concat(@type, '_'), '_'))[1])]"><xsl:sort select="substring-before(concat(@type, '_'), '_')"/><xsl:variable name="cleanType" select="substring-before(concat(@type, '_'), '_')"/><xsl:text>{"type":"</xsl:text><xsl:value-of select="$cleanType"/><xsl:text>",</xsl:text><xsl:text>"displayKa":"</xsl:text><xsl:call-template name="translate-role-ka"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"displayEn":"</xsl:text><xsl:call-template name="translate-role-en"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template><xsl:text>",</xsl:text><xsl:text>"count":</xsl:text><xsl:value-of select="count(//tei:roleName[starts-with(@type, $cleanType)])"/><xsl:text>}</xsl:text><xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if></xsl:for-each>
        <xsl:text>],</xsl:text>

        <xsl:text>"economicData": [</xsl:text>
        <!-- CHANGE 2: Add a new template call for 'ducat' at the end of the list, updating the `isFirst` logic -->
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="true()"/>
            <xsl:with-param name="total" select="$totalFlorins"/>
            <xsl:with-param name="key" select="'florin'"/>
            <xsl:with-param name="labelKa" select="'ფლური'"/>
            <xsl:with-param name="labelEn" select="'Florin'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0)"/>
            <xsl:with-param name="total" select="$totalTetri"/>
            <xsl:with-param name="key" select="'tetri'"/>
            <xsl:with-param name="labelKa" select="'თეთრი'"/>
            <xsl:with-param name="labelEn" select="'Tetri'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0)"/>
            <xsl:with-param name="total" select="$totalDrama"/>
            <xsl:with-param name="key" select="'drama'"/>
            <xsl:with-param name="labelKa" select="'დრაჰმა'"/>
            <xsl:with-param name="labelEn" select="'Drama'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0)"/>
            <xsl:with-param name="total" select="$totalMarchili"/>
            <xsl:with-param name="key" select="'marchili'"/>
            <xsl:with-param name="labelKa" select="'მარჩილი'"/>
            <xsl:with-param name="labelEn" select="'Marchili'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0 or $totalMarchili > 0)"/>
            <xsl:with-param name="total" select="$totalDrahkani"/>
            <xsl:with-param name="key" select="'drahkani'"/>
            <xsl:with-param name="labelKa" select="'დრაჰკანი'"/>
            <xsl:with-param name="labelEn" select="'Drahkani'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0 or $totalMarchili > 0 or $totalDrahkani > 0)"/>
            <xsl:with-param name="total" select="$totalVenetianTetri"/>
            <xsl:with-param name="key" select="'venetian_tetri'"/>
            <xsl:with-param name="labelKa" select="'ვენეტიკური თეთრი'"/>
            <xsl:with-param name="labelEn" select="'Venetian Tetri'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0 or $totalMarchili > 0 or $totalDrahkani > 0 or $totalVenetianTetri > 0)"/>
            <xsl:with-param name="total" select="$totalVelentiuriFlorin"/>
            <xsl:with-param name="key" select="'velentiuri_florin'"/>
            <xsl:with-param name="labelKa" select="'ველენტიური ფლური'"/>
            <xsl:with-param name="labelEn" select="'Velentiuri Florin'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0 or $totalMarchili > 0 or $totalDrahkani > 0 or $totalVenetianTetri > 0 or $totalVelentiuriFlorin > 0)"/>
            <xsl:with-param name="total" select="$totalMutqaliGold"/>
            <xsl:with-param name="key" select="'mutqali_gold'"/>
            <xsl:with-param name="labelKa" select="'მუტყალი ოქრო'"/>
            <xsl:with-param name="labelEn" select="'Mutqali Gold'"/>
        </xsl:call-template>
        <xsl:call-template name="generate-coin-data">
            <xsl:with-param name="isFirst" select="not($totalFlorins > 0 or $totalTetri > 0 or $totalDrama > 0 or $totalMarchili > 0 or $totalDrahkani > 0 or $totalVenetianTetri > 0 or $totalVelentiuriFlorin > 0 or $totalMutqaliGold > 0)"/>
            <xsl:with-param name="total" select="$totalDucats"/>
            <xsl:with-param name="key" select="'ducat'"/>
            <xsl:with-param name="labelKa" select="'დუკატი'"/>
            <xsl:with-param name="labelEn" select="'Ducat'"/>
        </xsl:call-template>

        <xsl:text>]</xsl:text>
        <xsl:text>}</xsl:text>
        <xsl:text>}</xsl:text>
    </xsl:template>

    <!-- This is a helper template to avoid repeating the comma logic -->
    <xsl:template name="generate-coin-data">
        <xsl:param name="isFirst"/>
        <xsl:param name="total"/>
        <xsl:param name="key"/>
        <xsl:param name="labelKa"/>
        <xsl:param name="labelEn"/>

        <xsl:if test="$total > 0">
            <xsl:if test="not($isFirst = 'true')">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>{"key":"</xsl:text><xsl:value-of select="$key"/><xsl:text>", "labelKa":"</xsl:text><xsl:value-of select="$labelKa"/><xsl:text>", "labelEn":"</xsl:text><xsl:value-of select="$labelEn"/><xsl:text>", "total":</xsl:text><xsl:value-of select="$total"/><xsl:text>}</xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
