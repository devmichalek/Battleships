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

proc ReadFromFile {filepath} {
	set file [open $filepath r]
	set data [read $file]
	close $file
	return $data
}

proc ClearFile {filepath} {
	close [open $filepath w]
}

proc WriteToFile {filepath data} {
	set file [open $filepath w]
	puts $file $data
	close $file
}

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
set cx -1
set cy -1
set made 0
set washit 0
proc Calculate {} {

	# Make move.
	if {$::made == 0} {
		if {!$::washit} {
			# Make totally new move.
			set xlist ""
			set ylist ""
			for {set i 0} {$i < $::length} {incr i} {
				for {set j 0} {$j < $::length} {incr j} {
					if {[lindex $::field $i $j] == "."} {
						append xlist $i " "
						append ylist $j " "
					}
				}
			}

			set lnr [expr {int(rand() * [llength $xlist])}]

			# cx, cy
			set ::cx [lindex $xlist $lnr]
			set ::cy [lindex $ylist $lnr]
			set tmp [format %c [expr $::cy + 65]]

			# Write to file.
			WriteToFile $Sets::FileName "$::cx$tmp"
			unset xlist
			unset ylist
		} else {
			for {set i 0} {$i < $::length} {incr i} {
				for {set j 0} {$j < $::length} {incr j} {
					if {[lindex $::field $i $j] == "K"} {

						set seek "."
						set il [expr $i-1]
						set im [expr $i+1]
						set jl [expr $j-1]
						set jm [expr $j+1]
						set movements ""
						set ::cx $i
						set ::cy $j

						if {$j > 0 && [lindex $::field $i $jl] == $seek} {append movements $::Cell::SEARCH_TOP " "}
						if {$i > 0 && [lindex $::field $il $j] == $seek} {append movements $::Cell::SEARCH_LEFT " "}
						if {$j < [expr $::length -1] && [lindex $::field $i $jm] == $seek} {append movements $::Cell::SEARCH_BOT " "}
						if {$i < [expr $::length -1] && [lindex $::field $im $j] == $seek} {append movements $::Cell::SEARCH_RIGHT " "}

						if {[llength $movements] > 0} {
							set lnr [expr {int(rand() * [llength $movements])}]
							set choice [lindex $movements $lnr]
							if {$choice == $::Cell::SEARCH_TOP} {
								set ::cy [expr $j - 1]
							} elseif {$choice == $::Cell::SEARCH_LEFT} {
								set ::cx [expr $i - 1]
							} elseif {$choice == $::Cell::SEARCH_BOT} {
								set ::cy [expr $j + 1]
							} elseif {$choice == $::Cell::SEARCH_RIGHT} {
								set ::cx [expr $i + 1]
							}

							# Write to file.
							set tmp [format %c [expr $::cy + 65]]
							WriteToFile $Sets::FileName "$::cx$tmp"

							set ::made 1
							return 0
						}
					}
				}
			}
		}

		set ::made 1
		return 0
	}

	# Read data from file.
	set data [ReadFromFile $Sets::FileName]
	if {[llength $data] == 0} {return 0}
	set str [lindex $data 0]

	if {$str == "hit"} {
		# Mark drown part of enemy's ship.
		lset ::field $::cx $::cy "K"

		set ::washit 1
		set ::made 0
		ClearFile $Sets::FileName
		return 1
	} elseif {$str == "mishit"} {
		lset ::field $::cx $::cy "0"
		set ::made 0
		ClearFile $Sets::FileName
		return 1
	} elseif {$str == "drown"} {
		# Mark drown part of enemy's ship.
		lset ::field $::cx $::cy "X"

		# Make "frame"
		for {set i 0} {$i < $::length} {incr i} {
			for {set j 0} {$j < $::length} {incr j} {
				if {[lindex $::field $i $j] == "K"} {lset ::field $i $j "X"}
				if {[lindex $::field $i $j] == "X"} {

					set seek "."
					set il [expr $i-1]
					set im [expr $i+1]
					set jl [expr $j-1]
					set jm [expr $j+1]

					# Left
					if {$i > 0} {
						if {$j > 0 && [lindex $::field $il $jl] == $seek}					{lset ::field $il $jl "0"}
						if {[lindex $::field $il $j] == $seek}								{lset ::field $il $j "0"}
						if {$j < [expr $::length-1] && [lindex $::field $il $jm] == $seek}	{lset ::field $il $jm "0"}
					}

					# Right
					if {$i < [expr $::length-1]} {
						if {$j > 0 && [lindex $::field $im $jl] == $seek}					{lset ::field $im $jl "0"}
						if {[lindex $::field $im $j] == $seek}								{lset ::field $im $j "0"}
						if {$j < [expr $::length-1] && [lindex $::field $im $jm] == $seek}	{lset ::field $im $jm "0"}
					}

					# Middle
					if {$j > 0 && [lindex $::field $i $jl] == $seek}					{lset ::field $i $jl "0"}
					if {$j < [expr $::length-1] && [lindex $::field $i $jm] == $seek}	{lset ::field $i $jm "0"}
				}
			}
		}

		# Reset.
		set ::washit 0
		set ::made 0
		ClearFile $Sets::FileName
		return 1
	} elseif {$str == "defeat"} {
		set ::endgame 1
		set ::actionstr "\033\[32mBattle is won. Victory.\033\[0m"
		set ::made 0
		ClearFile $Sets::FileName
		return 1
	}

	# Another player did not make decision yet.
	return 0
}

# Wait for enemy's move
set lastMove ""
proc Wait {} {
	set data [ReadFromFile $Sets::FileName]

	if {[llength $data] != 1} {
		return 0
	}

	set str [lindex $data 0]

	# Debugging
	if {$Sets::DebugMode} {
		puts "Wait() string: $str"
	}

	if {[string length $str] == 2} {
		if {$::lastMove == "" || $::lastMove != $str} {
			# Set last move.
			set ::lastMove $str

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
			if {[lindex $::area $x $y] == "S"} {

				# Mark it.
				lset ::area $x $y "X"

				set floatingParts 0
				set leftShips 0
				for {set i 0} {$i < $::length} {incr i} {
					for {set j 0} {$j < $::length} {incr j} {
						if {[lindex $::area $i $j] == "S"} {
							incr leftShips

							set seek "X"
							set il [expr $i-1]
							set im [expr $i+1]
							set jl [expr $j-1]
							set jm [expr $j+1]

							# Left
							if {$i > 0} {
								if {$j > 0 && [lindex $::area $il $jl] == $seek}					{incr floatingParts}
								if {[lindex $::area $il $j] == $seek}								{incr floatingParts}
								if {$j < [expr $::length-1] && [lindex $::area $il $jm] == $seek}	{incr floatingParts}
							}

							# Right
							if {$i < [expr $::length-1]} {
								if {$j > 0 && [lindex $::area $im $jl] == $seek}					{incr floatingParts}
								if {[lindex $::area $im $j] == $seek}								{incr floatingParts}
								if {$j < [expr $::length-1] && [lindex $::area $im $jm] == $seek}	{incr floatingParts}
							}

							# Middle
							if {$j > 0 && [lindex $::area $i $jl] == $seek}					{incr floatingParts}
							if {$j < [expr $::length-1] && [lindex $::area $i $jm] == $seek}	{incr floatingParts}
						}
					}
				}

				# Defeat
				if {$leftShips == 0} {
					set ::endgame 1
					set ::actionstr "\033\[31mGot failed in a battle. Surrender.\033\[0m"

					WriteToFile $Sets::FileName "defeat"
				} elseif {$floatingParts == 0} {
					WriteToFile $Sets::FileName "drown"
				} else {
					WriteToFile $Sets::FileName "hit"
				}
			} else {
				WriteToFile $Sets::FileName "mishit"
			}

			while {1} {
				set data [ReadFromFile $Sets::FileName]
				if {$data == ""} {break}
				after $Sets::TimeForMove
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
			set ::actionstr "Making next move..."
			if {[Calculate]} {
				set Sets::CurrentMove $Sets::MOVE_WAITING
			}
		}
	}

	after $Sets::TimeForMove
}