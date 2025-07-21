
module router_reg_tb;
reg clock,resetn,pkt_valid,fifo_full,rst_int_reg,
    detect_add,ld_state,laf_state,full_state,lfd_state;
reg [7:0]data_in;
wire err,low_pkt_valid,parity_done;
wire [7:0]dout;
router_reg dut(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,
               detect_add,ld_state,laf_state,full_state,lfd_state,
					parity_done,low_pkt_valid,err,dout);
integer i;
	
initial
begin
clock=1'b0;
forever #10 clock=~clock;
end

task RESET;
begin
@(negedge clock)
resetn=1'b0;
@(negedge clock)
resetn=1'b1;
end
endtask

task RESET_INT_REG;
begin
@(negedge clock)
rst_int_reg=1'b1;
@(negedge clock)
rst_int_reg=1'b0;
end
endtask

task packet_generation;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
begin
   @(negedge clock)
      payload_len=6'd14;
      addr=2'b10;//valid packet
      pkt_valid=1'b1;
      detect_add=1'b1;
      header={payload_len,addr};
		data_in=header;
      parity=8'h00^header;
   @(negedge clock)
      detect_add=1'b0;
      lfd_state=1'b1;
      full_state=1'b0;
      fifo_full=1'b0;
      laf_state=1'b0;
for(i=0;i<payload_len;i=i+1)
   begin
      @(negedge clock)
         lfd_state=1'b0;
         ld_state=1'b1;
         payload_data={$random}%256;
         data_in=payload_data;
         parity=parity^data_in;
   end
@(negedge clock)
   pkt_valid=1'b0;
	data_in=8'd1;
@(negedge clock)
   ld_state=1'b0;
end
endtask

initial
begin
RESET;
RESET_INT_REG;
packet_generation;
end
endmodule
