############################################################################
#
#BlackIP 1.4
#
#Afiseaza informatii despre ip-uri | Shows information about IPS
#
#!ip <ip> / <host> / <nickname>
#!ip -version ( shows the version )
#
#To activate .chanset #channel +ip | BlackTools : .set +ip
#
#                                             BLaCkShaDoW ProductionS
###########################################################################

#Seteaza aici ce flaguri sa poata folosii comanda.

set ip_flags "-|-"

############################################################################

bind pub $ip_flags !ip black:ip:check

package require http
setudef flag ip

proc black:ip:check {nick host hand chan arg} {
	
	set ip [lindex [split $arg] 0]
	set ::chan $chan
	set ::ip $ip

if {![channel get $chan ip]} {

return 0

}

if {[string equal -nocase "-version" $ip]} {
	puthelp "NOTICE $nick :\002BlackIp 1.4\002 by \002BLaCkShaDoW\002. For more information -> \002WwW.TclScripts.Net\002"
	return
}
	
if {$ip == ""} {

	puthelp "NOTICE $nick :Use !ip <ip> / <host> / <nick>"

return 0

}

if {![string match -nocase "*.*" $ip]} {
	
	putquick "WHOIS $ip $ip"
	bind raw - 401 no:nick
	bind raw - 311 check:for:nick

return 0

}

if {![regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $ip]} {

dnslookup $ip solve:ip $chan

return 0
}

check:ip $ip $chan 0 none
}

proc no:nick { from keyword arguments } {

	set chan $::chan
	set ip $::ip
	
	puthelp "PRIVMSG $chan :\[\002$ip\002]\ is not Online."

unbind raw - 401 no:nick
}

proc solve:ip {ip host receive chan} {
if {$receive == "1"} {
	check:ip $ip $chan 2 $host
	} else {
	puthelp "PRIVMSG $chan :Couldn't solve $host"
	}
}

proc solve:nick:ip {ip host receive chan nick} {
if {$receive == "1"} {
	check:ip $ip $chan 3 "$host $nick"
	} else {
	puthelp "PRIVMSG $chan :\[\002$nick\002\] Couldn't solve \002$host\002"
	}
}

proc check:for:nick { from keyword arguments } {

	set chan $::chan
	set getip [lindex [split $arguments] 3]
	set getnick [lindex [split $arguments] 1]

if {![regexp {[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$} $getip]} {

dnslookup $getip solve:nick:ip $chan $getnick

	unbind raw - 311 check:for:nick

return 0
}

check:ip $getip $chan 1 $getnick

	unbind raw - 311 check:for:nick
}


proc check:ip {ip chan status arg} {
global botnick
	set ipq [http::config -useragent "lynx"]
	set arg [split $arg]
	set counter 0
	set isp "NONE"
	set location "NONE"
	set ipq [http::geturl "http://www.ip-adress.com/whois/$ip" -timeout 30000]
	set getipq [http::data $ipq]
	set output [split $getipq "\n"]
putlog "$getipq"
foreach line $output {
set counter [expr $counter + 1]
if {[string match -nocase "*Location:*" $line]} {
	set location [lindex $output $counter]
}

set location [string map {
"<br class=\"ext\">" ""
"&amp;" "&"
} $location]

if {[string match -nocase "*ISP:*" $line]} {
	set isp [lindex $output $counter]
}

set isp [string map {
"<br class=\"ext\">" ""
"&amp;" "&"
} $isp]

}

if {$status != 0} {

if {$status == "1"} {
	putserv "PRIVMSG $chan :\[NickName: \002$arg\002]"
	putserv "PRIVMSG $chan :Ip: \002$ip\002 | Location: \002$location\002 | ISP: \002$isp\002"	
} 
if {$status == "2"} { 
	putserv "PRIVMSG $chan :\[Host: \002$arg\002\] Solved To \[\002$ip\002\]"
	putserv "PRIVMSG $chan :Ip: \002$ip\002 | Location: \002$location\002 | ISP: \002$isp\002"
}

if {$status == "3"} { 
	putserv "PRIVMSG $chan :\[NickName: \002[lindex $arg 1]\002 - Host: \002[lindex $arg 0]\002\] Solved To \[\002$ip\002\]"
	putserv "PRIVMSG $chan :Ip: \002$ip\002 | Location: \002$location\002 | ISP: \002$isp\002"
}

} else {
	putserv "PRIVMSG $chan :\[ip: \002$ip\002\]"
	putserv "PRIVMSG $chan :Ip: \002$ip\002 | Location: \002$location\002 | ISP: \002$isp\002"
	}
}


putlog "BlackIP 1.4 by BLaCkShaDoW Loaded"
