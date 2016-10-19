#####################################################
#
#	Youtube Title 1.5
#
#La postarea unui link youtube eggdropul va afisa
#titlul videoclipului
#
#.chanset #canal +ytitle | .set +ytitle
#
#Este nevoie de tcl-ul http.tcl sa fie incarcat inainte
#de YoutubeTitle.tcl
#			BLaCkShaDoW ProductionS
#####################################################



bind pubm - * check:youtube
bind ctcp - ACTION check:youtube:me

setudef flag ytitle
package require http


proc check:youtube {nick host hand chan arg} {
	
	set arg [split $arg]


if {![channel get $chan ytitle]} {

	return 0
}

foreach word $arg {

	set youtube_link "$word"


if {[string match -nocase "*youtube.com/watch*" $youtube_link] || [string match -nocase "*youtu.be*" $youtube_link]} {

	youtube:get:title $youtube_link $nick $chan

		}
	}
}


proc youtube:get:title {link nick chan} {

	set ipq [http::config -useragent "lynx"]
	set ipq [http::geturl "http://youtubesongname.000webhostapp.com/index.php?link=$link" -timeout 10000]
	set getipq [http::data $ipq]
	set output [split $getipq "\n"]
	http::cleanup $ipq

set title [string map { "&amp;" "&"
			"&#39;" "'"
			"&quot;" "\""
	
} [lindex $output 0]]


	puthelp "PRIVMSG $chan :\002\0031,0You\0030,4Tube\003\002 : $title"
}

proc check:youtube:me {nick host hand chan keyword arg} {
check:youtube $nick $host $hand $chan $arg
}

putlog "Youtube Title 1.4 by BLaCkShaDoW Loaded"
