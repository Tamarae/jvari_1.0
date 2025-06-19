<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

    <xsl:param name="item_id"/>

    <xsl:key name="line-content" match="tei:p/node()[not(self::tei:lb)]" use="generate-id(preceding-sibling::tei:lb[1])"/>

    <!-- MAIN TEMPLATE -->
    <xsl:template match="/">
        <xsl:variable name="currentItem" select="//tei:item[@xml:id = $item_id]"/>
        <xsl:if test="not($currentItem)">
            <xsl:message terminate="yes">ERROR: Item with xml:id '<xsl:value-of select="$item_id"/>' not found in input file.</xsl:message>
        </xsl:if>
        <html lang="ka">
            <head>
                <meta charset="UTF-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>იერუსალიმის ჯვრის მონასტრის აღაპები - <xsl:value-of select="$item_id"/></title>
                <link rel="stylesheet" href="../../style.css"/>
                <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
            </head>
            <body class="lang-ka-active">
                <div class="container">
                    <header class="header">
                        <a href="../../index.html#prosopography" class="back-link">
                            <span class="lang-ka georgian-main">← უკან</span>
                            <span class="lang-en">← Back to Database</span>
                        </a>
                        <div class="header-top-controls">
                            <div class="lang-toggle">
                                <button id="btn-ka" class="active" onclick="switchLang('ka')">ქართული</button>
                                <button id="btn-en" onclick="switchLang('en')">English</button>
                            </div>
                        </div>
                        <div class="header-content">
                            <h1 class="georgian-main">იერუსალიმის ჯვრის მონასტრის აღაპები</h1>
                            <div class="subtitle">Jerusalem Cross Monastery Commemorative Records</div>
                            <div class="subtitle">XI–XVII Centuries</div>
                            <div class="meta">Based on Leipzig MS V-1085 and Jerusalem MSS 24-25</div>
                            <xsl:call-template name="item-navigation">
                                <xsl:with-param name="currentItemNode" select="$currentItem"/>
                            </xsl:call-template>
                        </div>
                    </header>
                    <div class="scholarly-viewer">
                        <div class="manuscript-panel">
                            <xsl:call-template name="manuscript-details">
                                <xsl:with-param name="contextNode" select="$currentItem"/>
                            </xsl:call-template>
                            <xsl:call-template name="key-figures-sidebar">
                                <xsl:with-param name="contextNode" select="$currentItem"/>
                            </xsl:call-template>
                            <xsl:call-template name="donations-sidebar">
                                <xsl:with-param name="contextNode" select="$currentItem"/>
                            </xsl:call-template>
                        </div>
                        <div class="text-apparatus-container">
                            <div class="text-panel">
                                <div class="panel-header">
                                    <div class="panel-title-text"><span class="lang-ka">ტექსტი</span><span class="lang-en">Transcription</span></div>
                                    <div class="view-mode-switch">
                                        <label><input type="radio" name="view-mode" value="critical" checked="checked" onchange="switchTextView('critical')"/> Critical</label>
                                        <label><input type="radio" name="view-mode" value="diplomatic" onchange="switchTextView('diplomatic')"/> Diplomatic</label>
                                    </div>
                                </div>
                                <div class="transcription-viewer">
                                    <div id="critical-view" class="transcription-text">
                                        <xsl:apply-templates select="$currentItem/tei:p"/>
                                    </div>
                                    <div id="diplomatic-view" class="transcription-text" style="display:none;">
                                        <xsl:apply-templates select="$currentItem/tei:p" mode="diplomatic"/>
                                    </div>
                                </div>
                            </div>
                            <div class="apparatus-panel">
                                <div class="panel-header">
                                    <div class="panel-title-text"><span class="lang-ka">სამეცნიერო აპარატი და შენიშვნები</span><span class="lang-en">Scholarly Apparatus and Notes</span></div>
                                </div>
                                <div class="apparatus-viewer">
                                    <xsl:for-each select="$currentItem/tei:note[not(@type='presentation_summary')]">
                                        <div class="apparatus-note">
                                            <span class="note-type">
                                                <xsl:variable name="type" select="@type"/>
                                                <span class="lang-ka"><xsl:call-template name="translate-note-type-ka"><xsl:with-param name="type" select="$type"/></xsl:call-template></span>
                                                <span class="lang-en"><xsl:value-of select="translate($type, '_', ' ')"/>:</span>
                                            </span>
                                            <span class="note-content"><xsl:value-of select="normalize-space(.)"/></span>
                                        </div>
                                    </xsl:for-each>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <script>
                    function switchLang(lang) {
                        const body = document.body;
                        body.classList.toggle('lang-ka-active', lang === 'ka');
                        body.classList.toggle('lang-en-active', lang === 'en');
                        document.getElementById('btn-ka').classList.toggle('active', lang === 'ka');
                        document.getElementById('btn-en').classList.toggle('active', lang === 'en');
                    }
                    function switchTextView(view) {
                        document.getElementById('critical-view').style.display = 'none';
                        document.getElementById('diplomatic-view').style.display = 'none';
                        document.getElementById(view + '-view').style.display = 'block';
                    }
                    document.addEventListener('DOMContentLoaded', function() { switchLang('ka'); switchTextView('critical'); });
                </script>
            </body>
        </html>
    </xsl:template>

    <xsl:template name="item-navigation">
        <xsl:param name="currentItemNode"/>
        <xsl:variable name="prevItem" select="$currentItemNode/preceding-sibling::tei:item[1]"/>
        <xsl:variable name="nextItem" select="$currentItemNode/following-sibling::tei:item[1]"/>
        <div class="item-navigation">
            <div class="nav-prev"><xsl:if test="$prevItem"><a href="{$prevItem/@xml:id}.html"><span class="lang-ka">← წინა</span><span class="lang-en">← Previous</span></a></xsl:if></div>
            <div class="nav-current-item"><span class="lang-ka">ჩანაწერი <xsl:value-of select="$currentItemNode/@n"/></span><span class="lang-en">Item <xsl:value-of select="$currentItemNode/@n"/></span></div>
            <div class="nav-next"><xsl:if test="$nextItem"><a href="{$nextItem/@xml:id}.html"><span class="lang-ka">შემდეგი →</span><span class="lang-en">Next →</span></a></xsl:if></div>
        </div>
    </xsl:template>

    <xsl:template name="key-figures-sidebar">
        <xsl:param name="contextNode"/>
        <div class="sidebar-section">
            <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">მთავარი პირები</span><span class="lang-en">Key Figures</span></div></div>
            <xsl:for-each select="$contextNode//tei:persName[@key]">
                <xsl:call-template name="person-entry"/>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="donations-sidebar">
      <xsl:param name="contextNode"/>
      <xsl:variable name="donations" select="$contextNode//tei:seg[contains(@type, 'donation') or contains(@subtype, 'donation') or contains(@type, 'financial') or contains(@type, 'purchase')]"/>
      <xsl:if test="$donations">
          <div class="sidebar-section">
              <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">შემოწირულობები</span><span class="lang-en">Donations</span></div></div>
              <xsl:for-each select="$donations">
                  <div class="metadata-item"><p><xsl:value-of select="normalize-space(.)"/></p></div>
              </xsl:for-each>
          </div>
      </xsl:if>
    </xsl:template>

    <xsl:template name="person-entry">
        <xsl:variable name="person_filename" select="substring-after(@ref, '#auth_pers_')"/>
        <a href="../person/{$person_filename}.html" class="person-link">
            <div class="person-name-georgian"><xsl:value-of select="@key"/> ↛</div>
            <div class="person-role">
                <span class="lang-ka"><xsl:value-of select="@role"/></span>
                <span class="lang-en"><xsl:value-of select="@role"/></span>
            </div>
        </a>
    </xsl:template>

    <xsl:template name="manuscript-details">
        <xsl:param name="contextNode"/>
        <xsl:variable name="msDesc" select="$contextNode/ancestor::tei:TEI//tei:msDesc"/>
        <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">ხელნაწერის აღწერა</span><span class="lang-en">Manuscript Description</span></div></div>
        <div id="manuscript-details-view">
            <div class="metadata-section"><div class="metadata-title"><span class="lang-ka">იდენტიფიკატორი</span><span class="lang-en">Identifier</span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">საცავი:</span><span class="lang-en">Repository:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:repository"/></span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">შიფრი:</span><span class="lang-en">ID No:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:idno"/></span></div></div>
            <div class="metadata-section"><div class="metadata-title"><span class="lang-ka">ფიზიკური აღწერა</span><span class="lang-en">Physical Description</span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">მასალა:</span><span class="lang-en">Support:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:support"/></span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">ხელი:</span><span class="lang-en">Hand:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:handNote"/></span></div></div>
            <div class="metadata-section"><div class="metadata-title"><span class="lang-ka">ისტორია</span><span class="lang-en">History</span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">წარმომავლობა:</span><span class="lang-en">Origin:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:history//tei:origPlace[@xml:lang='en']"/></span></div><div class="metadata-item"><span class="metadata-label"><span class="lang-ka">თარიღი:</span><span class="lang-en">Date:</span></span><span class="metadata-value"><xsl:value-of select="$msDesc//tei:history//tei:origDate"/></span></div></div>
        </div>
    </xsl:template>

    <xsl:template name="translate-note-type-ka">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type = 'presentation_summary'">მოკლე შინაარსი:</xsl:when>
            <xsl:when test="$type = 'key_figures'">მთავარი პირები:</xsl:when>
            <xsl:when test="$type = 'gender_analysis'">გენდერული ანალიზი:</xsl:when>
            <xsl:when test="$type = 'liturgical_calendar_order'">ლიტურგიკული რიგი:</xsl:when>
            <xsl:when test="$type = 'item_classification'">კლასიფიკაცია:</xsl:when>
            <xsl:otherwise><xsl:value-of select="translate($type, '_', ' ')"/>:</xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p"><div class="line"><div class="line-number"><xsl:value-of select="preceding-sibling::tei:lb[1]/@n"/></div><div class="line-content"><xsl:apply-templates select="node()[not(self::tei:lb) and count(preceding-sibling::tei:lb) = 0]"/></div></div><xsl:for-each select="tei:lb"><div class="line"><div class="line-number"><xsl:value-of select="@n"/></div><div class="line-content"><xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::tei:lb) = count(current()/preceding-sibling::tei:lb) + 1]"/></div></div></xsl:for-each></xsl:template>
    <xsl:template match="tei:p" mode="diplomatic"><div class="line"><div class="line-number"><xsl:value-of select="preceding-sibling::tei:lb[1]/@n"/></div><div class="line-content"><xsl:apply-templates select="node()[not(self::tei:lb) and count(preceding-sibling::tei:lb) = 0]" mode="diplomatic"/></div></div><xsl:for-each select="tei:lb"><div class="line"><div class="line-number"><xsl:value-of select="@n"/></div><div class="line-content"><xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::tei:lb) = count(current()/preceding-sibling::tei:lb) + 1]" mode="diplomatic"/></div></div></xsl:for-each></xsl:template>
    <xsl:template match="tei:supplied"><span class="supplied-text">[<xsl:apply-templates/>]</span></xsl:template>
    <xsl:template match="tei:expan"><span class="expansion"><xsl:apply-templates/></span></xsl:template>
    <xsl:template match="tei:gap"><span class="gap-marker">[---]</span></xsl:template>
    <xsl:template match="tei:p//tei:seg | tei:p//tei:note"><xsl:apply-templates/><span class="seg-type-label"><xsl:value-of select="translate(@type, '_', ' ')"/></span><xsl:text> </xsl:text></xsl:template>
    <xsl:template match="tei:supplied" mode="diplomatic"/>
    <xsl:template match="tei:expan" mode="diplomatic"><xsl:value-of select="node()[not(self::tei:ex)]"/></xsl:template>
    <xsl:template match="tei:gap" mode="diplomatic"><span class="gap-marker">[---]</span></xsl:template>
    <xsl:template match="tei:p//tei:seg | tei:p//tei:note" mode="diplomatic"><xsl:apply-templates mode="diplomatic"/><xsl:text> </xsl:text></xsl:template>
    <xsl:template match="tei:persName"><a href="../person/{substring-after(@ref, '#auth_pers_')}.html"><strong><xsl:apply-templates/></strong></a></xsl:template>
    <xsl:template match="tei:persName" mode="diplomatic"><xsl:variable name="mkhedruli" select="'აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵ'"/><xsl:variable name="nuskhuri"  select="'ⴀⴁⴂⴃⴄⴅⴆⴡⴇⴈⴉ⊄ⴋⴌⴢⴍⴎⴏⴐⴑⴒⴣⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴤⴟⴠⴥ'"/><a href="../person/{substring-after(@ref, '#auth_pers_')}.html"><strong><xsl:value-of select="translate(., $mkhedruli, $nuskhuri)"/></strong></a></xsl:template>
    <xsl:template match="tei:date | tei:term | tei:orgName"><em><xsl:apply-templates/></em></xsl:template>
    <xsl:template match="tei:date | tei:term | tei:orgName" mode="diplomatic"><em><xsl:apply-templates mode="diplomatic"/></em></xsl:template>
    <xsl:template match="text()"><xsl:value-of select="normalize-space(.)"/><xsl:if test="normalize-space(.) != ''"><xsl:text> </xsl:text></xsl:if></xsl:template>
    <xsl:template match="text()" mode="diplomatic"><xsl:variable name="mkhedruli" select="'აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵ'"/><xsl:variable name="nuskhuri"  select="'ⴀⴁⴂⴃⴄⴅⴆⴡⴇⴈⴉⴊⴋⴌⴢⴍⴎⴏⴐⴑⴒⴣⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴤⴟⴠⴥ'"/><xsl:variable name="normalized_text" select="normalize-space(.)"/><xsl:value-of select="translate($normalized_text, $mkhedruli, $nuskhuri)"/><xsl:if test="$normalized_text != ''"><xsl:text> </xsl:text></xsl:if></xsl:template>
    <xsl:template match="tei:item/tei:note"/>
    <xsl:template match="tei:ref | tei:key | tei:ex"/>
</xsl:stylesheet>
