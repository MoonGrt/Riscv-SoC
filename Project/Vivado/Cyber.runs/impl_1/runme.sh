#!/bin/sh

# 
# Vivado(TM)
# runme.sh: a Vivado-generated Runs Script for UNIX
# Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
# 

echo "This script was generated under a different operating system."
echo "Please update the PATH and LD_LIBRARY_PATH variables below, before executing this script"
exit

if [ -z "$PATH" ]; then
  PATH=G:/Xilinx1/SDK/2018.3/bin;G:/Xilinx1/Vivado/2018.3/ids_lite/ISE/bin/nt64;G:/Xilinx1/Vivado/2018.3/ids_lite/ISE/lib/nt64:G:/Xilinx1/Vivado/2018.3/bin
else
  PATH=G:/Xilinx1/SDK/2018.3/bin;G:/Xilinx1/Vivado/2018.3/ids_lite/ISE/bin/nt64;G:/Xilinx1/Vivado/2018.3/ids_lite/ISE/lib/nt64:G:/Xilinx1/Vivado/2018.3/bin:$PATH
fi
export PATH

if [ -z "$LD_LIBRARY_PATH" ]; then
  LD_LIBRARY_PATH=
else
  LD_LIBRARY_PATH=:$LD_LIBRARY_PATH
fi
export LD_LIBRARY_PATH

HD_PWD='F:/Project/Sipeed/Tang_Primer/Riscv-SoC/Project/Vivado/Cyber.runs/impl_1'
cd "$HD_PWD"

HD_LOG=runme.log
/bin/touch $HD_LOG

ISEStep="./ISEWrap.sh"
EAStep()
{
     $ISEStep $HD_LOG "$@" >> $HD_LOG 2>&1
     if [ $? -ne 0 ]
     then
         exit
     fi
}

# pre-commands:
/bin/touch .init_design.begin.rst
EAStep vivado -log Cyber.vdi -applog -m64 -product Vivado -messageDb vivado.pb -mode batch -source Cyber.tcl -notrace


