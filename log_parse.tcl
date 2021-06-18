#!/usr/bin/tclsh

proc read_in_file { in_file } {
	set datas [dict create] 
	#set list1 = [list "Golden elab runtime"  "Revised elab runtime" "Golden compile rt" "Revised compile rt" "Set mode ec rt" "Map rt" "Compare rt" "Mapped inputs" "Mapped outputs " "Mapped states"]
	set pf [open $in_file r]
	puts "the file $in_file will be parsed"
	parse_file $pf $datas
	
}

proc parse_file { f_name ,datas } {
	set mf [open "Mapping.tmp" w]
	set s 0
	set n 0
	set m 0
	set key ""
	while {[gets $f_name line] != -1} {
		if { $n == 1 && [string match "*$s*" $line] == 1} {
			set s 0
			set n 0
			dict append datas $key $line
		}
		if { $m == 1 } {
			if { [string match "*$s*" $line] == 1} {
				#puts $line 
			    dict append datas $key $line
				set s 0
				set m 0
			#	set key ""
			} else {
				puts $mf $line
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
			dict append datas $key $line
		}
		if { [string match "*Compilation for design revised*" $line] == 1} {
			set key "Comp_revised_time"
			dict append datas $key $line
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
			dict append datas $key $line
			set key "Design_Time"
			set s "*System*"
			set n 1
		}
		if { [string match "*resource_usage_after_ec_mode_setup*" $line ] == 1 } {
			set key "Res_after_ec_mode"
			set s "*System*"
			set n 1
		}
		if { [string match "*resource_usage_after_map*" $line ] == 1 } {
            set key "Res_after_map"
            set s "*System*"
            set n 1
        }
		if { [string match "*resource_usage_after_compare*" $line ] == 1 } {
            set key "Res_after_compare"
            set s "*System*"
            set n 1
        }
		if { [string match "*resource_usage_after_clearbox*" $line ] == 1 } {
            set key "Res_after_clearbox"
            set s "*System*"
            set n 1
        }
		if { [string match "*resource_usage_after_golden*" $line ] == 1 } {
            set key "Res_after_golden_elab"
            set s "*System*"
            set n 1
        }
		if { [string match "*resource_usage_after_revised*" $line ] == 1 } {
            set key "Res_after_revised_elab"
            set s "*System*"
            set n 1
        }
		if { [string match "*Check * finished*" $line] == 1} {
			set key "comb?seq"
			dict append datas $key $line
		}

	}
	puts "RESULT IS"
	puts  $datas
	close $f_name
	close $mf
	set mf [open "Mapping.tmp" r]
	while {[gets $mf l] != -1} {
		puts $l
	}
	close $mf
	file delete "Mapping.tmp"
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

