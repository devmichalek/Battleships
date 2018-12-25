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
proc calculate {} {

}

# Wait for enemy's move
proc wait {} {
	
}


proc finish {} {

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

	# Make action based on the state.
	if {$::state == $::PREPARING} {
		Prepare
		incr ::state
	} elseif {$::state == $::PLAYING} {
		if {$Sets::CurrentMove == $Sets::MOVE_WAITING} {
			set ::actionstr "Waiting for opponent's move."

		} elseif {$Sets::CurrentMove == $Sets::MOVE_ATTACKING} {
			set ::actionstr "Calculating next move."

		}
	}

	after $Sets::TimeForMove
}