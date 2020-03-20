#!/bin/bash -i
#
# Convenience script for NOS3 development
#

BASE_DIR=/home/nos3
SIM_BIN=$BASE_DIR/mission/build/sim/bin
SIMS=$(cd $SIM_BIN; ls nos3*simulator)
SIM_TABS=$(for i in $SIMS; do printf " --tab --title=$i -e \"$SIM_BIN/$i\" "; done)

#echo $BASE_DIR # debug
#echo $SIM_BIN # debug
#echo $SIMS # debug
#echo SIM_TABS=$SIM_TABS # debug

echo "Launching COSMOS Ground Station..."
cd $BASE_DIR/cosmos
ruby Launcher &
ruby tools/CmdTlmServer --config cmd_tlm_server.txt &
ruby tools/CmdSender &

echo "Launching 42 Dynamic Simulator..."
cd $BASE_DIR/nos3-42
gnome-terminal --title="42 Dynamic Simulator" -- /opt/42/42 NOS3-42InOut &

echo "Launching Component Simulators..."
cd $SIM_BIN
gnome-terminal \
--tab --title="NOS Engine Standalone Server" -e "/usr/bin/nos_engine_server_standalone -f $SIM_BIN/nos_engine_server_simulator_config.json" \
--tab --title="NOS Time Driver" -e $SIM_BIN/nos-time-driver \
--tab --title="Simulator Terminal" -e $SIM_BIN/nos3-simulator-terminal \
$SIM_TABS

echo "Launching Flight Software..."
cd $BASE_DIR/mission/build/fsw/exe/cpu1
gnome-terminal --title="NOS3 Flight Software" -- $BASE_DIR/mission/build/fsw/exe/cpu1/core-cpu1 &

echo "Done!  Hit the <RETURN> key to continue..."
read
