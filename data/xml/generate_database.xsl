<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:key name="persons-by-key" match="tei:persName" use="@key"/>
    <xsl:key name="families-by-key" match="tei:addName[@type='patronymic' and @key]" use="@key"/>
    <xsl:key name="categories-by-type" match="tei:roleName[@type]" use="substring-before(concat(@type, '_'), '_')"/>

    <!-- ===== START: NEW STAT VARIABLES ===== -->
    <xsl:variable name="totalPersons" select="count(//tei:persName[@key and generate-id(.) = generate-id(key('persons-by-key', @key)[1])])"/>
    <xsl:variable name="totalFamilies" select="count(//tei:addName[@type='patronymic' and @key and generate-id(.)=generate-id(key('families-by-key', @key)[1])])"/>
    <!-- ===== END: NEW STAT VARIABLES ===== -->

    <!-- Add these new named templates anywhere outside the main template -->
    <xsl:template name="translate-role-ka">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'clergy'">სასულიერო</xsl:when>
            <xsl:when test="$type = 'noble'">დიდებული</xsl:when>
            <xsl:when test="$type = 'administrative'">მოხელე</xsl:when>
            <xsl:when test="$type = 'royal'">მონარქი</xsl:when>
            <xsl:when test="$type = 'secular'">საერო</xsl:when>
            <xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="translate-role-en">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'clergy'">Clergy</xsl:when>
            <xsl:when test="$type = 'noble'">Noble</xsl:when>
            <xsl:when test="$type = 'administrative'">Administrative</xsl:when>
            <xsl:when test="$type = 'royal'">Royal</xsl:when>
            <xsl:when test="$type = 'secular'">Secular</xsl:when>
            <xsl:otherwise><xsl:value-of select="$type"/></xsl:otherwise>
        </xsl:choose>
    </xsl:template>





    <xsl:template match="/">
        <xsl:variable name="all-items" select="//tei:item"/>
        <xsl:variable name="totalFlorins" select="sum(//tei:num[following-sibling::tei:term[1][@type='coin' and @key='florin']]/@value)"/>
        <xsl:variable name="totalTetri" select="sum(//tei:num[following-sibling::tei:term[1][@type='coin' and @key='tetri']]/@value)"/>

        <xsl:text>{"persons": [</xsl:text>
        <xsl:for-each select="$all-items//tei:persName[@key and generate-id(.) = generate-id(key('persons-by-key', @key)[1])]">
            <xsl:variable name="current-group" select="key('persons-by-key', @key)"/>

            <!-- ======================= NEW ROBUST LOGIC ======================= -->
            <!-- 1. Look through the entire group for a valid ref attribute. -->
            <xsl:variable name="authoritative_ref"
                          select="$current-group[@ref and starts-with(@ref, '#auth_pers_')][1]/@ref"/>

            <!-- 2. Use that ref to create the ID. Fall back ONLY if no valid ref is found anywhere. -->
            <xsl:variable name="person_id">
              <xsl:choose>
                <xsl:when test="$authoritative_ref">
                  <xsl:value-of select="substring-after($authoritative_ref, '#auth_pers_')"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="translate(@key, ' ', '_')"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <!-- ===================== END OF NEW LOGIC ====================== -->

            <xsl:variable name="primaryRole">
              <xsl:choose>
                <xsl:when test="$current-group[@role='donor']">donor</xsl:when>
                <xsl:when test="$current-group[@role='scribe']">scribe</xsl:when>
                <xsl:otherwise>commemorated</xsl:otherwise>
              </xsl:choose>
            </xsl:variable>

            <xsl:text>
            {</xsl:text>
                <xsl:text>"id": "</xsl:text><xsl:value-of select="$person_id"/><xsl:text>",</xsl:text>
                <xsl:text>"nameKa": "</xsl:text><xsl:value-of select="@key"/><xsl:text>",</xsl:text>
                <xsl:text>"nameEn": "</xsl:text><xsl:value-of select="@key"/><xsl:text>",</xsl:text>
                <xsl:text>"titleKa": "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>",</xsl:text>
                <xsl:text>"titleEn": "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>",</xsl:text>
                <xsl:text>"familyKey": "</xsl:text><xsl:value-of select="tei:addName[@type='patronymic']/@key"/><xsl:text>",</xsl:text>
                <xsl:text>"roleKey": "</xsl:text><xsl:value-of select="tei:roleName/@key"/><xsl:text>",</xsl:text>
                <xsl:text>"roleCategory": "</xsl:text>
                <xsl:if test="tei:roleName/@type">
                    <xsl:value-of select="substring-before(concat(tei:roleName/@type, '_'), '_')"/>
                </xsl:if>
                <xsl:text>",</xsl:text>
                <xsl:text>"primaryRole": "</xsl:text><xsl:value-of select="$primaryRole"/><xsl:text>",</xsl:text>
                <xsl:text>"sourcesDisplay": "</xsl:text>
                <xsl:for-each select="$current-group">
                    <xsl:variable name="msIdent" select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier"/>
                    <xsl:text>[</xsl:text>
                    <xsl:value-of select="substring(normalize-space($msIdent/tei:settlement), 1, 3)"/>
                    <xsl:text>. </xsl:text>
                    <xsl:value-of select="normalize-space($msIdent/tei:idno)"/>
                    <xsl:text>, </xsl:text>
                    <xsl:value-of select="ancestor::tei:item/@n"/>
                    <xsl:text>]</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>, </xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>",</xsl:text>
                <xsl:text>"items": [</xsl:text>
                <xsl:for-each select="$current-group">
                    <xsl:text>"item-</xsl:text><xsl:value-of select="ancestor::tei:item/@n"/><xsl:text>"</xsl:text>
                    <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
                </xsl:for-each>
                <xsl:text>]
            }</xsl:text>
            <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>

        <xsl:text>], "families": [</xsl:text>
        <xsl:for-each select="//tei:addName[@type='patronymic' and @key and generate-id(.)=generate-id(key('families-by-key', @key)[1])]">
            <xsl:sort select="@key"/>
            <xsl:text>{"key": "</xsl:text><xsl:value-of select="@key"/><xsl:text>", "display": "</xsl:text><xsl:value-of select="@key"/><xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>

        <xsl:text>], "roleCategories": [</xsl:text>
        <xsl:for-each select="//tei:roleName[@type and generate-id(.)=generate-id(key('categories-by-type', substring-before(concat(@type, '_'), '_'))[1])]">
             <xsl:sort select="substring-before(concat(@type, '_'), '_')"/>
             <xsl:variable name="cleanType" select="substring-before(concat(@type, '_'), '_')"/>
             <xsl:text>{"key": "</xsl:text><xsl:value-of select="$cleanType"/><xsl:text>", "displayKa": "</xsl:text>
             <xsl:choose>
                <xsl:when test="$cleanType = 'clergy'">სასულიერო</xsl:when>
                <xsl:when test="$cleanType = 'noble'">დიდებული</xsl:when>
                <xsl:when test="$cleanType = 'administrative'">მოხელე</xsl:when>
                <xsl:when test="$cleanType = 'royal'">მონარქი</xsl:when>
                <xsl:when test="$cleanType = 'secular'">საერო</xsl:when>
                <xsl:otherwise><xsl:value-of select="$cleanType"/></xsl:otherwise>
             </xsl:choose>
             <xsl:text>", "displayEn": "</xsl:text>
             <xsl:choose>
                <xsl:when test="$cleanType = 'clergy'">Clergy</xsl:when>
                <xsl:when test="$cleanType = 'noble'">Noble</xsl:when>
                <xsl:when test="$cleanType = 'administrative'">Administrative</xsl:when>
                <xsl:when test="$cleanType = 'royal'">Royal</xsl:when>
                <xsl:when test="$cleanType = 'secular'">Secular</xsl:when>
                <xsl:otherwise><xsl:value-of select="$cleanType"/></xsl:otherwise>
             </xsl:choose>
             <xsl:text>"}</xsl:text>
            <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>

        <xsl:text>], "sources": [</xsl:text>
        <xsl:for-each select="//tei:item">
             <xsl:text>{"id": "item-</xsl:text><xsl:value-of select="@n"/><xsl:text>",</xsl:text>
            <xsl:text>"source": "</xsl:text><xsl:value-of select="ancestor::tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id"/><xsl:text>",</xsl:text>
            <xsl:text>"number": "Jer. 24, </xsl:text><xsl:value-of select="@n"/><xsl:text>",</xsl:text>
            <xsl:text>"titleKa": "</xsl:text><xsl:value-of select="normalize-space(tei:p)"/><xsl:text>",</xsl:text>
            <xsl:text>"titleEn": "</xsl:text><xsl:value-of select="normalize-space(tei:note[@type='presentation_summary'])"/><xsl:text>",</xsl:text>
            <xsl:text>"textKa": "</xsl:text><xsl:value-of select="normalize-space(tei:p)"/><xsl:text>",</xsl:text>
            <xsl:text>"persons": [</xsl:text>
            <xsl:for-each select=".//tei:persName[@key]">
                <xsl:text>"</xsl:text><xsl:value-of select="@key"/><xsl:text>"</xsl:text>
                <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
            </xsl:for-each>
            <xsl:text>]}</xsl:text>
            <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>

        <!-- Comma after the sources array -->
        <xsl:text>],</xsl:text>

        <!-- ============================================== -->
        <!-- ===== START: CORRECTED STATS OBJECT ===== -->
        <!-- ============================================== -->
        <xsl:text>"stats": {</xsl:text>

        <xsl:text>"totalFlorins": </xsl:text><xsl:value-of select="$totalFlorins"/><xsl:text>,</xsl:text>
        <xsl:text>"totalTetri": </xsl:text><xsl:value-of select="$totalTetri"/><xsl:text>,</xsl:text>
        <xsl:text>"totalPersons": </xsl:text><xsl:value-of select="$totalPersons"/><xsl:text>,</xsl:text>
        <xsl:text>"totalFamilies": </xsl:text><xsl:value-of select="$totalFamilies"/><xsl:text>,</xsl:text>

        <xsl:text>"roleCounts": [</xsl:text>

        <xsl:for-each select="//tei:roleName[@type and generate-id(.)=generate-id(key('categories-by-type', substring-before(concat(@type, '_'), '_'))[1])]">
             <xsl:sort select="substring-before(concat(@type, '_'), '_')"/>
             <xsl:variable name="cleanType" select="substring-before(concat(@type, '_'), '_')"/>

             <xsl:text>{"type":"</xsl:text><xsl:value-of select="$cleanType"/><xsl:text>",</xsl:text>
             <xsl:text>"displayKa":"</xsl:text>
             <xsl:call-template name="translate-role-ka"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template>
             <xsl:text>",</xsl:text>
             <xsl:text>"displayEn":"</xsl:text>
             <xsl:call-template name="translate-role-en"><xsl:with-param name="type" select="$cleanType"/></xsl:call-template>
             <xsl:text>",</xsl:text>
             <xsl:text>"count":</xsl:text><xsl:value-of select="count(//tei:roleName[starts-with(@type, $cleanType)])"/>
             <xsl:text>}</xsl:text>

             <!-- This comma logic is correct for an array -->
             <xsl:if test="position() != last()"><xsl:text>,</xsl:text></xsl:if>
        </xsl:for-each>

        <!-- Close the roleCounts array. NO COMMA HERE, as it's the last item in the stats object. -->
        <xsl:text>]</xsl:text>

        <!-- Close the stats object -->
        <xsl:text>}</xsl:text>
        <!-- ============================================ -->
        <!-- ===== END: CORRECTED STATS OBJECT ===== -->
        <!-- ============================================ -->

        <!-- Final closing brace for the whole JSON file -->
        <xsl:text>}</xsl:text>
    </xsl:template>
</xsl:stylesheet>
