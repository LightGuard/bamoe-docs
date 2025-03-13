<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <!-- Compose the XML and DOCTYPE declarations for the main output: -->
    <xsl:output encoding="utf-8" method="xml" doctype-system="topic.dtd" doctype-public="-//OASIS//DTD DITA Topic//EN"
                indent="yes"/>

    <!-- Same output for the subsections, not sure if there's an easy way to reference this -->
    <xsl:output name="sub-section" indent="yes" method="xml" doctype-system="topic.dtd"
                doctype-public="-//OASIS//DTD DITA Topic//EN" encoding="utf-8"/>

    <xsl:variable name="file-extension" select="'.dita'" />

    <xsl:strip-space elements="*" />
    <xsl:preserve-space elements="codeblock pre screen" />

    <!-- Fix up any xref links that reference adoc documents
         since adoc will not be used after the dita conversion -->
    <xsl:template match="//xref[contains(@href, '.adoc')]">
        <xref href="{replace(@href, '.adoc', '.dita')}"><xsl:value-of select="text()" /></xref>
    </xsl:template>

    <!--
        Sections cannot be nested in DITA, but you can do a content reference.
        This splits out the nested section into its own topic file and creates a conref in the original document.
        The new subsection file will be created alongside the original with the id of the current topic and the
        subsection concatenated together.
    -->
    <xsl:template match="/topic/body/section//section">
        <xsl:variable name="sub-section-filename" select="concat(ancestor::topic/@id, @id, $file-extension)" />
        <div conref="{$sub-section-filename}">
            <xsl:value-of select="@id" />
        </div>
        <xsl:result-document href="{$sub-section-filename}" format="sub-section">
            <topic id="{@id}">
                <xsl:copy-of select="title" />
                <body>
                    <xsl:apply-templates select="node()" />
                </body>
            </topic>
        </xsl:result-document>
    </xsl:template>

    <!-- Don't need the title to be added in a subsection -->
    <xsl:template match="//section[position() > 1]/title"/>

    <!-- Perform identity transformation -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>