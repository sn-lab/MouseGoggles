<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE eagle SYSTEM "eagle.dtd">
<eagle version="9.6.2">
<drawing>
<settings>
<setting alwaysvectorfont="no"/>
<setting verticaltext="up"/>
</settings>
<grid distance="0.1" unitdist="inch" unit="inch" style="lines" multiple="1" display="no" altdistance="0.01" altunitdist="inch" altunit="inch"/>
<layers>
<layer number="1" name="Top" color="4" fill="1" visible="no" active="no"/>
<layer number="16" name="Bottom" color="1" fill="1" visible="no" active="no"/>
<layer number="17" name="Pads" color="2" fill="1" visible="no" active="no"/>
<layer number="18" name="Vias" color="2" fill="1" visible="no" active="no"/>
<layer number="19" name="Unrouted" color="6" fill="1" visible="no" active="no"/>
<layer number="20" name="Dimension" color="15" fill="1" visible="no" active="no"/>
<layer number="21" name="tPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="22" name="bPlace" color="7" fill="1" visible="no" active="no"/>
<layer number="23" name="tOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="24" name="bOrigins" color="15" fill="1" visible="no" active="no"/>
<layer number="25" name="tNames" color="7" fill="1" visible="no" active="no"/>
<layer number="26" name="bNames" color="7" fill="1" visible="no" active="no"/>
<layer number="27" name="tValues" color="7" fill="1" visible="no" active="no"/>
<layer number="28" name="bValues" color="7" fill="1" visible="no" active="no"/>
<layer number="29" name="tStop" color="7" fill="3" visible="no" active="no"/>
<layer number="30" name="bStop" color="7" fill="6" visible="no" active="no"/>
<layer number="31" name="tCream" color="7" fill="4" visible="no" active="no"/>
<layer number="32" name="bCream" color="7" fill="5" visible="no" active="no"/>
<layer number="33" name="tFinish" color="6" fill="3" visible="no" active="no"/>
<layer number="34" name="bFinish" color="6" fill="6" visible="no" active="no"/>
<layer number="35" name="tGlue" color="7" fill="4" visible="no" active="no"/>
<layer number="36" name="bGlue" color="7" fill="5" visible="no" active="no"/>
<layer number="37" name="tTest" color="7" fill="1" visible="no" active="no"/>
<layer number="38" name="bTest" color="7" fill="1" visible="no" active="no"/>
<layer number="39" name="tKeepout" color="4" fill="11" visible="no" active="no"/>
<layer number="40" name="bKeepout" color="1" fill="11" visible="no" active="no"/>
<layer number="41" name="tRestrict" color="4" fill="10" visible="no" active="no"/>
<layer number="42" name="bRestrict" color="1" fill="10" visible="no" active="no"/>
<layer number="43" name="vRestrict" color="2" fill="10" visible="no" active="no"/>
<layer number="44" name="Drills" color="7" fill="1" visible="no" active="no"/>
<layer number="45" name="Holes" color="7" fill="1" visible="no" active="no"/>
<layer number="46" name="Milling" color="3" fill="1" visible="no" active="no"/>
<layer number="47" name="Measures" color="7" fill="1" visible="no" active="no"/>
<layer number="48" name="Document" color="7" fill="1" visible="no" active="no"/>
<layer number="49" name="Reference" color="7" fill="1" visible="no" active="no"/>
<layer number="51" name="tDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="52" name="bDocu" color="7" fill="1" visible="no" active="no"/>
<layer number="88" name="SimResults" color="9" fill="1" visible="yes" active="yes"/>
<layer number="89" name="SimProbes" color="9" fill="1" visible="yes" active="yes"/>
<layer number="90" name="Modules" color="5" fill="1" visible="yes" active="yes"/>
<layer number="91" name="Nets" color="2" fill="1" visible="yes" active="yes"/>
<layer number="92" name="Busses" color="1" fill="1" visible="yes" active="yes"/>
<layer number="93" name="Pins" color="2" fill="1" visible="no" active="yes"/>
<layer number="94" name="Symbols" color="4" fill="1" visible="yes" active="yes"/>
<layer number="95" name="Names" color="7" fill="1" visible="yes" active="yes"/>
<layer number="96" name="Values" color="7" fill="1" visible="yes" active="yes"/>
<layer number="97" name="Info" color="7" fill="1" visible="yes" active="yes"/>
<layer number="98" name="Guide" color="6" fill="1" visible="yes" active="yes"/>
</layers>
<schematic xreflabel="%F%N/%S.%C%R" xrefpart="/%S.%C%R">
<libraries>
<library name="VSMB2943GX01">
<packages>
<package name="DIO_VSMB2943GX01">
<text x="-2.794" y="1.651" size="1.27" layer="25">&gt;NAME</text>
<text x="-2.794" y="-1.651" size="1.27" layer="27" align="top-left">&gt;VALUE</text>
<wire x1="-1.15" y1="1.15" x2="-1.15" y2="0.695" width="0.127" layer="21"/>
<wire x1="-1.15" y1="-1.15" x2="1.15" y2="-1.15" width="0.127" layer="51"/>
<wire x1="1.15" y1="1.15" x2="1.15" y2="-1.15" width="0.127" layer="51"/>
<circle x="-3.025" y="0" radius="0.1" width="0.2" layer="51"/>
<circle x="-3.025" y="0" radius="0.1" width="0.2" layer="21"/>
<wire x1="-2.825" y1="1.4" x2="-2.825" y2="-1.4" width="0.05" layer="39"/>
<wire x1="-2.825" y1="1.4" x2="2.825" y2="1.4" width="0.05" layer="39"/>
<wire x1="2.825" y1="-1.4" x2="2.825" y2="1.4" width="0.05" layer="39"/>
<wire x1="2.825" y1="-1.4" x2="-2.825" y2="-1.4" width="0.05" layer="39"/>
<wire x1="-1.15" y1="1.15" x2="1.15" y2="1.15" width="0.127" layer="21"/>
<wire x1="-1.15" y1="1.15" x2="1.15" y2="1.15" width="0.127" layer="51"/>
<wire x1="-1.15" y1="1.15" x2="-1.15" y2="-1.15" width="0.127" layer="51"/>
<wire x1="1.15" y1="1.15" x2="1.15" y2="0.695" width="0.127" layer="21"/>
<wire x1="1.15" y1="-1.15" x2="1.15" y2="-0.695" width="0.127" layer="21"/>
<wire x1="1.15" y1="-1.15" x2="-1.15" y2="-1.15" width="0.127" layer="21"/>
<wire x1="-1.15" y1="-1.15" x2="-1.15" y2="-0.695" width="0.127" layer="21"/>
<smd name="C" x="-1.9" y="0" dx="1.35" dy="0.75" layer="1"/>
<smd name="A" x="1.9" y="0" dx="1.35" dy="0.75" layer="1"/>
</package>
</packages>
<symbols>
<symbol name="VSMB2943GX01">
<wire x1="-2.54" y1="1.524" x2="-2.54" y2="0" width="0.254" layer="94"/>
<wire x1="-2.54" y1="0" x2="-2.54" y2="-1.524" width="0.254" layer="94"/>
<wire x1="-2.54" y1="-1.524" x2="0" y2="0" width="0.254" layer="94"/>
<wire x1="0" y1="0" x2="-2.54" y2="1.524" width="0.254" layer="94"/>
<wire x1="0" y1="1.524" x2="0" y2="-1.524" width="0.254" layer="94"/>
<wire x1="-2.54" y1="0" x2="-5.08" y2="0" width="0.1524" layer="94"/>
<text x="-3.556" y="4.826" size="1.27" layer="95">&gt;NAME</text>
<text x="-3.556" y="-3.302" size="1.27" layer="96">&gt;VALUE</text>
<text x="1.016" y="2.032" size="1.016" layer="94">IR</text>
<wire x1="1.016" y1="4.064" x2="-0.762" y2="2.032" width="0.254" layer="94"/>
<wire x1="0.6858" y1="3.0988" x2="0.127" y2="3.5814" width="0.254" layer="94"/>
<wire x1="0.127" y1="3.5814" x2="1.016" y2="4.064" width="0.254" layer="94"/>
<wire x1="1.016" y1="4.064" x2="0.6858" y2="3.0988" width="0.254" layer="94"/>
<wire x1="0.6858" y1="3.0988" x2="0.7112" y2="3.8354" width="0.254" layer="94"/>
<wire x1="0.7112" y1="3.8354" x2="0.5842" y2="3.8354" width="0.254" layer="94"/>
<wire x1="0.3048" y1="3.5052" x2="0.5334" y2="3.6576" width="0.254" layer="94"/>
<wire x1="-0.2286" y1="4.1656" x2="-2.0066" y2="2.1336" width="0.254" layer="94"/>
<wire x1="-0.5588" y1="3.2004" x2="-1.1176" y2="3.683" width="0.254" layer="94"/>
<wire x1="-1.1176" y1="3.683" x2="-0.2286" y2="4.1656" width="0.254" layer="94"/>
<wire x1="-0.2286" y1="4.1656" x2="-0.5588" y2="3.2004" width="0.254" layer="94"/>
<wire x1="-0.5588" y1="3.2004" x2="-0.5334" y2="3.937" width="0.254" layer="94"/>
<wire x1="-0.5334" y1="3.937" x2="-0.6604" y2="3.937" width="0.254" layer="94"/>
<wire x1="-0.9398" y1="3.6068" x2="-0.7112" y2="3.7592" width="0.254" layer="94"/>
<pin name="C" x="5.08" y="0" visible="pad" length="middle" direction="pas" rot="R180"/>
<pin name="A" x="-7.62" y="0" visible="pad" length="short" direction="pas"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="VSMB2943GX01" prefix="D">
<description>Infrared Emitter 940nm 20mW/sr Circular Top Mount Automotive 2-Pin SMD T/R </description>
<gates>
<gate name="G$1" symbol="VSMB2943GX01" x="0" y="0"/>
</gates>
<devices>
<device name="" package="DIO_VSMB2943GX01">
<connects>
<connect gate="G$1" pin="A" pad="A"/>
<connect gate="G$1" pin="C" pad="C"/>
</connects>
<technologies>
<technology name="">
<attribute name="MANUFACTURER" value="VISHAY"/>
<attribute name="MAXIMUM_PACKAGE_HEIGHT" value="2.7mm"/>
<attribute name="PARTREV" value="1.6"/>
<attribute name="STANDARD" value="Manufacturer recommendations"/>
</technology>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
<library name="RC0805FR-07100RL">
<packages>
<package name="RESC2012X60N">
<text x="-1.66" y="-1.02" size="0.5" layer="27" align="top-left">&gt;VALUE</text>
<text x="-1.66" y="1.02" size="0.5" layer="25">&gt;NAME</text>
<wire x1="1.05" y1="-0.68" x2="-1.05" y2="-0.68" width="0.127" layer="51"/>
<wire x1="1.05" y1="0.68" x2="-1.05" y2="0.68" width="0.127" layer="51"/>
<wire x1="1.05" y1="-0.68" x2="1.05" y2="0.68" width="0.127" layer="51"/>
<wire x1="-1.05" y1="-0.68" x2="-1.05" y2="0.68" width="0.127" layer="51"/>
<wire x1="-0.17" y1="0.68" x2="0.17" y2="0.68" width="0.127" layer="21"/>
<wire x1="-0.17" y1="-0.68" x2="0.17" y2="-0.68" width="0.127" layer="21"/>
<wire x1="-1.665" y1="-0.94" x2="1.665" y2="-0.94" width="0.05" layer="39"/>
<wire x1="-1.665" y1="0.94" x2="1.665" y2="0.94" width="0.05" layer="39"/>
<wire x1="-1.665" y1="-0.94" x2="-1.665" y2="0.94" width="0.05" layer="39"/>
<wire x1="1.665" y1="-0.94" x2="1.665" y2="0.94" width="0.05" layer="39"/>
<smd name="1" x="-0.955" y="0" dx="0.92" dy="1.38" layer="1"/>
<smd name="2" x="0.955" y="0" dx="0.92" dy="1.38" layer="1"/>
</package>
</packages>
<symbols>
<symbol name="RC0805FR-07100RL">
<wire x1="-5.08" y1="0" x2="-4.445" y2="1.905" width="0.254" layer="94"/>
<wire x1="-4.445" y1="1.905" x2="-3.175" y2="-1.905" width="0.254" layer="94"/>
<wire x1="-3.175" y1="-1.905" x2="-1.905" y2="1.905" width="0.254" layer="94"/>
<wire x1="-1.905" y1="1.905" x2="-0.635" y2="-1.905" width="0.254" layer="94"/>
<wire x1="-0.635" y1="-1.905" x2="0.635" y2="1.905" width="0.254" layer="94"/>
<wire x1="0.635" y1="1.905" x2="1.905" y2="-1.905" width="0.254" layer="94"/>
<wire x1="1.905" y1="-1.905" x2="3.175" y2="1.905" width="0.254" layer="94"/>
<wire x1="3.175" y1="1.905" x2="4.445" y2="-1.905" width="0.254" layer="94"/>
<wire x1="4.445" y1="-1.905" x2="5.08" y2="0" width="0.254" layer="94"/>
<text x="-7.624440625" y="2.54148125" size="2.54148125" layer="95">&gt;NAME</text>
<text x="-7.62996875" y="-5.086640625" size="2.54331875" layer="96">&gt;VALUE</text>
<pin name="1" x="-10.16" y="0" visible="off" length="middle" direction="pas"/>
<pin name="2" x="10.16" y="0" visible="off" length="middle" direction="pas" rot="R180"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="RC0805FR-07100RL" prefix="R">
<description>Resistor SMD [YAGEO] RC0805FR-07100RL Resistor SMD </description>
<gates>
<gate name="G$1" symbol="RC0805FR-07100RL" x="0" y="0"/>
</gates>
<devices>
<device name="" package="RESC2012X60N">
<connects>
<connect gate="G$1" pin="1" pad="1"/>
<connect gate="G$1" pin="2" pad="2"/>
</connects>
<technologies>
<technology name=""/>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
<library name="pinhead" urn="urn:adsk.eagle:library:325">
<description>&lt;b&gt;Pin Header Connectors&lt;/b&gt;&lt;p&gt;
&lt;author&gt;Created by librarian@cadsoft.de&lt;/author&gt;</description>
<packages>
<package name="1X01" urn="urn:adsk.eagle:footprint:22382/1" library_version="4">
<description>&lt;b&gt;PIN HEADER&lt;/b&gt;</description>
<wire x1="-0.635" y1="1.27" x2="0.635" y2="1.27" width="0.1524" layer="21"/>
<wire x1="0.635" y1="1.27" x2="1.27" y2="0.635" width="0.1524" layer="21"/>
<wire x1="1.27" y1="0.635" x2="1.27" y2="-0.635" width="0.1524" layer="21"/>
<wire x1="1.27" y1="-0.635" x2="0.635" y2="-1.27" width="0.1524" layer="21"/>
<wire x1="-1.27" y1="0.635" x2="-1.27" y2="-0.635" width="0.1524" layer="21"/>
<wire x1="-0.635" y1="1.27" x2="-1.27" y2="0.635" width="0.1524" layer="21"/>
<wire x1="-1.27" y1="-0.635" x2="-0.635" y2="-1.27" width="0.1524" layer="21"/>
<wire x1="0.635" y1="-1.27" x2="-0.635" y2="-1.27" width="0.1524" layer="21"/>
<pad name="1" x="0" y="0" drill="1.016" shape="octagon"/>
<text x="-1.3462" y="1.8288" size="1.27" layer="25" ratio="10">&gt;NAME</text>
<text x="-1.27" y="-3.175" size="1.27" layer="27">&gt;VALUE</text>
<rectangle x1="-0.254" y1="-0.254" x2="0.254" y2="0.254" layer="51"/>
</package>
</packages>
<packages3d>
<package3d name="1X01" urn="urn:adsk.eagle:package:22485/2" type="model" library_version="4">
<description>PIN HEADER</description>
<packageinstances>
<packageinstance name="1X01"/>
</packageinstances>
</package3d>
</packages3d>
<symbols>
<symbol name="PINHD1" urn="urn:adsk.eagle:symbol:22381/1" library_version="4">
<wire x1="-6.35" y1="-2.54" x2="1.27" y2="-2.54" width="0.4064" layer="94"/>
<wire x1="1.27" y1="-2.54" x2="1.27" y2="2.54" width="0.4064" layer="94"/>
<wire x1="1.27" y1="2.54" x2="-6.35" y2="2.54" width="0.4064" layer="94"/>
<wire x1="-6.35" y1="2.54" x2="-6.35" y2="-2.54" width="0.4064" layer="94"/>
<text x="-6.35" y="3.175" size="1.778" layer="95">&gt;NAME</text>
<text x="-6.35" y="-5.08" size="1.778" layer="96">&gt;VALUE</text>
<pin name="1" x="-2.54" y="0" visible="pad" length="short" direction="pas" function="dot"/>
</symbol>
</symbols>
<devicesets>
<deviceset name="PINHD-1X1" urn="urn:adsk.eagle:component:22540/3" prefix="JP" uservalue="yes" library_version="4">
<description>&lt;b&gt;PIN HEADER&lt;/b&gt;</description>
<gates>
<gate name="G$1" symbol="PINHD1" x="0" y="0"/>
</gates>
<devices>
<device name="" package="1X01">
<connects>
<connect gate="G$1" pin="1" pad="1"/>
</connects>
<package3dinstances>
<package3dinstance package3d_urn="urn:adsk.eagle:package:22485/2"/>
</package3dinstances>
<technologies>
<technology name="">
<attribute name="POPULARITY" value="64" constant="no"/>
</technology>
</technologies>
</device>
</devices>
</deviceset>
</devicesets>
</library>
</libraries>
<attributes>
</attributes>
<variantdefs>
</variantdefs>
<classes>
<class number="0" name="default" width="0" drill="0">
</class>
</classes>
<parts>
<part name="D1" library="VSMB2943GX01" deviceset="VSMB2943GX01" device=""/>
<part name="D2" library="VSMB2943GX01" deviceset="VSMB2943GX01" device=""/>
<part name="R1" library="RC0805FR-07100RL" deviceset="RC0805FR-07100RL" device=""/>
<part name="JP1" library="pinhead" library_urn="urn:adsk.eagle:library:325" deviceset="PINHD-1X1" device="" package3d_urn="urn:adsk.eagle:package:22485/2"/>
<part name="JP2" library="pinhead" library_urn="urn:adsk.eagle:library:325" deviceset="PINHD-1X1" device="" package3d_urn="urn:adsk.eagle:package:22485/2"/>
</parts>
<sheets>
<sheet>
<plain>
</plain>
<instances>
<instance part="D1" gate="G$1" x="27.94" y="91.44" smashed="yes">
<attribute name="NAME" x="24.384" y="96.266" size="1.27" layer="95"/>
<attribute name="VALUE" x="24.384" y="88.138" size="1.27" layer="96"/>
</instance>
<instance part="D2" gate="G$1" x="66.04" y="91.44" smashed="yes">
<attribute name="NAME" x="62.484" y="96.266" size="1.27" layer="95"/>
<attribute name="VALUE" x="62.484" y="88.138" size="1.27" layer="96"/>
</instance>
<instance part="R1" gate="G$1" x="45.72" y="111.76" smashed="yes">
<attribute name="NAME" x="38.095559375" y="114.30148125" size="2.54148125" layer="95"/>
</instance>
<instance part="JP1" gate="G$1" x="30.48" y="132.08" smashed="yes">
<attribute name="NAME" x="24.13" y="135.255" size="1.778" layer="95"/>
<attribute name="VALUE" x="24.13" y="127" size="1.778" layer="96"/>
</instance>
<instance part="JP2" gate="G$1" x="71.12" y="132.08" smashed="yes">
<attribute name="NAME" x="64.77" y="135.255" size="1.778" layer="95"/>
<attribute name="VALUE" x="64.77" y="127" size="1.778" layer="96"/>
</instance>
</instances>
<busses>
</busses>
<nets>
<net name="N$1" class="0">
<segment>
<pinref part="R1" gate="G$1" pin="2"/>
<wire x1="55.88" y1="111.76" x2="68.58" y2="111.76" width="0.1524" layer="91"/>
<pinref part="JP2" gate="G$1" pin="1"/>
<wire x1="68.58" y1="111.76" x2="68.58" y2="132.08" width="0.1524" layer="91"/>
</segment>
</net>
<net name="N$4" class="0">
<segment>
<pinref part="D2" gate="G$1" pin="C"/>
<wire x1="73.66" y1="91.44" x2="71.12" y2="91.44" width="0.1524" layer="91"/>
<wire x1="73.66" y1="91.44" x2="73.66" y2="101.6" width="0.1524" layer="91"/>
<wire x1="73.66" y1="101.6" x2="35.56" y2="101.6" width="0.1524" layer="91"/>
<pinref part="D1" gate="G$1" pin="C"/>
<pinref part="R1" gate="G$1" pin="1"/>
<wire x1="33.02" y1="91.44" x2="35.56" y2="91.44" width="0.1524" layer="91"/>
<wire x1="35.56" y1="91.44" x2="35.56" y2="111.76" width="0.1524" layer="91"/>
<wire x1="35.56" y1="101.6" x2="35.56" y2="111.76" width="0.1524" layer="91"/>
<junction x="35.56" y="111.76"/>
</segment>
</net>
<net name="N$2" class="0">
<segment>
<pinref part="JP1" gate="G$1" pin="1"/>
<wire x1="27.94" y1="132.08" x2="15.24" y2="132.08" width="0.1524" layer="91"/>
<pinref part="D1" gate="G$1" pin="A"/>
<wire x1="15.24" y1="132.08" x2="15.24" y2="91.44" width="0.1524" layer="91"/>
<wire x1="15.24" y1="91.44" x2="20.32" y2="91.44" width="0.1524" layer="91"/>
<wire x1="15.24" y1="91.44" x2="15.24" y2="83.82" width="0.1524" layer="91"/>
<wire x1="15.24" y1="83.82" x2="58.42" y2="83.82" width="0.1524" layer="91"/>
<junction x="15.24" y="91.44"/>
<pinref part="D2" gate="G$1" pin="A"/>
<wire x1="58.42" y1="83.82" x2="58.42" y2="91.44" width="0.1524" layer="91"/>
</segment>
</net>
</nets>
</sheet>
</sheets>
</schematic>
</drawing>
<compatibility>
<note version="8.2" severity="warning">
Since Version 8.2, EAGLE supports online libraries. The ids
of those online libraries will not be understood (or retained)
with this version.
</note>
<note version="8.3" severity="warning">
Since Version 8.3, EAGLE supports URNs for individual library
assets (packages, symbols, and devices). The URNs of those assets
will not be understood (or retained) with this version.
</note>
<note version="8.3" severity="warning">
Since Version 8.3, EAGLE supports the association of 3D packages
with devices in libraries, schematics, and board files. Those 3D
packages will not be understood (or retained) with this version.
</note>
</compatibility>
</eagle>
