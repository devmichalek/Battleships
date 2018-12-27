
namespace eval Supp {}

proc MakeColorForValue {value} {
	if {$value == "S"} {
		puts -nonewline "\033\[32m"
	} elseif {$value == "X" || $value == "K"} {
		puts -nonewline "\033\[31m"
	} else {
		puts -nonewline "\033\[33m"
	}
	puts -nonewline $value
	puts -nonewline "\033\[0m"
}

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

	for {set i 0} {$i < $max} {incr i} {

		# 0...9
		puts -nonewline $i
		puts -nonewline " "

		# data
		for {set j 0} {$j < $max} {incr j} {
			MakeColorForValue [lindex $a $i $j]
			puts -nonewline " "
		}

		# gap
		puts -nonewline "  |   "

		# 0...9
		puts -nonewline $i
		puts -nonewline " "

		# data
		for {set j 0} {$j < $max} {incr j} {
			MakeColorForValue [lindex $b $i $j]
			puts -nonewline " "
		}

		puts ""
	}
}

proc Supp::PrintLabel {actionstr} {
	if {$Sets::CharMode} {
		puts "\nS - intact part of ship"
		puts "X - drown part of ship"
		puts "0 - mishit part of ship or predicted empty area"
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