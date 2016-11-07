#####################################################################
#
#Horoscop En 1.2 TCL 
#
#Activate : .chanset +horoscope | .set +horoscope
#
# !horoscope <sign> - see the horoscop
# !horoscope version - script version
#
#				BLaCkShaDoW Production
#####################################################################


#Here you set the flags for !horoscop (-|- for everyone)

set horoscop_flags "-|-"

#Antiflood protection (actions:seconds)

set horoscop_flood "3:5"


######################################################################
#
#                            The End
#
#
######################################################################

bind pub $horoscop_flags !horoscope arata:horoscop
setudef flag horoscope

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
	puthelp "NOTICE $nick :Script version 4Horoscop 1.2 created by BLaCkShaDoW. For more information 4#Tcl-Help or 4WwW.TclScripts.Net"
	return 0
}

if {[info exists count(hflood:$host:$chan)]} {
if {$count(hflood:$host:$chan) == "$number"} {
puthelp "NOTICE $nick :Flood protection activated. Please hold 1 minute."
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


if {(![regexp -nocase -- {(#[0-9]+|aries|taurus|gemini|cancer|leo|virgo|libra|scorpio|sagittarius|capricorn|aquarius|pisces)} $alege_zodie])} {

	puthelp "NOTICE $nick :Use !horoscop <sign>"
	return
}

	set ipq [http::config -useragent "lynx"]
	set ipq [http::geturl "http://www.astrology.com/horoscope/daily/$alege_zodie.html"]
	set getipq [http::data $ipq] 
	set output [split $getipq "\n"]

if {[string match -nocase "*404*" $getipq]} {
	puthelp "PRIVMSG $chan :Found nothing."
	return
}

regexp {<div class=\"page-horoscope-date-container\"><span class=\"page-horoscope-date-font\">(.*)} $getipq get_date
	regsub -all "<div class=\"page-horoscope-date-container\"><span class=\"page-horoscope-date-font\">" $get_date "" get_date
	regsub -all "</span></div>" $get_date "" get_date
putserv "PRIVMSG $chan :Daily horoscope for $get_date"

foreach line $output {
if {[string match -nocase "*page-horoscope-text*" $line]} {
	set get_horoscop $line
	}
}
	set get_horoscop [concat [string map {
			"<div class=\"page-horoscope-text\" style=\"height:145px;\">" ""
			"</div>" ""
			} $get_horoscop]]

foreach txt [wordwrap [join [split $get_horoscop] " "] 300] {
	puthelp "PRIVMSG $chan :(4[string toupper $alege_zodie]) $txt"
	}
}


#not mine :P
proc wordwrap {str {len 100} {splitChr { }}} { 
   set out [set cur {}]; set i 0 
   foreach word [split [set str][unset str] $splitChr] { 
     if {[incr i [string len $word]]>$len} { 
         lappend out [join $cur $splitChr] 
         set cur [list $word] 
         set i [string len $word] 
      } { 
         lappend cur $word 
      } 
      incr i 
   } 
   lappend out [join $cur $splitChr] 
}



putlog "English Horoscop 1.2 TCL by BLaCkShaDoW Loaded"

