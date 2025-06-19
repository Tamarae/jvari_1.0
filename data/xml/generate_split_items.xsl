<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

    <!-- Main template: process all items in the input document -->
    <xsl:template match="/tei:TEI">
        <!-- Loop over every <item> in the file -->
        <xsl:for-each select=".//tei:item">
            <!--
                For each item, create a separate result document.
                The filename is based on the item's xml:id.
            -->
            <xsl:result-document href="../../pages/item/{@xml:id}.html">
                <html>
                    <head>
                        <title>Jvari 2.0 - <xsl:value-of select="@xml:id"/></title>
                        <link rel="stylesheet" type="text/css" href="../../style.css"/>
                        <meta charset="UTF-8"/>
                    </head>
                    <body>
                        <div class="container">
                            <div class="left-panel">
                                <!--
                                    Find the msDesc from this item's parent TEI file.
                                    This makes the link dynamic.
                                -->
                                <xsl:apply-templates select="ancestor::tei:TEI//tei:msDesc"/>
                            </div>
                            <div class="right-panel">
                                <!-- Process the current item itself for the right panel -->
                                <xsl:apply-templates select="." mode="item-view"/>
                            </div>
                        </div>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <!-- Template to display the item content in the right panel -->
    <xsl:template match="tei:item" mode="item-view">
        <div class="item-transcription">
            <h1>Item: <xsl:value-of select="@xml:id"/></h1>
            <xsl:apply-templates select="tei:p"/>
        </div>
        <div class="item-notes">
            <h3>Notes</h3>
            <xsl:apply-templates select="tei:note"/>
        </div>
    </xsl:template>

    <!-- Template for styling <p> tags -->
    <xsl:template match="tei:p">
      <p><xsl:apply-templates/></p>
    </xsl:template>

    <!-- Template for styling <note> tags -->
    <xsl:template match="tei:note">
      <div class="note">
        <strong><xsl:value-of select="@type"/>:</strong>
        <xsl:apply-templates/>
      </div>
    </xsl:template>

    <!-- Templates to render the <msDesc> block -->
    <xsl:template match="tei:msDesc">
        <div class="manuscript-details">
            <h2>Manuscript Details</h2>
            <h3><xsl:value-of select="tei:msIdentifier/tei:idno"/></h3>
            <p><strong><xsl:value-of select="ancestor::tei:TEI//tei:div/tei:head"/></strong></p>
            <p>
                <xsl:value-of select="tei:msIdentifier/tei:repository"/>,
                <xsl:value-of select="tei:msIdentifier/tei:settlement"/>
            </p>
            <p><xsl:value-of select="tei:msContents/tei:summary"/></p>
        </div>
    </xsl:template>

    <!-- Template to create links for people -->
    <xsl:template match="tei:persName[@ref]">
        <a class="person-link" href="../../persons.html#{@ref}"><xsl:apply-templates/></a>
    </xsl:template>

    <!-- Generic catch-all for other elements inside a paragraph -->
    <xsl:template match="tei:p//*">
        <xsl:apply-templates/>
    </xsl:template>

</xsl:stylesheet>
