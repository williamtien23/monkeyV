arch_test_path=""
project_dir=""
echo "compliance compilation"
PATH=/opt/riscv/bin:$PATH
cd $arch_test_path
make clean
make compile
cd work/rv32i_m/I
for f in *.elf; do riscv64-unknown-elf-objdump -D $f > "${f%.*}.txt"; done
for f in *.elf; do riscv64-unknown-elf-objcopy -O binary $f "${f%.*}.bin"; done
for f in *.bin
do
  echo "Test for ${f%.*}"
  cd $project_dir &>/dev/null
  bash project.sh target "${f%.*}" &>/dev/null
  rm obj_dir -r &>/dev/null
  bash project.sh sim &>/dev/null
  echo "${f%.*} signature generated"
done
cd $arch_test_path
make verify
echo "done compliance suite run"
