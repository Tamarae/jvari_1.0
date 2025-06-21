<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    exclude-result-prefixes="tei fn">

    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

    <xsl:key name="persons-by-unified-id" match="tei:persName"
        use="if (starts-with(@ref, '#auth_pers_')) then substring-after(@ref, '#auth_pers_') else replace(replace(@xml:id, '^pers_', ''), '_jer.*$', '')"/>

    <xsl:template match="/">
        <xsl:message>Generating simpler person pages with unified ID logic...</xsl:message>

        <xsl:for-each-group select="//tei:persName[@xml:id or starts-with(@ref, '#auth_pers_')]"
            group-by="if (starts-with(@ref, '#auth_pers_')) then substring-after(@ref, '#auth_pers_') else replace(replace(@xml:id, '^pers_', ''), '_jer.*$', '')">

            <xsl:variable name="unified_id" select="current-grouping-key()"/>

            <xsl:if test="$unified_id != ''">
                <xsl:result-document href="../../pages/person/{$unified_id}.html">

                    <xsl:variable name="all_mentions" select="current-group()"/>
                    <xsl:variable name="first_mention" select="$all_mentions[1]"/>
                    <xsl:variable name="person_name" select="$first_mention/@key"/>

                    <html lang="ka">
                        <head>
                            <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
                            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                            <title><xsl:value-of select="$person_name"/></title>
                            <link rel="stylesheet" href="../../style.css"/>
                        </head>
                        <body class="lang-ka-active">
                             <div class="header">
                                <a href="../../index.html" class="back-link">
                                    <span class="lang-ka georgian-main">← უკან</span><span class="lang-en">← Back</span>
                                </a>
                                <div class="language-switch">
                                    <button class="lang-btn active" data-lang="ka" onclick="switchLang('ka')">ქართული</button>
                                    <button class="lang-btn" data-lang="en" onclick="switchLang('en')">English</button>
                                </div>
                                <div class="header-content">
                                    <div class="person-header">
                                        <h1 class="lang-ka georgian-main"><xsl:value-of select="$person_name"/></h1>
                                        <h1 class="lang-en"><xsl:value-of select="$person_name"/></h1>
                                        <div class="person-title">
                                            <span class="lang-ka georgian-main"><xsl:value-of select="$first_mention/tei:roleName"/></span>
                                            <span class="lang-en"><xsl:value-of select="$first_mention/tei:roleName/@key"/></span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <div class="container">
                                <div class="person-content">
                                    <div class="main-content">
                                        <div class="section-title">
                                            <span class="lang-ka georgian-main">ხსენება ხელნაწერში</span>
                                            <span class="lang-en">Mention in Manuscript</span>
                                        </div>
                                        <div class="manuscript-quote">
                                            <p class="georgian-text"><xsl:value-of select="normalize-space($first_mention/ancestor::tei:p)"/></p>
                                            <div class="manuscript-reference">Item <xsl:value-of select="$first_mention/ancestor::tei:item/@n"/></div>
                                        </div>
                                    </div>
                                    <div class="sidebar">
                                        <div class="info-section">
                                            <div class="section-title">
                                                <span class="lang-ka georgian-main">დაკავშირებული წყაროები</span>
                                                <span class="lang-en">Related Sources</span>
                                            </div>
                                            <ul class="related-sources">
                                                <xsl:for-each select="$all_mentions[generate-id(.) = generate-id(ancestor::tei:item[1])]">
                                                    <xsl:variable name="item" select="ancestor::tei:item[1]"/>
                                                     <li><a href="../item/{$item/@xml:id}.html">
                                                        <span class="source-number"><xsl:value-of select="$item/@n"/></span>
                                                        <span class="lang-ka georgian-main"><xsl:value-of select="substring($item/tei:p, 1, 40)"/>...</span>
                                                        <span class="lang-en"><xsl:value-of select="$item/tei:note[@type='presentation_summary']"/></span>
                                                    </a></li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <script>
                                function switchLang(lang) {
                                    document.body.classList.toggle('lang-ka-active', lang === 'ka');
                                    document.body.classList.toggle('lang-en-active', lang !== 'ka');
                                    document.querySelectorAll('.language-switch .lang-btn').forEach(b => b.classList.remove('active'));
                                    document.querySelector(`.language-switch .lang-btn[data-lang='${lang}']`).classList.add('active');
                                }
                                document.addEventListener('DOMContentLoaded', () => switchLang('ka'));
                            </script>
                        </body>
                    </html>
                </xsl:result-document>
            </xsl:if>
        </xsl:for-each-group>
    </xsl:template>

</xsl:stylesheet>
