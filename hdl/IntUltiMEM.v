`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    14:01:43 02/23/2020 
// Design Name: 
// Module Name:    IntUltiMEM 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module IntUltiMEM(
                  input clock,
                  input _reset,
                  output phi0_cpu,
                  input phi1_cpu,
                  input phi2_cpu,
                  input [15:0]address_cpu,
                  inout [7:0]data_cpu,
                  input r_w_cpu,
                  input phi0_bus,
                  output phi1_bus,
                  output phi2_bus,
                  output [15:0]address_bus,
                  inout [7:0]data_bus,
                  output r_w_bus,
                  output [18:0]address_mem,
                  inout [7:0]data_mem,
                  output _ce_ram,
                  output _ce_rom,
                  output _we_mem,
                  inout [13:0]address_vic,
                  inout [11:0]data_vic
                 );

wire [7:0]blk;
wire [3:0]ram;
wire char;
wire color;
wire ce_vic;
wire [2:1]ce_via;
wire [3:2]ce_io;
wire s02;
wire ce_ram_cpu;
wire ce_rom_cpu;
wire ce_mem_cpu;
wire ce_char_vic;
wire va13;

reg [7:0]data_bus_out;
reg [7:0]data_cpu_out;
reg [7:0]data_mem_out;
reg [11:0]data_vic_out;
reg [15:12]address_vic_out;

assign s02 =                     phi2_cpu | phi0_bus;

assign blk[0] =                  s02 & (address_cpu[15:13] == 0);
assign blk[1] =                  s02 & (address_cpu[15:13] == 1);
assign blk[2] =                  s02 & (address_cpu[15:13] == 2);
assign blk[3] =                  s02 & (address_cpu[15:13] == 3);
assign blk[4] =                  s02 & (address_cpu[15:13] == 4);
assign blk[5] =                  s02 & (address_cpu[15:13] == 5);
assign blk[6] =                  s02 & (address_cpu[15:13] == 6);
assign blk[7] =                  s02 & (address_cpu[15:13] == 7);
assign ram[0] =                  blk[0] & (address_cpu[12:10] == 0);
assign ram[1] =                  blk[0] & (address_cpu[12:10] == 1);
assign ram[2] =                  blk[0] & (address_cpu[12:10] == 2);
assign ram[3] =                  blk[0] & (address_cpu[12:10] == 3);
assign char =                    s02 & (address_cpu[15:12] == 4'h8);
assign color =                   phi0_bus & (address_cpu[15:11] == 5'b10011);
assign ce_via[1] =               phi0_bus & (address_cpu[15:4] == 12'h911);
assign ce_via[2] =               phi0_bus & (address_cpu[15:4] == 12'h912);
assign ce_io[2] =                phi0_bus & (address_cpu[15:10] == 6'b100110);
assign ce_io[3] =                phi0_bus & (address_cpu[15:10] == 6'b100111);
assign ce_vic =                  s02 & (address_cpu[15:4] == 12'h900);

assign ce_char_vic =             (address_vic[13:0] < 14'h1000);
assign va13 =                    ((address_cpu[15:13] == 4) ? 0 : 1);

assign phi0_cpu =                phi0_bus;
assign phi1_bus =                !phi0_bus; //phi1_cpu;
assign phi2_bus =                phi0_bus; //phi2_cpu;
assign address_bus =             address_cpu;
assign r_w_bus =                 r_w_cpu;
assign data_bus =                data_bus_out;
assign data_cpu =                data_cpu_out;
assign data_mem =                data_mem_out;
assign data_vic =                data_vic_out;

assign address_mem =             (phi0_bus ? {3'b0, address_cpu} : {3'b0, address_vic_out , address_vic[11:0]});
assign _we_mem =                 (phi0_bus ? r_w_cpu : 1);   // always read on VIC half of cycle
assign ce_ram_cpu =              (
                                  0
                                  //| !r_w_cpu // RAM always on write...
                                  | blk[0]
                                  //| (address_cpu < 16'h2000)  // screen ram
                                  //| (!ce_via1 & !ce_via2 & !ce_vic & !ce_rom)
                                  | ram[1]
                                  | ram[2]
                                  | ram[3]
                                  | blk[1] 
                                  | blk[2] 
                                  | blk[3] 
                                  | blk[5]
                                  | color
                                  //| ce_io2
                                  //| ce_io3
                                  //| (phi0 & (address_cpu[15:4] >= 12'h913) & (address_cpu[15:4] < 12'h940))
                                 );

assign ce_rom_cpu =              (
                                  0
                                  | char
                                  | blk[6]
                                  | blk[7]
                                 );
assign ce_rom_vic =              (ce_char_vic ? 1 : 0);
assign ce_ram_vic =              !ce_rom_vic;
assign _ce_ram =                 !(phi0_bus ? ce_ram_cpu : ce_ram_vic);
assign _ce_rom =                 !(phi0_bus ? ce_rom_cpu : ce_rom_vic);

assign ce_mem_cpu =              ce_rom_cpu | ce_ram_cpu;

assign address_vic =             (phi0_bus ? {va13, address_cpu[12:0]} : 14'bz); // place bus address on vic lines on phi0


always @(*)
begin
   if(r_w_cpu & ce_mem_cpu)
      data_cpu_out = data_mem;      // cpu read from internal RAM/ROM
   else if (r_w_cpu & ce_vic)
      data_cpu_out = data_vic[7:0]; // cpu read from VIC-I
   else if (r_w_cpu)
      data_cpu_out = data_bus;      // cpu read from motherboard
   else
      data_cpu_out = 8'bz;          // not a read
end

always @(*)
begin
   if(r_w_cpu)
      data_bus_out = 8'bz;          // bus output inactive on read
   else
      data_bus_out = data_cpu;      // on write, bus gets cpu value always
end

always @(*)
begin
   if(phi0_bus & !r_w_cpu)               // always place data on memory bus during write.
      data_mem_out = data_cpu;
   else
      data_mem_out = 8'bz;
end

always @(*)
begin
   if(s02 & !r_w_cpu)         // if cpu write, send CPU value
      data_vic_out = {4'h0, data_cpu};
   else if(!s02)              // if vic, send data.
      data_vic_out = {4'h6, data_mem};
   else
      data_vic_out = {12'bz};
end

always @(*)
begin
   case (address_vic[13:12])
      0: address_vic_out = 4'b1000;
      1: address_vic_out = 4'b1001;
      2: address_vic_out = 4'b0000;
      3: address_vic_out = 4'b0001;
   endcase
end

endmodule
