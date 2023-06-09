
`timescale 1 ns / 1 ps

module axis_zeroer #
(
  parameter integer AXIS_TDATA_WIDTH = 32
)
(
  // System signals
  input  wire                        aclk,
  input  wire                        zero,

  // Slave side
  output wire                        s_axis_tready,
  input  wire [AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
  input  wire                        s_axis_tvalid,

  // Master side
  input  wire                        m_axis_tready,
  output wire [AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
  output wire                        m_axis_tvalid
);

  // synchronize zero  
  reg zero_sync;
  always @(posedge aclk)
    zero_sync <= zero;
    

  assign s_axis_tready = m_axis_tready;
//  assign m_axis_tdata = s_axis_tvalid ? s_axis_tdata : {(AXIS_TDATA_WIDTH){1'b0}};
//  assign m_axis_tvalid = 1'b1;

  assign m_axis_tdata = zero_sync ? {(AXIS_TDATA_WIDTH){1'b0}} : s_axis_tdata;
  assign m_axis_tvalid = s_axis_tvalid;
  
endmodule
