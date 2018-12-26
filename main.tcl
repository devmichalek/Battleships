# Includes.
source {sets.tcl}
source {cell.tcl}
source {print.tcl}


set area {
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
	{. . . . . . . . . .}
}

set field $area
set length 10
set actionstr "Positioning ships..."
set endgame 0


# Prepares ships in the 2D array.
proc Prepare {} {

	# Array of movements.
	set movements {}
	set ships {1 1 2 2 3 3 4 5}
	append movements $::Cell::SEARCH_TOP " "
	append movements $::Cell::SEARCH_BOT " "
	append movements $::Cell::SEARCH_LEFT " "
	append movements $::Cell::SEARCH_RIGHT " "

	while {[llength $ships] > 0} {
		set count [llength $ships]
		set next [expr int(rand() * $count)]
		set ship [lindex $ships $next]
		set acts $movements
		set x -1
		set y -1

		# Debugging
		if {$Sets::DebugMode} {puts "Count: $count"}
		
		while {$ship != 0} {

			# Debugging
			if {$Sets::DebugMode} {puts "Left parts of ship: $ship"}

			# Make first move.
			if {$ship == [lindex $ships $next]} {
				while {1} {
					set x [expr {int(rand() * $::length)}]
					set y [expr {int(rand() * $::length)}]

					# Check if cell is occupied
					if {[Cell::IsCellOccupied $x $y $::Cell::SEARCH_ALL $::area 0 [expr $::length]] == 0} {
						lset ::area $x $y "T"

						# Debugging.
						if {$Sets::DebugMode} {puts "\nAdded: x:$x y:$y"}

						incr ship -1
						break
					}
				}
				continue
			}
			
			# Make move.
			set buffer $ship
			while {[llength $acts] != 0} {
				set num [llength $acts]
				set nr [expr {int(rand() * $num)}]
				set val [lindex $acts $nr]

				# Delete used possible movements.
				set acts [lreplace $acts $nr $nr]

				# Debugging
				if {$Sets::DebugMode} {puts "Making move, num: $num, nr: $nr, val: $val\tPosition x:$x y:$y"}

				# Check if cell is occupied
				if {[Cell::IsCellOccupied $x $y $val $::area 0 [expr $::length]] == 0} {

					if {$val == $::Cell::SEARCH_TOP} {
						if {$y-1 < 0} {continue}
						incr y -1
					} elseif {$val == $::Cell::SEARCH_BOT} {
						if {$y+1 >= $::length} {continue}
						incr y
					} elseif {$val == $::Cell::SEARCH_LEFT} {
						if {$x-1 < 0} {continue}
						incr x -1
					} elseif {$val == $::Cell::SEARCH_RIGHT} {
						if {$x+1 >= $::length} {continue}
						incr x
					}

					lset ::area $x $y "T"
					incr ship -1
					set acts $movements
					break
				}
			}

			# Failure
			# Reset - all directions failed.
			# Replace all temporary chars "T" with dots "."
			if {$buffer == $ship} {
				set ship [lindex $ships $next]
				set acts $movements

				# Debugging
				if {$Sets::DebugMode} {puts "----Reset----"}

				for {set i 0} {$i < $::length} {incr i} {
					for {set j 0} {$j < $::length} {incr j} {
						if {[lindex $::area $i $j] == "T"} {
							lset ::area $i $j "."

							# Debugging
							if {$Sets::DebugMode} {puts "Node i:$i j:$j removed."}
						}
					}
				}
			}
		}

		# Make ship pernament.
		for {set i 0} {$i < $::length} {incr i} {
			for {set j 0} {$j < $::length} {incr j} {
				if {[lindex $::area $i $j] == "T"} {
					lset ::area $i $j "S"

					# Debugging
					if {$Sets::DebugMode} {puts "Node i:$i j:$j made pernament."}
				}
			}
		}

		# Remove ship from list.
		set ships [lreplace $ships $next $next]
	}
}

# Make move.
set sx -1
set sy -1
set cx -1
set cy -1
set made 0
set washit 0
proc Calculate {} {
	set file [open "move.txt" r]
	set data [read $file]
	close $file

	if {[llength $data] == 0} {return 0}
	set str [lindex $data 0]

	# Make move.
	if {$::made == 0} {
		# Make totally new move.
		if {$::washit == 0 && $::sx == -1 && $::sy == -1} {
			
		} else {

		}
	}

	if {$str == "hit"} {

		# Set first hit x y position
		if {$::sx == -1 && $::sy == -1} {
			set ::sx $::cx
			set ::sy $::cy
		}

		# Mark drown part of enemy's ship.
		lset ::field $::cx $::cy "X"

		set ::washit 1
		set ::made 0
		return 1
	} elseif {$str == "mishit"} {
		lset ::field $::cx $::cy "0"
		set ::washit 0
		set ::made 0
		return 1
	} elseif {$str == "drown"} {
		# Mark drown part of enemy's ship.
		lset ::field $::cx $::cy "X"

		# Make "frame"
		for {set i 0} {$i < $::length} {incr i} {
			for {set j 0} {$j < $::length} {incr j} {
				if {[lindex $::field $i $j] == "X"} {
					# Left
					if {$i > 0} {
						set val [expr $i-1]
						if {$j > 0 && [lindex $::field $val [expr $j-1]] != "X"} {lset ::field $val [expr $j-1] "0"}
						if {[lindex $::field $val $j] != "X"} {lset ::field $val $j "0"}
						if {$j < [expr $::length-1] && [lindex $::field $val [expr $j+1]] != "X"} {lset ::field $val [expr $j+1] "0"}
					}

					# Right
					if {$i < [expr $::length-1]} {
						set val [expr $i+1]
						if {$j > 0 && [lindex $::field $val [expr $j-1]] != "X"} {lset ::field $val [expr $j-1] "0"}
						if {[lindex $::field $val $j] != "X"} {lset ::field $val $j "0"}
						if {$j < [expr $::length-1] && [lindex $::field $val [expr $j+1]] != "X"} {lset ::field $val [expr $j+1] "0"}
					}

					# Middle
					if {$j > 0 && [lindex $::field $i [expr $j-1]] != "X"} {lset ::field $i [expr $j-1] "0"}
					if {$j < [expr $::length-1] && [lindex $::field $i [expr $j+1]] != "X"} {lset ::field $i [expr $j+1] "0"}
				}
			}
		}

		# Reset.
		set ::sx -1
		set ::sy -1
		set ::washit 0
		set ::made 0
		return 1
	} elseif {$str == "defeat"} {
		set ::endgame 1
		set ::actionstr "Battle is won. Victory."
		set ::made 0
		return 1
	}

	# Another player did not make decision yet.
	return 0
}

# Wait for enemy's move
set lastMove ""
proc Wait {} {
	set file [open "move.txt" r]
	set data [read $file]
	close $file

	if {[llength $data] != 1} {
		return 0
	}

	set str [lindex $data 0]

	# Debugging
	if {$Sets::DebugMode} {
		puts "Wait() string: $str"
	}

	if {[string length $str] == 2} {
		if {$lastMove == "" || $lastMove != $str} {
			# Set last move.
			set lastMove $str

			# 0...9 - x
			# A...J - y
			set x [string index $str 0]
			set tmp 0
			scan [string index $str 1] %c tmp
			set y [expr $tmp - 65]

			# Debugging
			if {$Sets::DebugMode} {
				puts "Wait() x:$x y:$y"
			}

			# Check if ship got hit.
			if {[lindex $area $x $y] == "S"} {

				# Mark it.
				lset ::area $x $y "X"

				set leftShips 0
				for {set i 0} {$i < $::length} {incr i} {
					for {set j 0} {$j < $::length} {incr j} {
						if {[lindex $::area $i $j] == "S"} {
							incr leftShips
						}
					}
				}

				# Defeat
				if {$leftShips == 0} {
					set ::endgame 1
					set ::actionstr "Got failed in a battle. Surrender."

					set file [open "move.txt" w+]
					puts $file "defeat"
					close $file
				}

				# Is ship drown?


				return 0
			} else {
				set file [open "move.txt" w+]
				puts $file "mishit"
				close $file
			}

			return 1
		}
	}

	return 0
}


# Init
Sets::Load
after $Sets::TimeForMove

# States.
set PREPARING 0
set PLAYING 1
set state $PREPARING

# Main loop.
set quit 0
while {!$::quit} {

	# Print area and field.
	Supp::Print $::area $::field $::length $::actionstr
	if {$::endgame} {break}

	# Make action based on the state.
	if {$::state == $::PREPARING} {
		Prepare
		incr ::state
	} elseif {$::state == $::PLAYING} {
		if {$Sets::CurrentMove == $Sets::MOVE_WAITING} {
			set ::actionstr "Waiting for opponent's move..."
			if {[Wait]} {
				set Sets::CurrentMove $Sets::MOVE_ATTACKING
			}
		} elseif {$Sets::CurrentMove == $Sets::MOVE_ATTACKING} {
			set ::actionstr "Calculating next move..."
			if {[Calculate]} {
				set Sets::CurrentMove $Sets::MOVE_WAITING
			}
		}
	}

	after $Sets::TimeForMove
}