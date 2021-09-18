
top_module=top_core
cpp_module=module_compliance
test_dir="\/home\/william\/riscv-arch-test\/work\/rv32i_m\/I\/"
testcase="add-01"
PATH=/opt/riscv/bin:$PATH

if [ "$1" = "lint" ]; then
	echo "Linting"
	verilator --lint-only -y Src_v --top-module $top_module $top_module.v

elif [ "$1" = "build" ]; then
	echo "Building"
	cd Src_c
	make clean
	make
	riscv64-unknown-linux-gnu-objdump -D main.elf > dump.txt
	riscv64-unknown-linux-gnu-objcopy -O binary --change-section-address .data=0xC8 --pad-to 0x190 main.elf test_prog.bin

elif [ "$1" = "target" ]; then
	echo "Setting target"
	testcase="$2"
	cd Testbenches
	rm module_compliance.h
	vim -c "s/^/#define testcase \"$testcase\"\r#define test_dir \"$test_dir\"/" -c "wq" module_compliance.h

elif [ "$1" = "sim" ]; then
	echo "Verilating"
	verilator --trace --cc --exe -y Src_v Testbenches/$cpp_module.cpp --top-module "$top_module" "$top_module".v
	cd obj_dir
	make -f V"$top_module".mk
	cd ../Testbenches
	echo "Building Testbench"
	g++ -I ../obj_dir -I/usr/share/verilator/include "$cpp_module".cpp /usr/share/verilator/include/verilated.cpp /usr/share/verilator/include/verilated_vcd_c.cpp ../obj_dir/V"$top_module"__ALL.a -o "$top_module".out
	echo "Simulating"
	./"$top_module".out

elif [ "$1" = "wave" ]; then
	cd Testbenches
	gtkwave trace.vcd	
fi


