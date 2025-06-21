<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" encoding="UTF-8" indent="yes"/>

    <!-- This includes the templates from our item library -->
    <xsl:include href="item_transform.xsl"/>

    <!-- Main template to start the process -->
    <xsl:template match="/">
        <xsl:apply-templates select="//tei:TEI"/>
    </xsl:template>

    <!-- This template matches each source XML file -->
    <xsl:template match="tei:TEI">
        <!-- Loop over every <item> -->
        <xsl:for-each select=".//item">
            <!--
              Create a separate result document for each item.
              THE FIX IS HERE: The href path is restored to your original structure,
              which will save the files in the correct 'pages/item/' directory.
            -->
            <xsl:result-document href="../../pages/item/{@xml:id}.html">
                <!-- Call the main page-creation template from the library -->
                <xsl:call-template name="create-item-page">
                    <xsl:with-param name="item_node" select="."/>
                </xsl:call-template>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
