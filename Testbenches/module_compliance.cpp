#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Vtop_core.h"          // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <memory>
#include <stdlib.h>
#include <fstream>
#include <string>
#include <iomanip>
#include "module_compliance.h"

using namespace std;

//Globals
Vtop_core *top;                 // Instantiation of model
int startsig =0;
int stopsig =19200;             //Problem with sltiu test case, don't touch this value
vluint64_t main_time = 0;       // Current simulation time

//Function Prototypes
void copy_bin(char * mem);
void sig_mem_bounds_init();
int read_word (char * mem, unsigned int addr);
void copy_sig(char * mem);
double sc_time_stamp();

//Main
int main(int argc, char** argv, char** env) {
    
    Verilated::commandArgs(argc, argv);   // Remember args
    VerilatedVcdC* tfp = new VerilatedVcdC;
    Verilated::traceEverOn(true);


    top = new Vtop_core;             // Create model
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy    
    top->Clk = 0;
    top->Reset = 1;
    top->Imem_data_read_cpp = 0;
    top->Dmem_data_read_cpp = 0;
    tfp->open("trace.vcd");

    int data_addr;
    char * flash;
    flash = new char [2097152]; //Worth 2 MiB

    copy_bin(flash); 
    sig_mem_bounds_init();

    //Sim for 500us over 1ns resolution
    while (!Verilated::gotFinish() && main_time<500000) { 
        
        //Reset ends at 15ns
        if(main_time == 15){
            top->Reset = 0;
        }

        //Clock period = 10 ticks (ns)
        if(main_time % 5 == 0){ 
            top->Clk = (top->Clk+1)%2;
        }

        //Poll for Imem and Dmem read/write requests
        if ((main_time % 10 == 5) && main_time>10) { 

            //Module Imem read
            top->Imem_data_read_cpp = read_word(flash, top->Imem_addr_cpp);

            //Module Dmem read/wr
            data_addr = (top->Dmem_addr_cpp);
            if(data_addr >= 0  && data_addr<2097152){ //set virtual bounds
                //Module Write Data
                if(top->Dmem_write_en == 1){
                    flash[data_addr] = top->Dmem_data_wr1_cpp;
                    flash[data_addr+1] = top->Dmem_data_wr2_cpp;
                    flash[data_addr+2] = top->Dmem_data_wr3_cpp;
                    flash[data_addr+3] = top->Dmem_data_wr4_cpp;
                }
                else if(top->Dmem_write_en == 2){
                    flash[data_addr]   = top->Dmem_data_wr1_cpp;
                    flash[data_addr+1] = top->Dmem_data_wr2_cpp;
                }
                else if(top->Dmem_write_en == 3){
                    flash[data_addr] = top->Dmem_data_wr1_cpp;
                }
                //Module Read Data
                top->Dmem_data_read_cpp = read_word(flash, data_addr);
            }
        }
        top->eval();            // Evaluate model
        tfp->dump(main_time);
        main_time++;            // Time passes...
    }
    
    copy_sig(flash);

    delete[] flash;
    tfp->close();   
    top->final();               // Done simulating
    delete top;
}

void copy_bin(char * mem){
    
    streampos size;
    ifstream bin_file( (string)test_dir + (string)testcase + (string)".bin", ios::binary|ios::ate);

    if (bin_file.is_open()){
        size = bin_file.tellg();
        bin_file.seekg (0, ios::beg);
        bin_file.read (mem, size);
        bin_file.close();
    }
    else
        cout << "Problem opening: " << testcase << ".bin" << std::endl;  
}

void sig_mem_bounds_init(){

    string line;
    ifstream elf_file((string)test_dir + (string)testcase + (string)".txt");

    if(elf_file.is_open()){
        while(getline(elf_file, line)) { // I changed this, see below
            if (line.find("<begin_signature>:") != string::npos) {
                startsig = stoi(line.substr(0, line.find(" ")),nullptr,16);
            }
            if (line.find("<end_signature>:") != string::npos) {
                    stopsig = stoi(line.substr(0, line.find(" ")),nullptr,16);
                    break;
            } 
        }
        elf_file.close();
    }
    else
        cout << "Problem opening: " << testcase << ".txt" << std::endl;
}

int read_word (char * mem, unsigned int addr){

    int byte4, byte3, byte2, byte1; //byte 4 is MSB

    byte4 = (0x000000ff & (int) mem[addr+3]) << 24;
    byte3 = (0x000000ff & (int) mem[addr+2]) << 16;
    byte2 = (0x000000ff & (int) mem[addr+1]) << 8;
    byte1 = (0x000000ff & (int) mem[addr]);

    return(byte4 | byte3 | byte2 | byte1);
}


void copy_sig(char * mem){
    
    ofstream signature_file( (string)test_dir + (string)testcase + ".signature.output");

    if (signature_file.is_open()){ 
        for(int i = startsig; i<stopsig; i=i+4)
            signature_file << setfill('0') << setw(8) <<std::hex << read_word(mem, i) << '\n';
        signature_file.close();
    }
    else
        cout << "Problem writing sig file to: " << testcase << std::endl; 
}

double sc_time_stamp() {        // Called by $time in Verilog
    return main_time;           // converts to double, to match
                                // what SystemC does
}
