<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <!-- This is a library file. It correctly has no <xsl:output> declaration. -->

    <!-- =============================================================== -->
    <!-- 1. MAIN TEMPLATE TO BUILD THE HTML PAGE -->
    <!-- =============================================================== -->
    <xsl:template name="create-item-page">
        <xsl:param name="item_node"/>
        <html lang="ka">
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>იერუსალიმის ჯვრის მონასტრის აღაპები - <xsl:value-of select="$item_node/@xml:id"/></title>
                <link rel="stylesheet" href="../../style.css"/>
            </head>
            <body class="lang-ka-active">
                <div class="container">
                    <header class="header">
                        <div class="header-top-controls">
                            <a href="../../index.html" class="back-link"><span class="lang-ka">← მთავარი</span><span class="lang-en">← Main</span></a>
                            <div class="lang-toggle">
                                <button id="btn-ka" class="active" onclick="switchLang('ka')">ქართული</button>
                                <button id="btn-en" onclick="switchLang('en')">English</button>
                            </div>
                        </div>
                        <div class="header-content">
                            <h1 class="georgian-main">იერუსალიმის ჯვრის მონასტრის აღაპები</h1>
                            <div class="subtitle">Jerusalem Cross Monastery Commemorative Records</div>
                            <div class="item-navigation"><xsl:call-template name="item-navigation-links"><xsl:with-param name="currentItemNode" select="$item_node"/></xsl:call-template></div>
                        </div>
                    </header>
                    <div class="scholarly-viewer">
                        <div class="manuscript-panel">
                             <xsl:apply-templates select="$item_node/ancestor::TEI//msDesc" mode="sidebar"/>
                             <xsl:call-template name="key-figures-sidebar"><xsl:with-param name="contextNode" select="$item_node"/></xsl:call-template>
                             <xsl:call-template name="donations-sidebar"><xsl:with-param name="contextNode" select="$item_node"/></xsl:call-template>
                        </div>
                        <div class="text-apparatus-container">
                            <div class="text-panel">
                                <div class="panel-header">
                                    <div class="panel-title-text"><span class="lang-ka">ტექსტი</span><span class="lang-en">Transcription</span></div>
                                    <div class="view-mode-switch">
                                        <label><input type="radio" name="view-mode" value="critical" checked="true" onchange="switchTextView('critical')"/> Critical</label>
                                        <label><input type="radio" name="view-mode" value="diplomatic" onchange="switchTextView('diplomatic')"/> Diplomatic</label>
                                    </div>
                                </div>
                                <div class="transcription-viewer">
                                    <div id="critical-view" class="transcription-text"><xsl:apply-templates select="$item_node/p"/></div>
                                    <div id="diplomatic-view" class="transcription-text" style="display:none;"><xsl:apply-templates select="$item_node/p" mode="diplomatic"/></div>
                                </div>
                            </div>
                            <div class="apparatus-panel">
                                <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">შენიშვნები</span><span class="lang-en">Notes</span></div></div>
                                <div class="apparatus-viewer"><xsl:apply-templates select="$item_node/note[@type!='presentation_summary']" mode="sidebar"/></div>
                            </div>
                        </div>
                    </div>
                </div>
                <script>
                    function switchLang(lang) { document.body.className = lang + '-active'; document.getElementById('btn-ka').classList.toggle('active', lang === 'ka'); document.getElementById('btn-en').classList.toggle('active', lang === 'en'); }
                    function switchTextView(view) { document.getElementById('critical-view').style.display = 'none'; document.getElementById('diplomatic-view').style.display = 'none'; document.getElementById(view + '-view').style.display = 'block'; }
                    document.addEventListener('DOMContentLoaded', function() { switchLang('ka'); switchTextView('critical'); });
                </script>
            </body>
        </html>
    </xsl:template>

    <!-- =============================================================== -->
    <!-- 2. SIDEBAR AND UTILITY TEMPLATES -->
    <!-- =============================================================== -->
    <xsl:template name="item-navigation-links"><xsl:param name="currentItemNode"/><div class="nav-prev"><xsl:if test="$currentItemNode/preceding-sibling::item[1]"><a href="{$currentItemNode/preceding-sibling::item[1]/@xml:id}.html"><span class="lang-ka">← წინა</span><span class="lang-en">← Previous</span></a></xsl:if></div><div class="nav-current-item"><span class="lang-ka">ჩანაწერი <xsl:value-of select="$currentItemNode/@n"/></span><span class="lang-en">Item <xsl:value-of select="$currentItemNode/@n"/></span></div><div class="nav-next"><xsl:if test="$currentItemNode/following-sibling::item[1]"><a href="{$currentItemNode/following-sibling::item[1]/@xml:id}.html"><span class="lang-ka">შემდეგი →</span><span class="lang-en">Next →</span></a></xsl:if></div></xsl:template>
    <xsl:template name="key-figures-sidebar"><xsl:param name="contextNode"/><div class="sidebar-section"><div class="panel-header"><div class="panel-title-text"><span class="lang-ka">მთავარი პირები</span><span class="lang-en">Key Figures</span></div></div><xsl:apply-templates select="$contextNode//persName[@key]" mode="sidebar"/></div></xsl:template>
    <xsl:template name="donations-sidebar"><xsl:param name="contextNode"/><xsl:if test="$contextNode//seg[contains(@type, 'donation')]"><div class="sidebar-section"><div class="panel-header"><div class="panel-title-text"><span class="lang-ka">შემოწირულობები</span><span class="lang-en">Donations</span></div></div><xsl:for-each select="$contextNode//seg[contains(@type, 'donation')]"><div class="metadata-item"><p><xsl:value-of select="normalize-space(.)"/></p></div></xsl:for-each></div></xsl:if></xsl:template>
    <xsl:template match="persName" mode="sidebar"><a href="../person/{substring-after(@ref, '#auth_pers_')}.html" class="person-link"><div class="person-name-georgian"><xsl:value-of select="@key"/> ↛</div><div class="person-role"><xsl:value-of select="@role"/></div></a></xsl:template>
    <xsl:template match="msDesc" mode="sidebar"><div class="sidebar-section"><div class="panel-header"><div class="panel-title-text"><span class="lang-ka">ხელნაწერი</span><span class="lang-en">Manuscript</span></div></div><div class="metadata-item"><span class="metadata-label">ID:</span><span class="metadata-value"><xsl:value-of select=".//idno"/></span></div><div class="metadata-item"><span class="metadata-label">Repo:</span><span class="metadata-value"><xsl:value-of select=".//repository"/></span></div></div></xsl:template>
    <xsl:template match="note" mode="sidebar"><div class="apparatus-note"><span class="note-type"><xsl:value-of select="translate(@type, '_', ' ')"/>:</span> <span class="note-content"><xsl:value-of select="."/></span></div></xsl:template>

    <!--
    ================================================================================
    3. MAIN TEXT RENDERING LOGIC
    ================================================================================
    -->

    <!-- TEMPLATE FOR <p> IN CRITICAL (DEFAULT) MODE -->
    <xsl:template match="p">
        <div class="line">
            <div class="line-number"><xsl:value-of select="preceding-sibling::lb[1]/@n"/></div>
            <div class="line-content"><xsl:apply-templates select="node()[not(self::lb) and count(preceding-sibling::lb) = 0]"/></div>
        </div>
        <xsl:for-each select="lb">
            <div class="line">
                <div class="line-number"><xsl:value-of select="@n"/></div>
                <div class="line-content"><xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::lb) = count(current()/preceding-sibling::lb) + 1]"/></div>
            </div>
        </xsl:for-each>
    </xsl:template>

    <!-- TEMPLATE FOR <p> IN DIPLOMATIC MODE -->
    <!-- This template correctly passes the 'diplomatic' mode to its children. -->
    <xsl:template match="p" mode="diplomatic">
        <div class="line">
            <div class="line-number"><xsl:value-of select="preceding-sibling::lb[1]/@n"/></div>
            <div class="line-content"><xsl:apply-templates select="node()[not(self::lb) and count(preceding-sibling::lb) = 0]" mode="diplomatic"/></div>
        </div>
        <xsl:for-each select="lb">
            <div class="line">
                <div class="line-number"><xsl:value-of select="@n"/></div>
                <div class="line-content"><xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::lb) = count(current()/preceding-sibling::lb) + 1]" mode="diplomatic"/></div>
            </div>
        </xsl:for-each>
    </xsl:template>

    <!-- CRITICAL MODE TEMPLATES FOR INDIVIDUAL TAGS -->
    <xsl:template match="text()"><xsl:value-of select="."/></xsl:template>
    <xsl:template match="persName"><a class="person-link-inline" href="../person/{substring-after(@ref, '#auth_pers_')}.html"><xsl:apply-templates/></a></xsl:template>
    <xsl:template match="date | term | orgName | placeName"><em><xsl:apply-templates/></em></xsl:template>
    <xsl:template match="seg[@type]"><span class="seg-inline"><xsl:apply-templates/><span class="seg-type-label"><xsl:value-of select="translate(@type, '_', ' ')"/></span></span></xsl:template>
    <xsl:template match="expan"><xsl:apply-templates/></xsl:template>
    <xsl:template match="ex"><span class="abbr-expansion">(<xsl:apply-templates/>)</span></xsl:template>
    <xsl:template match="supplied"><span class="supplied-text">[<xsl:apply-templates/>]</span></xsl:template>
    <xsl:template match="add">⟨<xsl:apply-templates/>⟩</xsl:template>
    <xsl:template match="del"><del><xsl:apply-templates/></del></xsl:template>
    <xsl:template match="unclear"><span class="tei-unclear"><xsl:apply-templates/></span></xsl:template>
    <xsl:template match="gap">[---]</xsl:template>
    <xsl:template match="app"><span class="app-wrapper"><xsl:apply-templates select="lem"/><span class="tooltip"><sup class="tooltip-marker">✧</sup><span class="tooltip-content"><xsl:apply-templates select="rdg"/></span></span></span></xsl:template>
    <xsl:template match="lem"><xsl:apply-templates/></xsl:template>
    <xsl:template match="rdg"><span class="reading"><xsl:if test="@wit"><span class="witness"><xsl:value-of select="@wit"/>: </span></xsl:if><xsl:apply-templates/></span></xsl:template>

    <!-- DIPLOMATIC MODE TEMPLATES FOR INDIVIDUAL TAGS -->
    <xsl:template match="text()" mode="diplomatic">
        <xsl:variable name="mkhedruli" select="'აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵ'"/>
        <xsl:variable name="nuskhuri"  select="'ⴀⴁⴂⴃⴄⴅⴆⴡⴇⴈⴉⴊⴋⴌⴢⴍⴎⴏⴐⴑⴒⴣⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴤⴟⴠⴥ'"/>
        <xsl:value-of select="translate(., $mkhedruli, $nuskhuri)"/>
    </xsl:template>
    <xsl:template match="persName | date | term | orgName | placeName | seg" mode="diplomatic"><xsl:apply-templates mode="diplomatic"/></xsl:template>
    <xsl:template match="expan" mode="diplomatic"><xsl:apply-templates select="text()" mode="diplomatic"/></xsl:template>
    <xsl:template match="ex|supplied|add|del|unclear|app|lem|rdg" mode="diplomatic"/>

</xsl:stylesheet>
