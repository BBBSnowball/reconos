#!/bin/bash

set -e

cd "$(dirname "$0")"

[ -z "$RECONOS" ] && RECONOS=../../..

check_environment() {
	# The Xilinx settings script is confused by our arguments, so we must remove them.
	while [ -n "$1" ] ; do
		shift
	done

	if [ -z "$RECONOS" -o ! -d "$RECONOS" ] ; then
		echo "Please source the ReconOS config script or set \$RECONOS before running this script." >&2
		exit 1
	fi

	[ -n "$XILINX_SETTINGS_SCRIPT" ] && source "$XILINX_SETTINGS_SCRIPT"

	if [ -z "$XILINX" -o ! -d "$XILINX" ] ; then
		echo "Please source the ReconOS config script or set \$XILINX_SETTINGS_SCRIPT before running this script." >&2
		exit 1
	fi
}

check_environment

createProjectFile() {
	# clear project file
	echo -n > "$1"
}

addPcore() {
	pao_file="$1"
	project_file="$2"

	# executed by "lib ..." lines in *.pao files
	lib() {
		library_name="$1"
		source_name="$2"
		source_type="$3"

		if [ -z "$source_type" -a "$source_name" == "all" ] ; then
			# This is a library dependency.
			return
		fi

		#TODO only works for VHDL...
		source_extension="vhd"

		source_file="$HDL_DIR/$source_type/$source_name.$source_extension"

		if [ -e "$source_file" ] ; then
			echo "$source_type $library_name \"$source_file\"" >>"$project_file"
		else
			echo "WARNING: Source file doesn't exist: $source_file" >&2
		fi
	}

	PCORE_DATA_DIR="$(dirname "$pao_file")"
	PCORE_DIR="$(dirname "$PCORE_DATA_DIR")"
	HDL_DIR="$PCORE_DIR/hdl"
	#echo "# $pao_file" >>"$project_file"
	. "$pao_file"
}

function addSourceFromProjectFile() {
	source_project="$1"
	target_project="$2"

	#echo "# $source_project" >> "$target_project"
	cat "$source_project" >> "$target_project"
}

createProjectFile all.prj

find "$RECONOS/pcores" "../hw" "$XILINX/../EDK/hw/XilinxProcessorIPLib/pcores" -iname "*.pao" \
	| grep 'reconos\(_test\)\?_v3\|sort_demo\|proc_common_v3' \
	| grep -v edk_ \
	| while read pao_file ; do
		addPcore "$pao_file" "all.prj"
	done

addSourceFromProjectFile test.prj all.prj

removeFuseLog() {
	if [ -e "fuse.log" ] ; then
		rm fuse.log
	fi
}

checkFuseResult() {
	if ! [ -e "fuse.log" ] ; then
		echo "ERROR: Fuse hasn't created logfile fuse.log!" >&2
		exit 1
	fi

	if grep "^WARNING:.* remains a black-box since it has no binding entity.$" fuse.log >&2 ; then
		echo "ERROR: Simulation will not work, if an entity is missing. Please add it to all.prj" >&2
		exit 1
	fi
}

removeFuseLog
fuse -incremental -prj all.prj -o test_sim work.sort_demo_test || exit $?
checkFuseResult

runISim() {
	isim_binary="$1"

	cat >run_test.tcl <<EOF
	cd "$(realpath "$(dirname "$0")")"
	run all
	exit
EOF

	[ -e "isim.log" ] && rm isim.log
	"$isim_binary" -intstyle ise -tclbatch run_test.tcl || exit $?
}

checkISimResult() {
	if ! [ -e "isim.log" ] ; then
		echo "ERROR: ISim hasn't created logfile isim.log!" >&2
		exit 1
	fi

	if ! grep -q "Simulator is doing circuit initialization process" isim.log ; then
		# We could also check for "Finished circuit initialization process", but it seems that
		# this is not printed, if we abort the simulation.
		echo "There seams to be some problem with the simulation." >&2
		exit 1
	fi

	if grep -q "The simulator has terminated in an unexpected manner" isim.log ; then
		echo "There seams to be some problem with the simulation." >&2
		exit 1
	fi

	if ! grep -q "INFO: Simulator is stopped" isim.log ; then
		echo "There seams to be some problem with the simulation." >&2
		exit 1
	fi

	if grep -v "^\*\* Failure:\s*NONE\. End of simulation\." isim.log | grep -q "^\*\* Failure:" ; then
		echo "The simulation has been stopped by a fatal error!" >&2
		exit 1
	fi

	# We use grep without '-q', so the user will see the error messages again.
	if grep "^at [^:]*: Error: " isim.log >&2 || grep -i "^Error: " isim.log >&2 ; then
		echo "There was at least one error during the test run!" >&2
		exit 1
	fi
}

runISim ./test_sim
checkISimResult

echo "PASSED"
