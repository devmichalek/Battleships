namespace eval Sets {
	set MOVE_WAITING 0
	set MOVE_ATTACKING 1

	set CurrentMove $MOVE_WAITING
	set TimeForMove 400
	set DebugMode 0
	set ActionMode 1
	set CharMode 1
}

proc Sets::GetBooleanValue {str} {
	if {$str == "1" || $str == "true"} {return 1}
	return 0
}

proc Sets::Load {} {
	set file [open "settings.settings" r]
	set data [read $file]
	close $file

	# Debugging
	set str "\nSettings:\n"

	set size [llength $data]
	for {set i 0} {$i < $size} {incr i} {
		if {[string first "@" [lindex $data $i]] == 0} {

			set var [lindex $data $i]
			incr i
			set val [lindex $data $i]

			# Debugging
			append str "$var=$val\n"

			if {$var == "@FirstMove"} {
				if {[GetBooleanValue $val]} {
					set Sets::CurrentMove $Sets::MOVE_ATTACKING
				}
			} elseif {$var == "@TimeForMove"} {
				set Sets::TimeForMove $val
			} elseif {$var == "@DebugMode"} {
				set Sets::DebugMode [GetBooleanValue $val]
			} elseif {$var == "@ActionMode"} {
				set Sets::ActionMode [GetBooleanValue $val]
			} elseif {$var == "@CharMode"} {
				set Sets::CharMode [GetBooleanValue $val]
			}
		}
	}

	# Debugging
	if {$Sets::DebugMode} {
		puts $str
	}
}
