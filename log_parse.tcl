#!/usr/bin/tclsh

proc read_in_file { in_file } {
	set datas [dict create] 
	set pf [open $in_file r]
	puts "the file $in_file will be parsed"
	parse_file $pf $datas
	
}

proc parse_file { f_name ,datas } {
	set mf [open "Mapping.tmp" w]
	set list1 [list "Golden elab runtime"  "Revised elab runtime" "Golden compile rt" "Revised compile rt" "Set mode ec rt" "Map rt" "Compare rt" "Mapped inputs" "Mapped outputs " "Mapped states" ]
    set var ""
    foreach i $list1 {
        append var "\"" "$i" "\"" ","   
    }
    puts $mf $var
	set s 0
	set n 0
	set m 0
    set flag 0
	set key ""
	while {[gets $f_name line] != -1} {
		if { $n == 1 && [string match "*$s*" $line] == 1} {
			set s 0
			set n 0
			dict append datas $key [string range $line 13 21]
            set key1 [ string last "_" $key ]
            set key11 [ string range $key 0 $key1]
            append key11 "Mem"
			dict append datas $key11 [string range $line 38 48]
		}
		if { $m == 1 } {
			if { [string match "*$s*" $line] == 1} {
			    dict append datas $key $line
				set s 0
				set m 0
			} else {
				#puts $mf $line
			    dict append datas $key $line 
			}
		}
		if { [string match "*Elaboration of design golden*" $line] == 1} {
			set s "System"
			set n 1
			set key "El_golden_time"
		}
		if { [string match "*Elaboration of design revised*" $line] == 1} {
			set s "System"
			set n 1 
			set key "El_revised_time" 
		}
		if { [string match "*Compilation for design golden*" $line] == 1} {
			set key "Comp_golden_time"
            puts $key
            set x [ string first took $line ]
            set y [ expr $x + 5 ]
            set space [ string first " " $line $y ]
            set sec [ expr $space + 3 ]
			dict append datas $key [ string range $line $y $sec ]
		}
		if { [string match "*Compilation for design revised*" $line] == 1} {
			set key "Comp_revised_time"
            puts $line
            set x [ string first took $line ]
            set y [ expr $x + 5 ]
            set space [ string first " " $line $y ]
            set sec [ expr $space + 3 ]
			dict append datas $key [ string range $line $y $sec ]
		}
		if { [string match "*Entering ec mode*" $line] == 1} {
			set s "*System*"
			set n 1 
			set key "EC_mode_time"
		}
		if { [string match "*Start mapping phas*" $line] == 1} {
			set s "System"
			set m 1
			set key "Mapping_info"
        }
		if { [string match "*The designs are*" $line] == 1} {
            set key "Eq?Not"
			set n 1
            set x [ string first are $line ]
            set y [ expr $x + 3 ]
            set eq [ string first equiv $line $y ]
            set eqI [ expr $eq + 4]
            if { $flag == 0 } {
			    dict append datas $key [string range $line $y $eqI]
            }
            set flag  1
			set key "Design_Time"
			set s "*System*"
			set n 1
		}
		if { [string match "*Check * finished*" $line] == 1} {
			set key "comb?seq"
            set x [ string first ( $line ]
            set y [ expr $x + 1 ]
            set bracket [ string first ) $line $y ]
            set brack [ expr $bracket ] 
			dict append datas $key [ string range $line $y $brack ]
		}

	}
	puts "RESULT IS"
	puts  $datas
	close $f_name
	close $mf
	#set mf [open "Mapping.tmp" r]
	#while {[gets $mf l] != -1} {
	#	puts $l
	#}
	#close $mf
	#file delete "Mapping.tmp"
}

if { $argc > 0   } {
    set fp [lindex $argv 0]
	if { [file exists $fp] == 1} {
		read_in_file  $fp 
	} else {
		puts "The file $fp can't be found."
	}
} else {
 	puts "There is no any arguments to parse"
}

