######################################################################
#
#				BlackMeteo
#
#Afiseaza starea vremii atat pentru ziua curenta 
#cat si pentru urmatoarele 3 zile.
#
#Prognoza este valabila pentru toate orasele din lume.
#
#Activare : .set +meteo (BlackTools) | .chanset +meteo (DCC)
#
#!meteo oras / oras,regiune
#
#					BLaCkShaDoW ProductionS
#					   WwW.TclScriptS.Net
######################################################################

#Aici setezi cine poate folosii comanda !meteo (-|- pt toata lumea)

set meteo_flags "-|-"

#Protectia anti-flood (actionari:secunde)

set meteo_flood "3:5"


######################################################################
#
#                            The End
#
#
######################################################################

bind pub $meteo_flags !meteo arata:meteo

setudef flag meteo

proc arata:meteo {nick host hand chan arg} {
	global count meteo_flood

	set city [string tolower [lrange [split $arg] 0 end]]
	set li 0
	set number [scan $meteo_flood %\[^:\]]
	set timer [scan $meteo_flood %*\[^:\]:%s]

if {![channel get $chan meteo]} {
	return
}


if {[info exists count(mflood:$host:$chan)]} {
if {$count(mflood:$host:$chan) == "$number"} {
	puthelp "NOTICE $nick :Am activat protectia anti-flood.Te rog asteapta un minut."
	return
	}
}
	
foreach tmr [utimers] {
if {[string match "*count(mflood:$host:$chan)*" [join [lindex $tmr 1]]]} {
	killutimer [lindex $tmr 2]
}

}
if {![info exists count(mflood:$host:$chan)]} { 
	set count(mflood:$host:$chan) 0 
}

	incr count(mflood:$host:$chan)
	utimer 60 [list unset count(mflood:$host:$chan)]


if {[llength $city] > 1} {

foreach word $city {

if {[info exists thecity]} {

	set old_city $thecity%20

	set thecity $old_city$word
	
} else { set thecity $word }
 
}


} else { set thecity "$city" }

	set ipq [http::config -useragent "lynx"]
	set ipq [http::geturl "http://www.local-weather-forecast.info/?city=$thecity" -timeout 10000]
	set getipq [http::data $ipq]
	set output [split $getipq "\n"]
	http::cleanup $ipq

#< check if exists city
	set output [split $getipq "\n"]
	set current_line ""
foreach line $output {
if {[string match -nocase "*cityCurrent*" $line]} {
	set current_line $line
		}
	}
	set current_line [join [string map {"<div class=\"cityCurrent\">" ""
				 "</div>" ""
				 		} $current_line]]
if {$current_line == ""} {
	putquick "PRIVMSG $chan :Nu am gasit informatii meteo despre orasul \002$thecity\002."
	return
}
#<


#< current day weather.

	regexp {div class="cityCurrent">(.*)} $getipq get_oras
	regsub -all "div class=\"cityCurrent\">" $get_oras "" get_oras
	regsub -all "</div>" $get_oras "" get_oras

	regexp {<div class="tempCurrent">(.*)} $getipq get_temp
	regsub -all "<div class=\"tempCurrent\">" $get_temp "" get_temp
	regsub -all "</div>" $get_temp "" get_temp
	

	regexp {<div class="humidityCurrent">(.*)} $getipq get_humidity
	regsub -all "<div class=\"humidityCurrent\">" $get_humidity "" get_humidity
	regsub -all "</div><br />" $get_humidity "" get_humidity

	regexp {<div class="windCurrent">(.*)} $getipq get_wind
	regsub -all "<div class=\"windCurrent\">" $get_wind "" get_wind
	regsub -all "</div>" $get_wind "" get_wind

	set get_temp [concat [lindex $get_temp 0]]

if {[lindex $get_wind 2] == "<div"} {
	set cardinal ""
} else {
	set cardinal [lindex $get_wind 2]
}

	putserv "NOTICE $nick :Vremea curenta pentru \002$get_oras\002"
	putserv "NOTICE $nick :Temperatura : \002[encoding convertfrom utf-8 [temp_show $get_temp]]\002 , Umiditate : \002[lindex $get_humidity 0]\002 , Vant : \002[lrange $get_wind 0 1] $cardinal\002"


#< three days forecast
first:day $output $chan $nick
#>

}

proc first:day {output chan nick} {
	
	set count 0
	set found_line 0

foreach line $output {
	set count [expr $count + 1]
if {[string match -nocase "*dayForecast*" $line]} {
	set day $line
	set found_line $count
	break
		}
	}
	set get_day [join [string map {"<div class=\"dayForecast\">" ""
				 "</div><br />" ""
				 		} $day]]
	set min_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 2]]]]]
	set max_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 5]]]]]
	set condition [join [temp_show [lindex $output [expr $found_line + 8]]]]

#<
	set three_days "\[\002[meteo_days $get_day]\002\] Temperaturi $min_temp/$max_temp , Conditii : [get_condition $condition]"
#>

second:day $output $chan $get_day $three_days $nick

}

proc second:day {output chan last_day three_days nick} {
	set current_day $last_day
	set count 0
	set found_line 0
foreach line $output {
	set count [expr $count + 1]
if {[string match -nocase "*dayForecast*" $line] && ![string match -nocase "*$last_day*" $line]} {
	set day $line
	set found_line $count
	break
		}
	}
	set get_day [join [string map {"<div class=\"dayForecast\">" ""
				 "</div><br />" ""
				 		} $day]]
	set min_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 2]]]]]
	set max_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 5]]]]]
	set condition [join [temp_show [lindex $output [expr $found_line + 8]]]]

#<
	set three_days "$three_days \[\002[meteo_days $get_day]\002\] Temperaturi $min_temp/$max_temp , Conditii : [get_condition $condition]"
#>

third:day $output $chan $get_day $current_day $three_days $nick

}

proc third:day {output chan last_day current_day three_days nick} {
	set count 0
	set found_line 0
foreach line $output {
	set count [expr $count + 1]
if {[string match -nocase "*dayForecast*" $line] && ![string match -nocase "*$last_day*" $line] && ![string match -nocase "*$current_day*" $line]} {
	set day $line
	set found_line $count
	break
		}
	}
	set get_day [join [string map {"<div class=\"dayForecast\">" ""
				 "</div><br />" ""
				 		} $day]]
	set min_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 2]]]]]
	set max_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 5]]]]]
	set condition [join [temp_show [lindex $output [expr $found_line + 8]]]]

#<
	set three_days "$three_days \[\002[meteo_days $get_day]\002\] Temperaturi $min_temp/$max_temp , Conditii : [get_condition $condition]"
#>

fourth:day $output $chan $three_days $nick
}


proc fourth:day {output chan three_days nick} {
	set count 0
	set found_line 0
foreach line $output {
	set count [expr $count + 1]
if {[string match -nocase "*dayForecast*" $line]} {
	set day $line
	set found_line $count
		}
	}
	set get_day [join [string map {"<div class=\"dayForecast\">" ""
				 "</div><br />" ""
				 		} $day]]
	set min_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 2]]]]]
	set max_temp [encoding convertfrom utf-8 [join [temp_show [lindex $output [expr $found_line + 5]]]]]
	set condition [join [temp_show [lindex $output [expr $found_line + 8]]]]

#<
	set three_days "$three_days \[\002[meteo_days $get_day]\002\] Temperaturi $min_temp/$max_temp , Conditii : [get_condition $condition]"
#>

	putserv "NOTICE $nick :$three_days"
}


proc temp_show {temp} {
	set temp [string map {"&deg;" "°C"
			      "<div class=\"tempForecast\">" ""	
                              "</div><br />" ""
			      "<div class=\"condForecast\">" ""  
			      "</div>" "" 
			     			} $temp]
	return $temp
}

proc get_condition {condition} {
	switch [string tolower $condition] {
	"clear sky" {
	set condition "Cer senin"
		}
	"few clouds" {
	set condition "Cativa nori"
		}
	"moderate rain" {
	set condition "Ploaie moderata"
		}
	"overcast clouds" {
	set condition "Cer acoperit de nori"
		}
	"heavy intensity rain" {
	set condition "Ploaie deasa"
		}
	"light rain" {
	set condition "Ploaie usoara"
		}
	"broken clouds" {
	set condition "Nori rupti"
		}
	"scattered clouds" {
	set condition "Nori imprastiati"		
		}
	}
	return $condition
}


proc meteo_days {day} {
	switch [string tolower $day] {

	monday {
	set current_day "Luni"
}
	tuesday {
	set current_day "Marti"
}
	wednesday {
	set current_day "Miercuri"
}
	thursday {
	set current_day "Joi"
}
	friday {
	set current_day "Vineri"
}
	saturday {
	set current_day "Sambata"
}
	sunday {
	set current_day "Duminica"
		}	
	}
}

putlog "BlackMeteo 1.0 by BLaCkShaDoW Loaded."

