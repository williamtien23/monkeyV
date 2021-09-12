ENTRY(_start)

MEMORY
{
  CODE(rx):ORIGIN = 0x0000, LENGTH = 200  
  SRAM(rx):ORIGIN = 0xC8, LENGTH = 200
}

SECTIONS
{
  .text :
  {
    *(.text)
  }> CODE

  .data :
  {
    *(.sdata)
  }> SRAM AT>CODE

  .bss :
  {
    *(.sbss)
  }> SRAM
}
