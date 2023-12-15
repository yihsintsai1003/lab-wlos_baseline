// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

// `default_nettype wire
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module WB_decoder(
    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,
    /*
    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,
    */
    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] user_irq
);



wire exmem_ack_o;
wire [31:0] exmem_data_o;
wire uart_ack_o;
wire [31:0] uart_data_o;

user_proj_exmemfir exmemfir1(   
                .wb_clk_i(wb_clk_i),
                .wb_rst_i(wb_rst_i),
                .wbs_stb_i(wbs_stb_i), 
                .wbs_cyc_i(wbs_cyc_i), 
                .wbs_we_i(wbs_we_i),
                .wbs_sel_i(wbs_sel_i),
                .wbs_dat_i(wbs_dat_i),
                .wbs_adr_i(wbs_adr_i),
                .wbs_ack_o(exmem_ack_o),
                .wbs_dat_o(exmem_data_o)
                /*,
             // Logic Analyzer Signals
                .la_data_in(la_data_in),
                .la_data_out(la_data_out),
                .la_oenb(la_oenb),
	    	 // IOs
                .io_in(io_in),
                .io_out(io_out_exmem),
                .io_oeb(io_oeb_exmem),
	    	 // IRQ
                .irq(user_irq_exmem)*/
);

uart uart (
    .wb_clk_i(wb_clk_i),
    .wb_rst_i(wb_rst_i),
    
    // MGMT SoC Wishbone Slave

    .wbs_stb_i(wbs_stb_i), 
    .wbs_cyc_i(wbs_cyc_i), 
    .wbs_we_i(wbs_we_i),
    .wbs_sel_i(wbs_sel_i),
    .wbs_dat_i(wbs_dat_i),
    .wbs_adr_i(wbs_adr_i),
    .wbs_ack_o(uart_ack_o),
    .wbs_dat_o(uart_data_o),

    // IO ports
    .io_in  (io_in),
    .io_out (io_out),
    .io_oeb (io_oeb),

    // irq
    .user_irq (user_irq)
);


assign wbs_ack_o = (wbs_adr_i[31:24]==8'h30) ? uart_ack_o :
                   (wbs_adr_i[31:24]==8'h38) ? exmem_ack_o : 1'b0;
assign wbs_dat_o = (wbs_adr_i[31:24]==8'h30) ? uart_data_o :
                   (wbs_adr_i[31:24]==8'h38) ? exmem_data_o : 1'b0;
                   
endmodule

`default_nettype wire
