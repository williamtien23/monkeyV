# riscv32i_w1
 <strong> About The Project </strong> <br> 
 This is my (partially completed) first implementation of a RISCV architecture. The implementation is a 5-stage pipeline that currently only stalls during hazards. It currently has no internal instruction or data memory. I am using Verilator and a C++ wrapper to provide the core with an external "ideal 1 cycle read/write" memory for the time being. The instruction and data "memory" are split. 
 
<br> 

 <strong> A Couple Hacks (for the time being): </strong><br>
 I'm building the C program without a startup routine, implying that a) my stack pointer is uninitialized b) .data isn't properly relocated in SRAM. As a work around:
  <ul>
  <li>I'm passing arguments to objcopy in the riscv gcc toolchain to generate a .bin with padded 0's and a hard-coded relocation of .data into the memory location to match the linker script. </li>
  <li>I hard-code the stack pointer register in the register file to a non zero value during reset, instead of letting a startup routine define it.</i></li>
</ul>
 <br>
 
  <strong> To Do: </strong><br>
<ul>
  <li>Setup the compliance test suite </li>  
  <li>Implement instruction and data TCM or Cache </li>
  <li>Write a startup routine and set the memory map</i></li>
  <li>Implement some machine mode CSRs</i></li>
</ul>
<br> 

 <strong> Project Structure </strong> <br>
 /Src_v contains the verilog source code. /Src_c contains the sample C program, linker script and makefile. /Testbenches contains the C++ testbench files and hosts the test executables and .vcd waveform files. /doc contains design schematics and some waveform screenshots.
 <b> ** </b> You will need to modify 'project_dir' #define in the module_top_core.cpp file in /Testbenches to provide an absolute path to this project's root directory. This is for finding the .bin executable built by the example C program, which will be located in /Src_c <b> ** </b> 
 
 <br>


 <strong> Using My Bash Script </strong> <br>
  
 <ul>
  <li>Use Verilator to lint project with:<i> bash project.sh lint</i></li>
  <li>Build the sample C program with:<i> bash project.sh build</i> </li>
  <li>Verilate project, build testbench and simulate with:<i> bash project.sh simulate</i></li>
  <li>Run the ALU_i tests by changing target with:<i> bash project.sh simulate -target alu_i module_alu_i</i></li>
</ul>
<br>

<strong> The ALU Test </strong> <br>
I tested the ALU by generating random signed int values in the cpp wrapper module. The cpp wrapper performs the same ALU operations alongside the simulated verilog ALU. Both answers are compared and the result is written as a Pass or Fail to the alu_tests.txt file that generates in /Testbenches. If a test case fails, the mismatched result from the verilog ALU is also outputted.


<img src="doc/sample_program_hazard.PNG">

<img src="doc/sample_program_sw.PNG">

<img src="doc/sample_program_ld.PNG">

<img src="doc/sample_program_jalr.PNG">


