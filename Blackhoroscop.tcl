#####################################################################
#
#Horoscop 1.3 TCL 
#
#Activare : .chanset +horoscop | .set +horoscop
#
# !horoscop <zodie> - aflii zodiacul zodiei tale
# !horoscop version - aflii versiunea scriptului
#
#				BLaCkShaDoW ProductionS
#####################################################################


#Aici setezi cine poate folosii comanda !horoscop (-|- pt toata lumea)

set horoscop_flags "-|-"

#Protectia anti-flood (actionari:secunde)

set horoscop_flood "3:5"


######################################################################
#
#                            The End
#
#
######################################################################

bind pub $horoscop_flags !horoscop arata:horoscop
setudef flag horoscop

proc arata:horoscop {nick host hand chan arg} {
	global count horoscop_flood
	set alege_zodie [string tolower [lindex [split $arg] 0]]
	set li 0
	set number [scan $horoscop_flood %\[^:\]]
	set timer [scan $horoscop_flood %*\[^:\]:%s]
	
if {![channel get $chan horoscop]} {

	return 0
	
}

if {[string equal -nocase "version" $alege_zodie]} {
	puthelp "NOTICE $nick :Versiune script 4Horoscop 1.3 creat de BLaCkShaDoW. Pentru mai multe informatii 4#Tcl-Help sau 4WwW.TclScripts.Net"
	return 0
}

if {[info exists count(hflood:$host:$chan)]} {
if {$count(hflood:$host:$chan) == "$number"} {
puthelp "NOTICE $nick :Am activat protectia anti-flood.Te rog asteapta un minut."
return 0
}
}
	
foreach tmr [utimers] {
if {[string match "*count(hflood:$host:$chan)*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
}

}
if {![info exists count(hflood:$host:$chan)]} { 
	set count(hflood:$host:$chan) 0 
}

	incr count(hflood:$host:$chan)
	utimer 60 [list unset count(hflood:$host:$chan)]


if {(![regexp -nocase -- {(#[0-9]+|berbec|taur|capricorn|leu|scorpion|pesti|sagetator|varsator|gemeni|fecioara|balanta|rac)} $alege_zodie])} {

	puthelp "NOTICE $nick :Use !horoscop <zodie>"

	return 0
}

	set ipq [http::config -useragent "lynx"]
	set ipq [http::geturl "http://www.eastrolog.ro/horoscop-zilnic/horoscop-$alege_zodie.php"]
	set getipq [http::data $ipq] 
	set output [split $getipq "\n"]
	set text ""

if {[string match -nocase "*404*" $getipq]} {

	puthelp "NOTICE $nick :Nu am gasit nimic."
	
	return 0

}

putserv "NOTICE $nick :Horoscopul zilei pentru 4[string toupper $alege_zodie]"

set line_counter -1
set true 0

foreach line $output {
set line_counter [expr $line_counter + 1]
if {[string match -nocase "<p>*" $line]} {
	set true $line_counter
	}
}
	set text "[string map { "<br>" "" "<p>" ""} [lindex $output $true]]"
while {$line_counter > -1} {
	set true [expr $true + 1]
if {![string match -nocase "*</p>*" [lindex $output $true]]} {
	set line [string map { "<br>" "" "<p>" ""} [lindex $output $true]]
if {[string length $line] > 1} {
	set text "$text $line"
				}
		} else {
		break;
		}
	}
if {$text != ""} {
	putserv "NOTICE $nick :$text"
	}
}

putlog "Horoscop 1.3 TCL by BLaCkShaDoW Loaded"

