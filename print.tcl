
namespace eval Supp {}

proc Supp::PrintTitle {} {
	puts "MINE\t\t\t    ENEMY\n"
}

proc Supp::PrintDouble {a b max} {

	# ". A B C D E F G H I J...  |  . A B C D E F G H I J..."
	set add 65
	set str ". "
	for {set i $add} {$i < $max + $add} {incr i} {
		append str "[format %c $i $i] "
	}
	append str "  |   . "
	for {set i $add} {$i < $max + $add} {incr i} {
		append str "[format %c $i $i] "
	}
	puts $str
	set str ""

	for {set i 0} {$i < $max} {incr i} {

		# 0...9
		append str $i
		append str " "

		# data
		for {set j 0} {$j < $max} {incr j} {
			append str [lindex $a $i $j]
			append str " "
		}

		# gap
		append str "  |   "

		# 0...9
		append str $i
		append str " "

		# data
		for {set j 0} {$j < $max} {incr j} {
			append str [lindex $b $i $j]
			append str " "
		}

		puts $str
		set str ""
	}
}

proc Supp::PrintLabel {actionstr} {
	if {$Sets::CharMode} {
		puts "\nS - intact part of ship"
		puts "X - drown part of ship"
		puts "0 - mishit part of ship"
	}

	if {$Sets::ActionMode} {
		puts "\nCurrent Action: $actionstr"
	}
}

proc Supp::Print {a b max actionstr} {
	# Refreshing console window.
	if {!$Sets::DebugMode} {eval exec >&@stdout <@stdin [auto_execok cls]}

	PrintTitle
	PrintDouble $a $b $max
	PrintLabel $actionstr
}