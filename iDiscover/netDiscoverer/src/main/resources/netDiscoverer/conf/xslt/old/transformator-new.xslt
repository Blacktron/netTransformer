<?xml version="1.0" encoding="UTF-8"?>
<!--
  ~ iTransformer is an open source tool able to discover IP networks
  ~ and to perform dynamic data data population into a xml based inventory system.
  ~ Copyright (C) 2010  http://itransformers.net
  ~
  ~ This program is free software: you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation, either version 3 of the License, or
  ~ any later version.
  ~
  ~ This program is distributed in the hope that it will be useful,
  ~ but WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  ~ GNU General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program.  If not, see <http://www.gnu.org/licenses/>.
  -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:SnmpForXslt="net.itransformers.idiscover.discoveryhelpers.xml.SnmpForXslt" xmlns:exslt="http://exslt.org/common"
                extension-element-prefixes="exslt" xmlns:functx="http://www.functx.com"
                xmlns:IPv6formatConvertor="net.itransformers.idiscover.util.IPv6formatConvertor">
	<xsl:output method="xml" omit-xml-declaration="yes"/>
	<xsl:param name="ipAddress"/>
	<xsl:param name="status"/>
	<xsl:param name="community"/>
	<xsl:param name="community2"/>
	<xsl:param name="hopsToInitial"/>
	<xsl:include href="../utils.xslt"/>
	<xsl:include href="../discovery-methods.xslt"/>
	<xsl:variable name="comm" select="$community"/>
	<xsl:variable name="comm2" select="$community2"/>
	<xsl:variable name="deviceIPv4Address" select="$ipAddress"/>
	<xsl:variable name="dev_state" select="$status"/>
	<xsl:template match="/">
		<!--
		<xsl:output method="xml" omit-xml-declaration="yes"/>
        This file transforms the raw-node data to the common object oriented model used by snmpDiscovery manager for representing
        different devices architecture.
        The current model consist of a node that has:
         1. Several common node parameters
         2. Several node objects including:
            2.1 Objects that represent node interfaces
            2.1.1 Under some of the interfaces there are objects that represent one or more addresses connfigured under the interface.
            2.2.2 Neighbors found by the snmpDiscovery methods under the particular interface. Each time the neighbor address is identified
             a snmp-get is perform in order to obtain neighbor hostname. Currently the following snmpDiscovery methods are supported:

            2.2.2.1 MAC address table neighbors. This table represent L2 Neighbors in Ethernet network. Those neighbors are identified by
            MAC address and physical interface index. Unfortunately it does not contain neighbor IP address. So to find it a cross check
            is performed against the IPv4 ARP table. Neighbors that could not be obtained are marked with the name "Unknown - MAC addreess".

            2.2.2.2 ARP address table neighbors - Neighbors here are identified by a MAC, IP and interface index. It is important to note
            that those indexes represent in many cases represent node logical interfaces (e.g vlan interfaces).

            2.2.2.3 Cisco Discovery Protocol neighbors - Cisco proprietary snmpDiscovery protocol - one of the most reliable methods for physical
            network topology snmpDiscovery. Supported by most of the Cisco devices but also by some others e.g HP Procurve switches. Note that HP is
            able to see Cisco but Cisco is not able to see HP. The good stuff of that protocol is that it provide information about neighbor
            platform and current node interface pointing to the neighbor.
            2.2.2.4 Local Link Discovery Protocol - IEEE standardized snmpDiscovery protocol. Pretty much same as CDP.Note that LLDP MIB is still
             a draft and therefore might cause some problems.
            2.2.2.5 SLASH30/31- This method use Interface IP address to calculate the IP address on the other side of the point to point link.
			2.2.2.6 Next Hops from routing Table 
			2.2.2.7  Next Hops from ipCidrRouteTable 
            2.3 Node Logical Data - section that represent data related to the current node unrelated to the physical setup of the node.
            Such might be routing protocol neighbors or node configuration or something else.
            2.3.1 OSPF Neighbors - Neighbors found by OSPF routing protocol.
            2.3.2 BGP Neighbors - Neighbors found by BGP routing protocol.
            -->
		<xsl:variable name="dot1dStpDesignatedRoot" select="//root/iso/org/dod/internet/mgmt/mib-2/dot1dBridge/dot1dStp/dot1dStpDesignatedRoot"/>
		<xsl:variable name="baseBridgeAddress" select="//root/iso/org/dod/internet/mgmt/mib-2/dot1dBridge/dot1dBase/dot1dBaseBridgeAddress"/>
		<!--Format hostname. For example if we have R1.test.com it will strip .test.com and will return only R1. This comes form the issue
        that there is a bug in CDP and on some Cisco routers we might see the neighbor hostname as R1.test.co so those hostname will mismatch
        from the one obtained by snmp or other snmpDiscovery methods.-->
		<xsl:variable name="sysName">
			<xsl:call-template name="return-hostname">
				<xsl:with-param name="hostname-unformated" select="//root/iso/org/dod/internet/mgmt/mib-2/system/sysName"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="hostname">
			<xsl:choose>
				<xsl:when test="$sysName!=''">
					<xsl:value-of select="$sysName"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:variable name="temp">
						<xsl:call-template name="return-hostname">
							<xsl:with-param name="hostname-unformated" select="SnmpForXslt:getName($deviceIPv4Address, $comm)"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:value-of select="$temp"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="sysDescr">
			<xsl:value-of select="//root/iso/org/dod/internet/mgmt/mib-2/system/sysDescr"/>
		</xsl:variable>
		<xsl:variable name="deviceType">
			<xsl:call-template name="determine-node-Type">
				<xsl:with-param name="sysDescr" select="$sysDescr"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="IPv6">
			<xsl:choose>
				<xsl:when test="$deviceType='CISCO'">
					<xsl:choose>
						<xsl:when test="//root/iso/org/dod/internet/private/enterprises/cisco/ciscoExperiment/ciscoIetfIpMIB/ciscoIetfIpMIBObjects/cIpv6/cIpv6Forwarding = '1'">YES</xsl:when>
						<xsl:otherwise>NO</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:choose>
						<xsl:when test="//root/iso/org/dod/internet/mgmt/mib-2/ipv6MIB/ipv6MIBObjects/ipv6Forwarding ='1'">YES</xsl:when>
						<xsl:otherwise>NO</xsl:otherwise>
					</xsl:choose>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="mplsVRF">
			<root1>
				<xsl:for-each select="//root/iso/org/dod/internet/experimental/mplsVpnMIB/mplsVpnObjects/mplsVpnConf/mplsVpnInterfaceConfTable/mplsVpnInterfaceConfEntry/instance">
					<xsl:variable name="test">
						<xsl:call-template name="substring-before-last">
							<xsl:with-param name="substring">.</xsl:with-param>
							<xsl:with-param name="value" select="substring-after(.,'.')"/>
						</xsl:call-template>
					</xsl:variable>
					<xsl:variable name="name">
						<xsl:for-each select="tokenize($test,'\.')">
							<xsl:value-of select="codepoints-to-string(xs:integer(.))"/>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="index">
						<xsl:call-template name="substring-after">
							<xsl:with-param name="substring">
								<xsl:call-template name="substring-before-last">
									<xsl:with-param name="value" select="."/>
									<xsl:with-param name="substring">.</xsl:with-param>
								</xsl:call-template>
							</xsl:with-param>
							<xsl:with-param name="value" select="."/>
						</xsl:call-template>
					</xsl:variable>
					<test>
						<name>
							<xsl:value-of select="$name"/>
						</name>
						<index>
							<xsl:value-of select="$index"/>
						</index>
					</test>
				</xsl:for-each>
			</root1>
		</xsl:variable>
		<object> <xsl:attribute name="name" select="$hostname"/><xsl:attribute name="type">DiscoveredDevice</xsl:attribute>
			<!-- Node specific parameters-->
			<parameters>
				<parameter>
                    <xsl:attribute name="name">Device State</xsl:attribute>
                    <xsl:attribute name="value"><xsl:value-of select="$dev_state"/></xsl:attribute>
                </parameter>
				<!--Parameter that contain node sysDescr e.g info about node OS and particular image-->
				<parameter>
					<name>sysDescr</name>
					<value>
						<xsl:value-of select="$sysDescr"/>
					</value>
				</parameter>
				<parameter>
					<name>Device Type</name>
					<value>
						<xsl:value-of select="$deviceType"/>
					</value>
				</parameter>
				<!--
                OID that represents exact node model for most of the devices. Once identified the OID shall be identified in the
                VENDOR-PRODUCTS-MIB.
                TODO: Currently only CISCO and Juniper are supported!!!
                -->
				<xsl:variable name="oid">
					<xsl:value-of select="//root/iso/org/dod/internet/mgmt/mib-2/system/sysObjectID"/>
				</xsl:variable>
				<parameter>
					<name>Device Model</name>
					<value>
						<xsl:choose>
							<xsl:when test="$deviceType='CISCO'">
								<xsl:value-of select="SnmpForXslt:getSymbolByOid('CISCO-PRODUCTS-MIB', $oid)"/>
							</xsl:when>
							<xsl:when test="$deviceType='JUNIPER'">
								<xsl:value-of select="SnmpForXslt:getSymbolByOid('JUNIPER-CHASSIS-DEFINES-MIB', $oid)"/>
							</xsl:when>
							<xsl:otherwise>Unknown</xsl:otherwise>
						</xsl:choose>
					</value>
				</parameter>
				<parameter>
					<name>Management IP Address</name>
					<value>
						<xsl:value-of select="$deviceIPv4Address"/>
					</value>
				</parameter>
				<parameter>
					<name>hopsToInitial</name>
					<value>
						<xsl:value-of select="$hopsToInitial"/>
					</value>
				</parameter>
				<parameter>
					<name>ipv6Forwarding</name>
					<value>
						<xsl:value-of select="$IPv6"/>
					</value>
				</parameter>
				<parameter>
					<name>Device Model Oid</name>
					<value>
						<xsl:value-of select="$oid"/>
					</value>
				</parameter>
				<parameter>
					<name>BGPLocalASInfo</name>
					<value>
						<xsl:value-of select="//root/iso/org/dod/internet/mgmt/mib-2/bgp/bgpLocalAs"/>
					</value>
				</parameter>
				<!--Those two addresses has intention to STP process. Some devices do not have STP enables so for those might contain
                some boolshit-->
				<parameter>
					<name>baseBridgeAddress</name>
					<value>
						<xsl:value-of select="$baseBridgeAddress"/>
					</value>
				</parameter>
				<parameter>
					<name>stpDesignatedRoot</name>
					<value>
						<xsl:value-of select="$dot1dStpDesignatedRoot"/>
					</value>
				</parameter>
				<parameter>
					<name>siteID</name>
					<value>
						<xsl:call-template name="substring-before">
							<xsl:with-param name="value" select="$hostname"/>
							<xsl:with-param name="substring">-</xsl:with-param>
						</xsl:call-template>
					</value>
				</parameter>
				<xsl:variable name="sysLocation" select="//root/iso/org/dod/internet/mgmt/mib-2/system/sysLocation"/>
				<parameter>
					<name>X Coordinate</name>
					<value>
						<xsl:call-template name="substring-before">
							<xsl:with-param name="value" select="$sysLocation"/>
							<xsl:with-param name="substring">,</xsl:with-param>
						</xsl:call-template>
					</value>
				</parameter>
				<parameter>
					<name>Y Coordinate</name>
					<value>
						<xsl:call-template name="substring-after">
							<xsl:with-param name="value" select="$sysLocation"/>
							<xsl:with-param name="substring">,</xsl:with-param>
						</xsl:call-template>
					</value>
				</parameter>
			</parameters>
			<!--Walk over the interface table.-->
			<xsl:for-each select="//root/iso/org/dod/internet/mgmt/mib-2/interfaces/ifTable/ifEntry">
				<xsl:variable name="ifIndex">
					<xsl:value-of select="ifIndex"/>
				</xsl:variable>
				<xsl:variable name="ifAdminStatus">
					<xsl:call-template name="adminStatus">
						<xsl:with-param name="status" select="ifAdminStatus"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="ifOperStatus">
					<xsl:call-template name="operStatus">
						<xsl:with-param name="status" select="ifOperStatus"/>
					</xsl:call-template>
				</xsl:variable>
				<xsl:variable name="ifDescr">
					<xsl:value-of select="ifDescr"/>
				</xsl:variable>
				<xsl:variable name="ifType">
					<xsl:value-of select="ifType"/>
				</xsl:variable>
				<!-- Neighbors and IP addresses are obtained only for the interfaces that are up and running.
                If the Admin status is UP and Operational is down the interface is marked as Cable CUT !-->
				<xsl:choose>
					<xsl:when test="$ifAdminStatus = 'UP' and $ifOperStatus ='UP'">
						<object>
							<name>
								<xsl:value-of select="$ifDescr"/>
							</name>
							<objectType>Discovery Interface</objectType>
							<parameters>
								<parameter>
									<name>ifIndex</name>
									<value>
										<xsl:value-of select="ifIndex"/>
									</value>
								</parameter>
								<parameter>
									<name>ifDescr</name>
									<value>
										<xsl:value-of select="$ifDescr"/>
									</value>
								</parameter>
								<parameter>
									<name>ifType</name>
									<value>
										<xsl:call-template name="determine-ifType">
											<xsl:with-param name="ifType" select="$ifType"/>
										</xsl:call-template>
									</value>
								</parameter>
								<parameter>
									<name>ifAdminStatus</name>
									<value>
										<xsl:value-of select="ifAdminStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifOperStatus</name>
									<value>
										<xsl:value-of select="ifOperStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifPhysAddress</name>
									<value>
										<xsl:value-of select="ifPhysAddress"/>
									</value>
								</parameter>
								<parameter>
									<name>CableCut</name>
									<value>NO</value>
								</parameter>
								<parameter>
									<name>vrfForwarding</name>
									<value>
										<xsl:value-of select="$mplsVRF/root1//test[substring-after(index,'.')= $ifIndex]/name"/>
									</value>
								</parameter>
							</parameters>
							<!--Check for  IPv4 IP addresses-->
                            <xsl:variable name="ipv4Addresses">
                                <ipv4>
							    <xsl:for-each select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipAddrTable/ipAddrEntry[ipAdEntIfIndex=$ifIndex]">
                                    <ipv4addr>
                                        <ipAdEntAddr><xsl:value-of select="ipAdEntAddr"/></ipAdEntAddr>
                                        <ipAdEntNetMask><xsl:value-of select="ipAdEntNetMask"/></ipAdEntNetMask>
                                    </ipv4addr>
                                </xsl:for-each>
                                </ipv4>
                            </xsl:variable>

                            <xsl:for-each select="$ipv4Addresses/ipv4/ipv4addr">
                                <xsl:variable name="ipAdEntAddr" select="ipAdEntAddr"/>
								<xsl:variable name="ipAdEntNetMask" select="ipAdEntNetMask"/>

								<xsl:if test="$ipAdEntAddr !=''">
									<object>
										<name>
											<xsl:value-of select="$ipAdEntAddr"/>/<xsl:value-of select="$ipAdEntNetMask"/>
										</name>
										<objectType>IPv4 Address</objectType>
										<parameters>
											<parameter>
												<name>IPv4Address</name>
												<value>
													<xsl:value-of select="$ipAdEntAddr"/>
												</value>
											</parameter>
											<parameter>
												<name>ipSubnetMask</name>
												<value>
													<xsl:value-of select="$ipAdEntNetMask"/>
												</value>
											</parameter>
											<parameter>
												<name>ipv4Subnet</name>
												<value>
													<xsl:call-template name="get-network-range">
														<xsl:with-param name="ip-address" select="$ipAdEntAddr"/>
														<xsl:with-param name="subnet-mask" select="$ipAdEntNetMask"/>
													</xsl:call-template>
												</value>
											</parameter>
										</parameters>
									</object>
								</xsl:if>
							</xsl:for-each>
							<!--Check for  IPv6 IP addresses-->
							<xsl:choose>
								<xsl:when test="$deviceType='CISCO'">
									<xsl:for-each select="/root/iso/org/dod/internet/private/enterprises/cisco/ciscoExperiment/ciscoIetfIpMIB/ciscoIetfIpMIBObjects/cIp/cIpAddressTable/cIpAddressEntry[cIpAddressIfIndex=$ifIndex]/instance">
										<xsl:variable name="instance" select="substring-after(.,'.')"/>
										<xsl:variable name="ipAdEntAddr">
											<xsl:for-each select="tokenize($instance,'\.')">
												<xsl:value-of select="functx:decimal-to-hex(xs:integer(.))"/>.</xsl:for-each>
										</xsl:variable>
										<xsl:variable name="ipv6AddrPfxLength" select="substring-after(substring-before(../cIpAddressPrefix,'.'),'.')"/>
										<xsl:variable name="ipv6AddrType" select="../cIpAddressType"/>
										<xsl:variable name="cIpAddressOrigin" select="../cIpAddressPrefix"/>
										<xsl:variable name="ipv6AddrAnycastFlag" select="../ipv6AddrAnycastFlag"/>
										<xsl:variable name="ipv6AddrStatus" select="../ipv6AddrStatus"/>
										<xsl:call-template name="IPv6">
											<xsl:with-param name="ipAdEntAddr" select="$ipAdEntAddr"/>
											<xsl:with-param name="ipv6AddrPfxLength" select="functx:substring-after-last-match($cIpAddressOrigin,'\.')"/>
											<xsl:with-param name="ipv6AddrType" select="$ipv6AddrType"/>
											<xsl:with-param name="ipv6AddrAnycastFlag" select="$ipv6AddrAnycastFlag"/>
											<xsl:with-param name="ipv6AddrStatus" select="$ipv6AddrStatus"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:when>
								<xsl:otherwise>
									<xsl:for-each select="//root/iso/org/dod/internet/mgmt/mib-2/ipv6MIB/ipv6MIBObjects/ipv6AddrTable/ipv6AddrEntry[index=$ifIndex]/instance">
										<xsl:variable name="instance" select="substring-after(.,'.')"/>
										<xsl:variable name="ipAdEntAddr">
											<xsl:for-each select="tokenize($instance,'\.')">
												<xsl:value-of select="functx:decimal-to-hex(xs:integer(.))"/>.</xsl:for-each>
										</xsl:variable>
										<!--<xsl:variable name="fr" select="()"/>-->
										<!--<xsl:variable name="to" select="(':')"/>-->
										<!--<xsl:variable name="ipAddr" select="functx:replace-multi($ipAdEntAddr,$fr,$to)" />-->
										<xsl:variable name="ipv6AddrPfxLength" select="../ipv6AddrPfxLength"/>
										<xsl:variable name="ipv6AddrType" select="../ipv6AddrType"/>
										<xsl:variable name="ipv6AddrAnycastFlag" select="../ipv6AddrAnycastFlag"/>
										<xsl:variable name="ipv6AddrStatus" select="../ipv6AddrStatus"/>
										<xsl:call-template name="IPv6">
											<xsl:with-param name="ipAdEntAddr" select="IPv6formatConvertor:IPv6Convertor($ipAdEntAddr)"/>
											<xsl:with-param name="ipv6AddrPfxLength" select="$ipv6AddrPfxLength"/>
											<xsl:with-param name="ipv6AddrType" select="$ipv6AddrType"/>
											<xsl:with-param name="ipv6AddrAnycastFlag" select="$ipv6AddrAnycastFlag"/>
											<xsl:with-param name="ipv6AddrStatus" select="$ipv6AddrStatus"/>
										</xsl:call-template>
									</xsl:for-each>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:variable name="interface-neighbors">
                                <xsl:for-each select="$ipv4Addresses/ipv4/ipv4addr">
                                    <xsl:variable name="ipAdEntAddr" select="ipAdEntAddr"/>
								    <xsl:variable name="ipAdEntNetMask" select="ipAdEntNetMask"/>
                                    <xsl:call-template name="SLASH30">
										<xsl:with-param name="ipAdEntNetMask" select="$ipAdEntNetMask"/>
										<xsl:with-param name="ipAdEntAddr" select="$ipAdEntAddr"/>
									</xsl:call-template>
									<xsl:call-template name="SLASH31">
										<xsl:with-param name="ipAdEntNetMask" select="$ipAdEntNetMask"/>
										<xsl:with-param name="ipAdEntAddr" select="$ipAdEntAddr"/>
									</xsl:call-template>
                                </xsl:for-each>
								<!--Check for NEXT-HOP neighbors-->
								<xsl:call-template name="nextHop">
									<xsl:with-param name="ifNextHops" select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipRouteTable/ipRouteEntry[ipRouteIfIndex=$ifIndex]/ipRouteNextHop"/>
									<xsl:with-param name="sysName" select="$sysName"/>
								</xsl:call-template>
								<!--Check for CIDR-NEXT-HOP neighbors-->
								<xsl:call-template name="cnextHop">
									<xsl:with-param name="ipCidrRouteTable" select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipForward/ipCidrRouteTable/ipCidrRouteEntry[ipCidrRouteIfIndex=$ifIndex]"/>
									<xsl:with-param name="sysName" select="$sysName"/>
								</xsl:call-template>
								<!--Check for ARP neighbors-->
								<xsl:call-template name="ARP">
									<xsl:with-param name="ipNetToMediaIfNeighbors" select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipNetToMediaTable/ipNetToMediaEntry[ipNetToMediaIfIndex = $ifIndex]"/>
									<xsl:with-param name="sysName" select="$sysName"/>
								</xsl:call-template>
								<!--Check for MAC neighbors-->
								<xsl:variable name="brdPort">
									<xsl:value-of select="//root/iso/org/dod/internet/mgmt/mib-2/dot1dBridge/dot1dBase/dot1dBasePortTable/dot1dBasePortEntry[dot1dBasePortIfIndex=$ifIndex]/dot1dBasePort"/>
								</xsl:variable>
								<xsl:for-each select="//root/iso/org/dod/internet/mgmt/mib-2/dot1dBridge/dot1dTp/dot1dTpFdbTable/dot1dTpFdbEntry[dot1dTpFdbPort=$brdPort]">
									<xsl:variable name="neighborMACAddress">
										<xsl:value-of select="dot1dTpFdbAddress"/>
									</xsl:variable>
									<xsl:variable name="neighborIPAddress">
										<xsl:value-of select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipNetToMediaTable/ipNetToMediaEntry[ipNetToMediaPhysAddress=$neighborMACAddress][1]/ipNetToMediaNetAddress"/>
									</xsl:variable>
									<xsl:call-template name="MAC">
										<xsl:with-param name="neighborMACAddress" select="dot1dTpFdbAddress"/>
										<xsl:with-param name="neighborIPAddress" select="//root/iso/org/dod/internet/mgmt/mib-2/ip/ipNetToMediaTable/ipNetToMediaEntry[ipNetToMediaPhysAddress=$neighborMACAddress][1]/ipNetToMediaNetAddress"/>
									</xsl:call-template>
								</xsl:for-each>
								<!--Check for CDP neighbors-->
								<xsl:call-template name="CDP">
									<xsl:with-param name="cdpIfNeighbors" select="exslt:node-set(//root/iso/org/dod/internet/private/enterprises/cisco/ciscoMgmt/ciscoCdpMIB/ciscoCdpMIBObjects/cdpCache/cdpCacheTable/cdpCacheEntry[index[@name='cdpCacheIfIndex'] = $ifIndex])"/>
								</xsl:call-template>
								<!--Check for LLDP neighbors-->
								<xsl:call-template name="LLDP">
									<xsl:with-param name="lldpIfNeighbors" select="//root/iso/std/iso8802/ieee802dot1/ieee802dot1mibs/lldpMIB/lldpObjects/lldpRemoteSystemsData/lldpRemTable/lldpRemEntry/index[@name = 'lldpRemLocalPortNum' and text()=$ifIndex]/../lldpRemSysName"/>
								</xsl:call-template>
								<!--Check for Spanning Tree neighbors-->
								<TEST>brdPort<xsl:value-of select="$brdPort"/>
								</TEST>
								<xsl:for-each select="//root/iso/org/dod/internet/mgmt/mib-2/dot1dBridge/dot1dStp/dot1dStpPortTable/dot1dStpPortEntry[dot1dStpPort=$brdPort]">
									<xsl:variable name="designatedBridge" select="dot1dStpPortDesignatedBridge"/>
									<xsl:choose>
										<xsl:when test="contains($designatedBridge,$baseBridgeAddress)">
											<STP>The other switch is the root <xsl:value-of select="$designatedBridge"/>|<xsl:value-of select="$baseBridgeAddress"/>
											</STP>
										</xsl:when>
										<xsl:otherwise>
											<STP>I am the root. The root is <xsl:value-of select="$baseBridgeAddress"/>|
                                            <xsl:value-of select="$designatedBridge"/>
											</STP>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:for-each>
							</xsl:variable>
							<!--xsl:copy-of select="$interface-neighbors"/-->
							<xsl:for-each select="distinct-values($interface-neighbors/object/name)">
								<object>
									<xsl:variable name="name" select="."/>
									<name>
										<xsl:value-of select="$name"/>
									</name>
									<objectType>Discovered Neighbor</objectType>
									<parameters>
										<xsl:variable name="Reachable">
											<xsl:for-each select="$interface-neighbors/object[name=$name]/parameters/parameter[name='Reachable']/value">
												<xsl:value-of select="."/>
											</xsl:for-each>
										</xsl:variable>
										<Reachable>
											<xsl:copy-of select="$Reachable"/>
										</Reachable>
										<xsl:choose>
											<xsl:when test="contains($Reachable,'YES')">
												<parameter>
													<name>Reachable</name>
													<value>YES</value>
												</parameter>
												<parameter>
													<name>SNMP Community</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Reachable' and value='YES']/../parameter[name='SNMP Community']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Discovery Method</name>
													<value>
														<xsl:for-each select="$interface-neighbors/object[name=$name]/parameters/parameter[name='Discovery Method']/value">
															<xsl:value-of select="."/>,</xsl:for-each>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor Port</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor Port']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor IP Address</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Reachable' and value='YES']/../parameter[name='Neighbor IP Address']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor hostname</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor hostname']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor Device Type</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor Device Type']/value)"/>
													</value>
												</parameter>
											</xsl:when>
											<xsl:otherwise>
												<parameter>
													<name>Reachable</name>
													<value>NO</value>
												</parameter>
												<parameter>
													<name>SNMP Community</name>
													<value/>
												</parameter>
												<parameter>
													<name>Discovery Method</name>
													<value>
														<xsl:for-each select="$interface-neighbors/object[name=$name]/parameters/parameter[name='Discovery Method']/value">
															<xsl:value-of select="."/>,</xsl:for-each>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor Port</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor Port']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor Platform</name>
													<value>
														<xsl:value-of select="$interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor Platform']/value"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor IP Address</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor IP Address']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor hostname</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor hostname']/value)"/>
													</value>
												</parameter>
												<parameter>
													<name>Neighbor Device Type</name>
													<value>
														<xsl:value-of select="distinct-values($interface-neighbors/object[name=$name]/parameters/parameter[name='Neighbor Device Type']/value)"/>
													</value>
												</parameter>
											</xsl:otherwise>
										</xsl:choose>
									</parameters>
								</object>
							</xsl:for-each>
						</object>
					</xsl:when>
					<xsl:when test="$ifAdminStatus = 'UP' and $ifOperStatus ='DOWN'">
						<object>
							<name>
								<xsl:value-of select="$ifDescr"/>
							</name>
							<objectType>Discovery Interface</objectType>
							<parameters>
								<parameter>
									<name>ifIndex</name>
									<value>
										<xsl:value-of select="ifIndex"/>
									</value>
								</parameter>
								<parameter>
									<name>ifDescr</name>
									<value>
										<xsl:value-of select="ifDescr"/>
									</value>
								</parameter>
								<parameter>
									<name>ifType</name>
									<value>
										<xsl:call-template name="determine-ifType">
											<xsl:with-param name="ifType" select="$ifType"/>
										</xsl:call-template>
									</value>
								</parameter>
								<parameter>
									<name>ifAdminStatus</name>
									<value>
										<xsl:value-of select="$ifAdminStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifOperStatus</name>
									<value>
										<xsl:value-of select="$ifOperStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifPhysAddress</name>
									<value>
										<xsl:value-of select="ifPhysAddress"/>
									</value>
								</parameter>
								<parameter>
									<name>CableCut</name>
									<value>YES</value>
								</parameter>
								<parameter>
									<name>vrfForwarding</name>
									<value>
										<xsl:value-of select="$mplsVRF/root1//test[substring-after(index,'.')= $ifIndex]/name"/>
									</value>
								</parameter>
							</parameters>
						</object>
					</xsl:when>
					<xsl:when test="$ifAdminStatus = 'DOWN' and $ifOperStatus ='DOWN'">
						<object>
							<name>
								<xsl:value-of select="$ifDescr"/>
							</name>
							<objectType>Discovery Interface</objectType>
							<parameters>
								<parameter>
									<name>ifIndex</name>
									<value>
										<xsl:value-of select="ifIndex"/>
									</value>
								</parameter>
								<parameter>
									<name>ifDescr</name>
									<value>
										<xsl:value-of select="ifDescr"/>
									</value>
								</parameter>
								<parameter>
									<name>ifType</name>
									<value>
										<xsl:call-template name="determine-ifType">
											<xsl:with-param name="ifType" select="$ifType"/>
										</xsl:call-template>
									</value>
								</parameter>
								<parameter>
									<name>ifAdminStatus</name>
									<value>
										<xsl:value-of select="$ifAdminStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifOperStatus</name>
									<value>
										<xsl:value-of select="$ifOperStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifPhysAddress</name>
									<value>
										<xsl:value-of select="ifPhysAddress"/>
									</value>
								</parameter>
								<parameter>
									<name>CableCut</name>
									<value>NO</value>
								</parameter>
								<parameter>
									<name>vrfForwarding</name>
									<value>
										<xsl:value-of select="$mplsVRF/root1//test[substring-after(index,'.')= $ifIndex]/name"/>
									</value>
								</parameter>
							</parameters>
						</object>
					</xsl:when>
					<xsl:otherwise>
						<object>
							<name>
								<xsl:value-of select="$ifDescr"/>
							</name>
							<objectType>Discovery Interface</objectType>
							<parameters>
								<parameter>
									<name>ifIndex</name>
									<value>
										<xsl:value-of select="ifIndex"/>
									</value>
								</parameter>
								<parameter>
									<name>ifDescr</name>
									<value>
										<xsl:value-of select="ifDescr"/>
									</value>
								</parameter>
								<parameter>
									<name>ifType</name>
									<value>
										<xsl:call-template name="determine-ifType">
											<xsl:with-param name="ifType" select="$ifType"/>
										</xsl:call-template>
									</value>
								</parameter>
								<parameter>
									<name>ifAdminStatus</name>
									<value>
										<xsl:value-of select="$ifAdminStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifOperStatus</name>
									<value>
										<xsl:value-of select="$ifOperStatus"/>
									</value>
								</parameter>
								<parameter>
									<name>ifPhysAddress</name>
									<value>
										<xsl:value-of select="ifPhysAddress"/>
									</value>
								</parameter>
								<parameter>
									<name>CableCut</name>
									<value>UNKNOWN</value>
								</parameter>
								<parameter>
									<name>vrfForwarding</name>
									<value>
										<xsl:value-of select="$mplsVRF/root1//test[substring-after(index,'.')= $ifIndex]/name"/>
									</value>
								</parameter>
							</parameters>
						</object>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
			<object>
				<name>DeviceLogicalData</name>
				<objectType>DeviceLogicalData</objectType>
				<parameters/>
				<xsl:for-each select="//org/dod/internet/mgmt/mib-2/ospf/ospfNbrTable/ospfNbrEntry">
					<xsl:call-template name="OSPF">
						<xsl:with-param name="ospfNbr" select="."/>
					</xsl:call-template>
				</xsl:for-each>
				<xsl:for-each select="//org/dod/internet/mgmt/mib-2/bgp/bgpPeerTable/bgpPeerEntry">
					<xsl:call-template name="BGP">
						<xsl:with-param name="bgpPeer" select="."/>
					</xsl:call-template>
				</xsl:for-each>
			</object>
			<object>
				<objectType>mplsL3VPNs</objectType>
				<parameters/>
				<xsl:for-each select="//org/dod/internet/experimental/mplsVpnMIB/mplsVpnObjects/mplsVpnConf/mplsVpnVrfTable/mplsVpnVrfEntry">
					<xsl:variable name="RD" select="mplsVpnVrfRouteDistinguisher"/>
					<xsl:variable name="instance" select="instance"/>
					<xsl:variable name="rd_instance" select="substring-after($instance,'.')"/>
					<object>
						<name>
							<xsl:value-of select="$RD"/>
						</name>
						<objectType>mplsL3VPN</objectType>
						<parameters>
							<parameter>
								<name>vrfName</name>
								<value>
									<xsl:for-each select="tokenize($rd_instance,'\.')">
										<xsl:value-of select="codepoints-to-string(xs:integer(.))"/>
										<!--xsl:value-of select="."/-->
									</xsl:for-each>
								</value>
							</parameter>
						</parameters>
						<xsl:for-each select="//org/dod/internet/experimental/mplsVpnMIB/mplsVpnObjects/mplsVpnConf/mplsVpnVrfRouteTargetTable/mplsVpnVrfRouteTargetEntry[contains(instance,$rd_instance)]">
							<xsl:variable name="rt" select="mplsVpnVrfRouteTarget"/>
							<object>
								<name>
									<xsl:value-of select="$rt"/>
								</name>
								<objectType>RT</objectType>
								<parameters>
									<parameter>
										<name>Type</name>
										<value>
											<xsl:value-of select="codepoints-to-string(xs:integer(index[@name='mplsVpnVrfRouteTargetType']))"/>
										</value>
									</parameter>
								</parameters>
							</object>
						</xsl:for-each>
					</object>
				</xsl:for-each>
			</object>
		</object>
		<!--</network> -->
	</xsl:template>
</xsl:stylesheet>
