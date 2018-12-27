
namespace eval Cell {
	set SEARCH_ALL -1
	set SEARCH_TOP 0
	set SEARCH_BOT 1
	set SEARCH_LEFT 2
	set SEARCH_RIGHT 3
}

proc Cell::CheckUpWall {x y array2D size {seek "."}} {
	for {set i [expr $y-1]} {$i >= [expr $y-2]} {incr i -1} {
		if {$i >= 0} {
			if {$x-1 >= 0 && [lindex $array2D [expr $x-1] $i] != $seek}		{return 1}
			if {[lindex $array2D $x $i] != $seek}							{return 1}
			if {$x+1 < $size && [lindex $array2D [expr $x+1] $i] != $seek}	{return 1}
		}
	}
	return 0
}

proc Cell::CheckDownWall {x y array2D size {seek "."}} {
	for {set i [expr $y+1]} {$i <= [expr $y+2]} {incr i} {
		if {$i < $size} {
			if {$x-1 >= 0 && [lindex $array2D [expr $x-1] $i] != $seek}		{return 1}
			if {[lindex $array2D $x $i] != $seek}							{return 1}
			if {$x+1 < $size && [lindex $array2D [expr $x+1] $i] != $seek} 	{return 1}
		}
	}
	return 0
}

proc Cell::CheckLeftWall {x y array2D size {seek "."}} {
	for {set i [expr $x-1]} {$i >= [expr $x-2]} {incr i -1} {
		if {$i >= 0} {
			if {$y-1 >= 0 && [lindex $array2D $i [expr $y-1]] != $seek} 	{return 1}
			if {[lindex $array2D $i $y] != $seek} 							{return 1}
			if {$y+1 < $size && [lindex $array2D $i [expr $y+1]] != $seek}	{return 1}
		}
	}
	return 0
}

proc Cell::CheckRightWall {x y array2D size {seek "."}} {
	for {set i [expr $x+1]} {$i <= [expr $x+2]} {incr i} {
		if {$i < $size} {
			if {$y-1 >= 0 && [lindex $array2D $i [expr $y-1]] != $seek}		{return 1}
			if {[lindex $array2D $i $y] != $seek}							{return 1}
			if {$y+1 < $size && [lindex $array2D $i [expr $y+1]] != $seek}	{return 1}
		}
	}
	return 0
}

proc Cell::CheckAllWalls {x y array2D size {seek "."}} {
	# top left, top middle, top right
	if {$y > 0} {
		if {$x > 0 && [lindex $array2D [expr $x-1] [expr $y-1]] != $seek}		{return 1}
		if {[lindex $array2D $x [expr $y-1]] != $seek}							{return 1}
		if {$x < $size-1 && [lindex $array2D [expr $x+1] [expr $y-1]] != $seek}	{return 1}
	}

	# left middle, middle, right middle
	if {$x > 0 && [lindex $array2D [expr $x-1] $y] != $seek}		{return 1}
	if {[lindex $array2D $x $y] != $seek}							{return 1}
	if {$x < $size-1 && [lindex $array2D [expr $x+1] $y] != $seek}	{return 1}

	# bot left, bot middle, bot right
	if {$y < $size-1} {
		if {$x > 0 && [lindex $array2D [expr $x-1] [expr $y+1]] != $seek}		{return 1}
		if {[lindex $array2D $x [expr $y+1]] != $seek}							{return 1}
		if {$x < $size-1 && [lindex $array2D [expr $x+1] [expr $y+1]] != $seek}	{return 1}
	}

	# success
	return 0
}

# Returns 1 if position or surrondings are occupied in 2D array.
proc Cell::IsCellOccupied {x y direction array2D min max {seek "."}} {
	set a [CheckAllWalls $x $y $array2D $max]
	set t [CheckUpWall $x $y $array2D $max]
	set d [CheckDownWall $x $y $array2D $max]
	set l [CheckLeftWall $x $y $array2D $max]
	set r [CheckRightWall $x $y $array2D $max]

	# Debugging.
	if {$Sets::DebugMode} {
		puts "Cell::IsCellOccupied() - X:$x Y:$y"
		puts "Direction: $direction All: $a, Up: $t, Down: $d, Left: $l, Right: $r"
	}

	if {$direction == $Cell::SEARCH_TOP} {
		return $t
	} elseif {$direction == $Cell::SEARCH_BOT} {
		return $d
	} elseif {$direction == $Cell::SEARCH_LEFT} {
		return $l
	} elseif {$direction == $Cell::SEARCH_RIGHT} {
		return $r
	}

	return $a
}