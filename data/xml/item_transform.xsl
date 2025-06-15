<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <xsl:output method="html" doctype-system="about:legacy-compat" encoding="UTF-8" indent="yes"/>

    <xsl:variable name="manuscript" select="document('../tischendorf_01.xml')"/>

    <!-- Key for Muenchian Grouping (Line-by-Line display) -->
    <xsl:key name="line-content" match="tei:p/node()[not(self::tei:lb)]" use="generate-id(preceding-sibling::tei:lb[1])"/>


    <!-- =================================================================== -->
    <!-- I. MAIN TEMPLATE (builds the page structure)                      -->
    <!-- =================================================================== -->
    <xsl:template match="/">
        <xsl:variable name="item" select="//tei:item"/>
        <xsl:variable name="itemNum" select="$item/@n"/>
        <xsl:variable name="englishSummary" select="normalize-space($item/tei:note[@type='presentation_summary'])"/>

        <html lang="ka">
          <head>
            <meta charset="UTF-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <!-- The main project title -->
            <title>იერუსალიმის ჯვრის მონასტრის აღაპები - პროსოპოგრაფიული მონაცემთა ბაზა</title>
            <!-- Adjust the path to the stylesheet -->
            <link rel="stylesheet" href="../../style.css"/>
            <!-- Add the D3 script for potential future use or consistency -->
            <script src="https://cdnjs.cloudflare.com/ajax/libs/d3/7.8.5/d3.min.js"></script>
          </head>
            <body class="lang-ka-active">

                <div class="page-top-bar">
                    <a href="../../index.html#prosopography" class="back-link">
                        <span class="lang-ka georgian-main">← უკან მონაცემთა ბაზაში</span>
                        <span class="lang-en">← Back to Database</span>
                    </a>

                </div>

                <div class="container">
                  <header class="header">
                    <div class="header-top-controls">
                        <a href="../../index.html#prosopography" class="back-link">
                            <span class="lang-ka georgian-main">← უკან მონაცემთა ბაზაში</span>
                            <span class="lang-en">← Back to Database</span>
                        </a>
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

                        <!-- We integrate the item navigation here -->
                        <xsl:call-template name="item-navigation">
                            <xsl:with-param name="currentItemNumber" select="$itemNum"/>
                        </xsl:call-template>
                    </div>
                  </header>

                    <div class="scholarly-viewer">
                        <!-- Left Panel -->
                        <div class="manuscript-panel">
                            <xsl:call-template name="manuscript-details"/>
                            <xsl:call-template name="key-figures-sidebar"/>
                            <xsl:call-template name="donations-sidebar"/>
                        </div>

                        <!-- Right Panel -->
                        <div class="text-apparatus-container">
                            <div class="text-panel">
                                <div class="panel-header">
                                    <div class="panel-title-text">
                                        <span class="lang-ka">ტექსტი</span>
                                        <span class="lang-en">Transcription</span>
                                    </div>
                                    <div class="view-mode-switch">
                                        <label><input type="radio" name="view-mode" value="critical" checked="checked" onchange="switchTextView('critical')"/> Critical</label>
                                        <label><input type="radio" name="view-mode" value="diplomatic" onchange="switchTextView('diplomatic')"/> Diplomatic</label>
                                    </div>
                                </div>

                                <div class="transcription-viewer">
                                    <div id="critical-view" class="transcription-text">
                                        <xsl:apply-templates select="$item/tei:p"/>
                                    </div>
                                    <div id="diplomatic-view" class="transcription-text" style="display:none;">
                                        <xsl:apply-templates select="$item/tei:p" mode="diplomatic"/>
                                    </div>
                                </div>
                            </div>

                            <div class="apparatus-panel">
                                <div class="panel-header">
                                    <div class="panel-title-text">
                                      <span class="lang-ka">სამეცნიერო აპარატი და შენიშვნები</span>
                                      <span class="lang-en">Scholarly Apparatus and Notes</span>
                                    </div>
                                </div>
                                <div class="apparatus-viewer">
                                    <xsl:for-each select="$item/tei:note[not(@type='presentation_summary')]">
                                        <div class="apparatus-note">
                                            <span class="note-type">
                                                <xsl:variable name="type" select="@type"/>
                                                <span class="lang-ka">
                                                    <xsl:choose>
                                                        <xsl:when test="$type = 'presentation_summary'">მოკლე შინაარსი:</xsl:when>
                                                        <xsl:when test="$type = 'key_figures'">მთავარი პირები:</xsl:when>
                                                        <xsl:when test="$type = 'gender_analysis'">გენდერული ანალიზი:</xsl:when>
                                                        <xsl:when test="$type = 'liturgical_calendar_order'">ლიტურგიკული რიგი:</xsl:when>
                                                        <xsl:when test="$type = 'item_classification'">კლასიფიკაცია:</xsl:when>
                                                        <xsl:otherwise><xsl:value-of select="translate($type, '_', ' ')"/>:</xsl:otherwise>
                                                    </xsl:choose>
                                                </span>
                                                <span class="lang-en">
                                                    <xsl:value-of select="translate($type, '_', ' ')"/>:
                                                </span>
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
                        const btnKa = document.getElementById('btn-ka');
                        const btnEn = document.getElementById('btn-en');
                        body.classList.toggle('lang-ka-active', lang === 'ka');
                        body.classList.toggle('lang-en-active', lang === 'en');
                        btnKa.classList.toggle('active', lang === 'ka');
                        btnEn.classList.toggle('active', lang === 'en');
                        document.querySelectorAll('.page-top-bar .lang-ka, .header .lang-ka, .manuscript-panel .lang-ka, .panel-title-text .lang-ka').forEach(el => {
                            el.style.display = (lang === 'ka') ? 'block' : 'none';
                        });
                        document.querySelectorAll('.page-top-bar .lang-en, .header .lang-en, .manuscript-panel .lang-en, .panel-title-text .lang-en').forEach(el => {
                            el.style.display = (lang === 'en') ? 'block' : 'none';
                        });
                    }

                    function switchTextView(view) {
                        document.getElementById('critical-view').style.display = 'none';
                        document.getElementById('diplomatic-view').style.display = 'none';
                        document.getElementById(view + '-view').style.display = 'block';
                    }

                    document.addEventListener('DOMContentLoaded', function() {
                        switchLang('ka');
                        switchTextView('critical');
                    });
                </script>
            </body>
        </html>
    </xsl:template>

    <!-- =================================================================== -->
    <!-- II. NAMED TEMPLATES (reusable component blocks)                   -->
    <!-- =================================================================== -->

    <xsl:template name="item-navigation">
        <!-- This parameter receives the item number from the call -->
        <xsl:param name="currentItemNumber"/>

        <!-- The rest of the logic now uses the parameter -->
        <xsl:variable name="currentItemInList" select="$manuscript//tei:item[number(@n) = number($currentItemNumber)]"/>
        <xsl:variable name="prevItem" select="$currentItemInList/preceding-sibling::tei:item[1]"/>
        <xsl:variable name="nextItem" select="$currentItemInList/following-sibling::tei:item[1]"/>

        <div class="item-navigation">
            <div class="nav-prev">
                <xsl:if test="$prevItem">
                    <a href="item-{$prevItem/@n}.html">
                        <span class="lang-ka">← წინა</span>
                        <span class="lang-en">← Previous</span>
                    </a>
                </xsl:if>
            </div>

            <!-- ===== START: NEW CENTER ELEMENT ===== -->
            <div class="nav-current-item">
                <span class="lang-ka">ჩანაწერი <xsl:value-of select="$currentItemNumber"/></span>
                <span class="lang-en">Item <xsl:value-of select="$currentItemNumber"/></span>
            </div>
            <!-- ===== END: NEW CENTER ELEMENT ===== -->

            <div class="nav-next">
                <xsl:if test="$nextItem">
                    <a href="item-{$nextItem/@n}.html">
                        <span class="lang-ka">შემდეგი →</span>
                        <span class="lang-en">Next →</span>
                    </a>
                </xsl:if>
            </div>
        </div>
    </xsl:template>

    <xsl:template name="key-figures-sidebar">
        <div class="sidebar-section">
            <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">მთავარი პირები</span><span class="lang-en">Key Figures</span></div></div>
            <xsl:for-each select="//tei:item//tei:persName[@key]">
                <xsl:call-template name="person-entry"/>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="donations-sidebar">
      <xsl:variable name="donations" select="//tei:item//tei:seg[contains(@type, 'donation') or contains(@subtype, 'donation') or contains(@type, 'financial') or contains(@type, 'purchase')]"/>
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
            <div class="person-name-georgian"><xsl:value-of select="@key"/> →</div>
            <div class="person-role">
                <span class="lang-ka"><xsl:value-of select="@role"/></span>
                <span class="lang-en"><xsl:value-of select="@role"/></span>
            </div>
        </a>
    </xsl:template>

    <xsl:template name="manuscript-details">
        <xsl:variable name="msDesc" select="$manuscript//tei:msDesc[@xml:id='ms_lpz_v1085']"/>
        <div class="panel-header"><div class="panel-title-text"><span class="lang-ka">ხელნაწერის აღწერა</span><span class="lang-en">Manuscript Description</span></div></div>
        <div id="manuscript-details-view">
            <div class="metadata-section">
                <div class="metadata-title">
                    <span class="lang-ka">იდენტიფიკატორი</span>
                    <span class="lang-en">Identifier</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">საცავი:</span>
                        <span class="lang-en">Repository:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:repository"/></span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">შიფრი:</span>
                        <span class="lang-en">ID No:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:idno"/></span>
                </div>
            </div>
            <div class="metadata-section">
                <div class="metadata-title">
                    <span class="lang-ka">ფიზიკური აღწერა</span>
                    <span class="lang-en">Physical Description</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">მასალა:</span>
                        <span class="lang-en">Support:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:support"/></span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">ხელი:</span>
                        <span class="lang-en">Hand:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:handNote"/></span>
                </div>
            </div>
            <div class="metadata-section">
                <div class="metadata-title">
                    <span class="lang-ka">ისტორია</span>
                    <span class="lang-en">History</span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">წარმომავლობა:</span>
                        <span class="lang-en">Origin:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:history//tei:origPlace[@xml:lang='en']"/></span>
                </div>
                <div class="metadata-item">
                    <span class="metadata-label">
                        <span class="lang-ka">თარიღი:</span>
                        <span class="lang-en">Date:</span>
                    </span>
                    <span class="metadata-value"><xsl:value-of select="$msDesc//tei:history//tei:origDate"/></span>
                </div>
            </div>
        </div>
    </xsl:template>

    <!-- =================================================================== -->
    <!-- III. MATCHING TEMPLATES (how to render specific TEI tags)         -->
    <!-- =================================================================== -->

    <xsl:template match="tei:p">
          <!-- 1. ALWAYS process the very first line. -->
          <div class="line">
              <div class="line-number">
                  <!-- The line number is from the LB right before the <p> tag -->
                  <xsl:value-of select="preceding-sibling::tei:lb[1]/@n"/>
              </div>
              <div class="line-content">
                  <!-- The content is everything BEFORE the first <lb> inside the <p> -->
                  <xsl:apply-templates select="node()[not(self::tei:lb) and count(preceding-sibling::tei:lb) = 0]"/>
              </div>
          </div>

          <!-- 2. Now, loop through any LBs INSIDE the <p> to create the other lines. -->
          <xsl:for-each select="tei:lb">
              <div class="line">
                  <div class="line-number"><xsl:value-of select="@n"/></div>
                  <div class="line-content">
                      <!-- The content is everything between this LB and the next one -->
                      <xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::tei:lb) = count(current()/preceding-sibling::tei:lb) + 1]"/>
                  </div>
              </div>
          </xsl:for-each>
      </xsl:template>

      <xsl:template match="tei:p" mode="diplomatic">
          <!-- 1. ALWAYS process the very first line. -->
          <div class="line">
              <div class="line-number">
                  <xsl:value-of select="preceding-sibling::tei:lb[1]/@n"/>
              </div>
              <div class="line-content">
                  <xsl:apply-templates select="node()[not(self::tei:lb) and count(preceding-sibling::tei:lb) = 0]" mode="diplomatic"/>
              </div>
          </div>

          <!-- 2. Now, loop through any LBs INSIDE the <p> to create the other lines. -->
          <xsl:for-each select="tei:lb">
              <div class="line">
                  <div class="line-number"><xsl:value-of select="@n"/></div>
                  <div class="line-content">
                      <xsl:apply-templates select="following-sibling::node()[count(preceding-sibling::tei:lb) = count(current()/preceding-sibling::tei:lb) + 1]" mode="diplomatic"/>
                  </div>
              </div>
          </xsl:for-each>
      </xsl:template>

    <!-- CRITICAL VIEW TEMPLATES (Default Mode) -->
    <xsl:template match="tei:supplied">
        <span class="supplied-text">[<xsl:apply-templates/>]</span>
    </xsl:template>
    <xsl:template match="tei:expan">
        <span class="expansion"><xsl:apply-templates/></span>
    </xsl:template>
    <xsl:template match="tei:gap">
        <span class="gap-marker">[---]</span>
    </xsl:template>
    <xsl:template match="tei:p//tei:seg | tei:p//tei:note">
        <xsl:apply-templates/>
        <span class="seg-type-label"><xsl:value-of select="translate(@type, '_', ' ')"/></span>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- DIPLOMATIC VIEW TEMPLATES (mode="diplomatic") -->
    <xsl:template match="tei:supplied" mode="diplomatic"/>
    <xsl:template match="tei:expan" mode="diplomatic">
        <xsl:value-of select="node()[not(self::tei:ex)]"/>
    </xsl:template>
    <xsl:template match="tei:gap" mode="diplomatic">
        <span class="gap-marker">[---]</span>
    </xsl:template>
    <xsl:template match="tei:p//tei:seg | tei:p//tei:note" mode="diplomatic">
        <xsl:apply-templates mode="diplomatic"/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- SHARED TEMPLATES (used by both modes) -->
    <xsl:template match="tei:persName">
         <xsl:variable name="person_filename" select="substring-after(@ref, '#auth_pers_')"/>
        <a href="../person/{$person_filename}.html"><strong><xsl:apply-templates/></strong></a>
    </xsl:template>
    <xsl:template match="tei:persName" mode="diplomatic">
        <!-- Define the character maps again, or use a global variable -->
        <xsl:variable name="mkhedruli" select="'აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵ'"/>
        <xsl:variable name="nuskhuri"  select="'ⴀⴁⴂⴃⴄⴅⴆⴡⴇⴈⴉⴊⴋⴌⴢⴍⴎⴏⴐⴑⴒⴣⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴤⴟⴠⴥ'"/>

        <xsl:variable name="person_filename" select="substring-after(@ref, '#auth_pers_')"/>
        <a href="../person/{$person_filename}.html">
            <strong>
                <!-- Get the text value, THEN translate it -->
                <xsl:value-of select="translate(., $mkhedruli, $nuskhuri)"/>
            </strong>
        </a>
    </xsl:template>

    <xsl:template match="tei:date | tei:term | tei:orgName">
        <em><xsl:apply-templates/></em>
    </xsl:template>
    <xsl:template match="tei:date | tei:term | tei:orgName" mode="diplomatic">
        <em><xsl:apply-templates mode="diplomatic"/></em>
    </xsl:template>

    <!-- FINAL CATCH-ALL AND IGNORE TEMPLATES -->
    <!-- Template for CRITICAL (default) mode -->
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:if test="normalize-space(.) != ''"><xsl:text> </xsl:text></xsl:if>
    </xsl:template>

    <!-- Template for DIPLOMATIC mode with Nuskhuri translation -->
    <xsl:template match="text()" mode="diplomatic">
        <!-- Define the character maps for translation -->
        <xsl:variable name="mkhedruli" select="'აბგდევზჱთიკლმნჲოპჟრსტჳუფქღყშჩცძწჭხჴჯჰჵ'"/>
        <xsl:variable name="nuskhuri"  select="'ⴀⴁⴂⴃⴄⴅⴆⴡⴇⴈⴉⴊⴋⴌⴢⴍⴎⴏⴐⴑⴒⴣⴓⴔⴕⴖⴗⴘⴙⴚⴛⴜⴝⴞⴤⴟⴠⴥ'"/>

        <xsl:variable name="normalized_text" select="normalize-space(.)"/>

        <xsl:value-of select="translate($normalized_text, $mkhedruli, $nuskhuri)"/>

        <xsl:if test="$normalized_text != ''"><xsl:text> </xsl:text></xsl:if>
    </xsl:template>


    <xsl:template match="tei:item/tei:note"/>
    <xsl:template match="tei:ref | tei:key | tei:ex"/>

</xsl:stylesheet>
