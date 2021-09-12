#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vtop_core.h"               // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <memory>
#include <stdlib.h>
#include <random>
#include <fstream>
#include <string>

#define project_dir "/home/william/William/w1/"

using namespace std;
Vtop_core *top;                      // Instantiation of model

int counter=0;
vluint64_t main_time = 0;       // Current simulation time
// This is a 64-bit integer to reduce wrap over issues and
// allow modulus.  This is in units of the timeprecision
// used in Verilog (or from --timescale-override)

std::default_random_engine generator;
std::uniform_int_distribution<int> distribution(-2147483648,2147483647);

double sc_time_stamp() {        // Called by $time in Verilog
    return main_time;           // converts to double, to match
                                // what SystemC does
}


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);   // Remember args

    //const std::unique_ptr<VerilatedContext> contextp{new VerilatedContext};
    Verilated::traceEverOn(true);

    top = new Vtop_core;             // Create model
    
    streampos size;
    char * instructions;
    char * data;
    ifstream file_in( (string)project_dir + (string)"Src_c/test_prog.bin", ios::binary|ios::ate);
    ofstream file_out( "tests_out.txt");

    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("trace.vcd");

    if (file_in.is_open()){
        instructions = new char [200];
        data = new char [200];
        file_in.seekg (0, ios::beg);
        file_in.read (instructions, 200); //0-200 instructions
        file_in.read (data, 200); //200-400 data
        file_in.close();
    }

    //top->i_reset = 0;           // Set some inputs
    top->Clk = 0;
    top->Reset = 1;
    top->Imem_data_read_cpp = 0;
    top->Dmem_data_read_cpp = 0;

    int data_addr;

    while (!Verilated::gotFinish() && top->Imem_addr_cpp<197 && main_time<1000) {
        if(main_time == 15){
            top->Reset = 0;
        }
        if(main_time % 5 == 0){ //Clock period 10 ticks
            top->Clk = (top->Clk+1)%2;
        }

        if ((main_time % 10 == 5) && main_time>10) {

            //Module Read Instruction
            top->Imem_data_read_cpp = ((0x000000ff & (int) instructions[(top->Imem_addr_cpp)+3]) << 24) | ((0x000000ff & (int) instructions[(top->Imem_addr_cpp)+2]) << 16) | ((0x000000ff & (int) instructions[(top->Imem_addr_cpp)+1]) << 8) | (0x000000ff & (int) instructions[top->Imem_addr_cpp]);

            data_addr = (top->Dmem_addr_cpp) - 200;
            if(data_addr >= 0  && data_addr<200){ //set virtual bounds
                //Module Write Data
                if(top->Dmem_write_en == 1){
                    data[data_addr] = top->Dmem_data_wr1_cpp;
                    data[data_addr+1] = top->Dmem_data_wr2_cpp;
                    data[data_addr+2] = top->Dmem_data_wr3_cpp;
                    data[data_addr+3] = top->Dmem_data_wr4_cpp;
                }
                else if(top->Dmem_write_en == 2){
                    data[data_addr] = top->Dmem_data_wr1_cpp;
                    data[data_addr+1] = top->Dmem_data_wr2_cpp;
                }
                else if(top->Dmem_write_en == 3){
                    data[data_addr] = top->Dmem_data_wr1_cpp;
                }
                //Module Read Data
                top->Dmem_data_read_cpp = ((0x000000ff & (int) data[data_addr+3]) << 24) | ((0x000000ff & (int) data[data_addr+2]) << 16) | ((0x000000ff & (int) data[data_addr+1]) << 8) | (0x000000ff & (int)data[data_addr]);
            }

        }

        //contextp->timeInc(1);
        top->eval();            // Evaluate model
        tfp->dump(main_time);

        main_time++;            // Time passes...
    }

    if (file_out.is_open()){
        for(int i = 0; i<200; i=i+4)
        file_out << std::hex << (((0x000000ff & (int) data[i+3]) << 24) | ((0x000000ff & (int) data[i+2]) << 16) | ((0x000000ff & (int) data[i+1]) << 8) | (0x000000ff & (int)data[i]))<< '\n';
        file_out.close();
    }
    delete[] instructions;
    delete[] data;
    tfp->close();
    top->final();               // Done simulating
    //    // (Though this example doesn't get here)
    delete top;
}
