#include <verilated.h>          // Defines common routines
#include <iostream>             // Need std::cout
#include "Valu_i.h"               // From Verilating "top.v"
#include <verilated_vcd_c.h>
#include <memory>
#include <stdlib.h>
#include <random>
#include <fstream>
#include <iomanip>

using namespace std;
Valu_i *top;                      // Instantiation of model

vluint64_t main_time = 0;       // Current simulation time


std::default_random_engine generator;
std::uniform_int_distribution<int> distribution(-2147483648,2147483647);

double sc_time_stamp() {        // Called by $time in Verilog
    return main_time;           // converts to double, to match
                                // what SystemC does
}


int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);   // Remember args

    Verilated::traceEverOn(true);

    ofstream file_out( "alu_tests.txt");
    top = new Valu_i;             // Create model

    int a;
    int b;
    int c;
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);  // Trace 99 levels of hierarchy
    tfp->open("trace.vcd");


    top->A = 0;
    top->B = 0;
    top->Code = 0;
    top->Sel = 0;

    while (!Verilated::gotFinish() && main_time<1000) {
        if (main_time != 0 && file_out.is_open()){
            if (main_time % 5 == 0) {
                a = distribution(generator);
                b = distribution(generator);
                top->A = a;
                top->B = b;
                if (main_time <100){
                    top->Code = 0;
                    top->Sel = 0;
                    c = a+b;
                    file_out << setw (11) << a << setw (5) << " + " << setw (11)<< b << " = " << setw (11) << c << " : ";                
                }
                else if (main_time >=100 && main_time<200){
                    top->Code = 0;
                    top->Sel = 1;
                    c = a-b;
                    file_out << setw (11) << a << setw (5) << " - " << setw (11)<< b << " = " << setw (11) << c << " : "; 
              
                }                
                else if (main_time >=200 && main_time<300){
                    top->Code = 1;
                    top->Sel = 0;
                    c = a<<(b%32);
                    file_out << setw (11) << a << setw (5) << " SLL " << setw (11)<< abs(b%32) << " = " << setw (11) << c << " : "; 
               
                }
                else if (main_time >=300 && main_time<400){
                    top->Code = 2;
                    top->Sel = 0;
                    c = a>>(b%32); //Documentation says signed shift is implementation dependent
                    file_out << setw (11) << a << setw (5) << " SRA " << setw (11)<< abs(b%32) << " = " << setw (11) << c << " : ";                  
                }
                else if (main_time >=400 && main_time<500){
                    top->Code = 3;
                    top->Sel = 0;
                    c = a ^ b; 
                    file_out << setw (11) << a << setw (5) << " XOR " << setw (11)<< b << " = " << setw (11) << c << " : ";                 
                }
                else if (main_time >=500 && main_time<600){
                    top->Code = 4;
                    top->Sel = 0;
                    c = a | b; 
                    file_out << setw (11) << a << setw (5) << " OR " << setw (11)<< b << " = " << setw (11) << c << " : ";                 
                }    
                else if (main_time >=600 && main_time<700){
                    top->Code = 5;
                    top->Sel = 0;
                    c = a & b; 
                    file_out << setw (11) << a << setw (5) << " AND " << setw (11)<< b << " = " << setw (11) << c << " : "; 
                }
                else if (main_time >=700 && main_time<800){
                    top->Code = 2;
                    top->Sel = 1;
                    c = (unsigned)a>>((unsigned)b%32); 
                    file_out << setw (11) << a << setw (5) << " SRL " << setw (11)<< abs(b%32) << " = " << setw (11) << c << " : "; 
                }                                                 
                else{
                    top->Code = 6;
                    top->Sel = 0;
                    if(a<b)
                        c = 1;
                    else
                        c = 0; 
                    file_out << setw (11) << a << setw (5) << " SLT " << setw (11)<< b << " = " << setw (11) << c << " : ";                
                }
                top->eval();            // Evaluate model  
                if(top->C == c)
                    file_out << "Pass\n";
                else
                    file_out << "Fail : dut result = " << top->C << "\n";                                  
            }
        }

        tfp->dump(main_time);
        main_time++;            
    }
    file_out.close();
    tfp->close();
    top->final();               // Done simulating

    delete top;
}
