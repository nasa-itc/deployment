#!/bin/bash

#
# This script sets up the submodules necessary for a NOS3 new mission setup.
#
# It is assumed you have already copied the `mission` directory to a new location
# and are running this script from inside the copy.
#
# https://github.com/nasa/nos3
# 
git submodule init

###
### Components
###

# TODO: Comment out the components not included on the specific mission
git submodule add -f -b main https://github.com/nasa-itc/arducam.git ./components/arducam
git submodule add -f -b main https://github.com/nasa-itc/generic_reaction_wheel.git ./components/generic_reaction_wheel
git submodule add -f -b main https://github.com/nasa-itc/novatel_oem615.git ./components/novatel_oem615
git submodule add -f -b main https://github.com/nasa-itc/sample.git ./components/sample
git submodule add -f -b main https://github.com/nasa-itc/component_template.git ./components/template


###
### Flight Software (fsw)
###

# Core
git submodule add -f -b nos3-main https://github.com/nasa-itc/cFE.git ./fsw/cfe
git submodule add -f -b nos3-main https://github.com/nasa-itc/osal.git ./fsw/osal
git submodule add -f -b nos3-main https://github.com/nasa-itc/PSP.git ./fsw/psp

# Apps
git submodule add -f -b nos3-main https://github.com/nasa-itc/CF.git ./fsw/apps/cf
git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_lib.git ./fsw/apps/cfs_lib
git submodule add -f -b nos3-main https://github.com/nasa-itc/CFS_CI.git ./fsw/apps/ci
#git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_cs.git ./fsw/apps/cs
#git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_ds.git ./fsw/apps/ds
#git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_fm.git ./fsw/apps/fm
git submodule add -f -b nos3-main https://github.com/nasa-itc/HK.git ./fsw/apps/hk
git submodule add -f -b nos3-main https://github.com/nasa-itc/HS.git ./fsw/apps/hs
git submodule add -f -b main https://github.com/nasa-itc/hwlib.git ./fsw/apps/hwlib
git submodule add -f -b nos3-main https://github.com/nasa-itc/CFS_IO_LIB.git ./fsw/apps/io_lib
git submodule add -f -b nos3-main https://github.com/nasa-itc/LC.git ./fsw/apps/lc
#git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_md.git ./fsw/apps/md
#git submodule add -f -b nos3-main https://github.com/nasa-itc/cfs_mm.git ./fsw/apps/mm
git submodule add -f -b nos3-main https://github.com/nasa-itc/SC.git ./fsw/apps/sc
git submodule add -f -b nos3-main https://github.com/nasa-itc/SCH.git ./fsw/apps/sch
git submodule add -f -b nos3-main https://github.com/nasa-itc/CFS_TO.git ./fsw/apps/to

# Apps External
git submodule add -f -b main https://github.com/nasa/ci_lab.git ./fsw/apps/ci_lab
git submodule add -f -b main https://github.com/nasa/to_lab.git ./fsw/apps/to_lab

# Tools
git submodule add -f -b nos3-main https://github.com/nasa-itc/elf2cfetbl.git ./fsw/tools/elf2cfetbl


###
### Ground Software (gsw)
###

git submodule add -f -b main https://github.com/nasa-itc/gsw-ait.git ./gsw/ait
git submodule add -f -b main https://github.com/nasa-itc/gsw-cosmos.git ./gsw/cosmos
git submodule add -f -b main https://github.com/nasa-itc/OrbitInviewPowerPrediction.git ./gsw/OrbitInviewPowerPrediction


###
### Simulators (sims)
###

git submodule add -f -b main https://github.com/nasa-itc/nos_time_driver.git ./sims/nos_time_driver
git submodule add -f -b main https://github.com/nasa-itc/sim_common.git ./sims/sim_common
git submodule add -f -b main https://github.com/nasa-itc/sim_server.git ./sims/sim_server
git submodule add -f -b main https://github.com/nasa-itc/sim_terminal.git ./sims/sim_terminal
git submodule add -f -b main https://github.com/nasa-itc/truth_42_sim.git ./sims/truth_42_sim
