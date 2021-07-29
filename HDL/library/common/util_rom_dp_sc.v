`timescale 1ns / 1ps

module util_rom_dp_sc #(
  parameter ROM_WIDTH = 32,
  parameter ROM_ADDR_BITS = 12,
  parameter PATH_TO_FILE = "path_to_mem_init_file" )(

  input                             clk,
  input        [ROM_ADDR_BITS-1:0]  rom_addra,
  output  reg  [ROM_WIDTH-1:0]      rom_dataa,
  input        [ROM_ADDR_BITS-1:0]  rom_addrb,
  output  reg  [ROM_WIDTH-1:0]      rom_datab);

reg [ROM_WIDTH-1:0] lut_rom [(2**ROM_ADDR_BITS)-1:0];

initial begin
  $readmemb(PATH_TO_FILE, lut_rom, 0, (2**ROM_ADDR_BITS)-1);
end

always @(posedge clk) begin
  rom_dataa = lut_rom[rom_addra];
  rom_datab = lut_rom[rom_addrb];
end

endmodule

