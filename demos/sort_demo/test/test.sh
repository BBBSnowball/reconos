#!/bin/bash

set -e

cd "$(dirname "$0")"

[ -z "$RECONOS" ] && RECONOS=../../..

. "testlib.sh"

check_environment

createProjectFile all.prj \
	"$RECONOS/pcores/reconos_v3_01_a/data/reconos_v2_1_0.pao" \
	"$RECONOS/pcores/reconos_test_v3_01_a/data/reconos_test_v2_1_0.pao" \
	"$XILINX/../EDK/hw/XilinxProcessorIPLib/pcores/proc_common_v3_00_a/data/proc_common_v2_1_0.pao" \
	"../hw/hwt_sort_demo_v1_00_c/data/hwt_sort_demo_v2_1_0.pao" \
	"test.prj"

runTest all.prj work.sort_demo_test || exit $?

echo "PASSED"
