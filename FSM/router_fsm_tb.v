module router_fsm_tb();
reg clock,resetn,pkt_valid,parity_done,
      soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
		low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
reg [1:0]data_in;
wire detect_add,ld_state,laf_state,full_state,write_enb_reg,
		 rst_int_reg,lfd_state,busy;
router_fsm dut(clock,resetn,pkt_valid,parity_done,data_in,
                  soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
						low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
						detect_add,ld_state,laf_state,full_state,write_enb_reg,
						rst_int_reg,lfd_state,busy);
initial
begin
clock=1'b0;
forever #10 clock=~clock;
end

task RESET();
begin
@(negedge clock)
resetn=1'b0;
@(negedge clock)
resetn=1'b1;
end
endtask

task SOFT_RESET;
begin
@(negedge clock)
{soft_reset_2,soft_reset_1,soft_reset_0}=3'b010;
@(negedge clock)
{soft_reset_2,soft_reset_1,soft_reset_0}=3'b000;
end
endtask

task TASK1;
begin
@(negedge clock)
pkt_valid=1'b1;
data_in=2'b01;
fifo_empty_1=1'b1;
@(negedge clock)
@(negedge clock)
fifo_full=1'b0;
pkt_valid=1'b0;
@(negedge clock)
@(negedge clock)
fifo_full=1'b0;
end
endtask

task TASK2;
begin
@(negedge clock)
pkt_valid=1'b1;
data_in=2'b01;
fifo_empty_1=1'b1;
@(negedge clock)
@(negedge clock)
fifo_full=1'b1;
@(negedge clock)
fifo_full=1'b0;
@(negedge clock)
parity_done=1'b0;
low_pkt_valid=1'b1;
@(negedge clock)
@(negedge clock)
fifo_full=0;
end
endtask

task TASK3;
begin
@(negedge clock)
pkt_valid=1'b1;
data_in=2'b01;
fifo_empty_1=1'b1;
@(negedge clock)
@(negedge clock)
fifo_full=1'b1;
@(negedge clock)
fifo_full=1'b0;
@(negedge clock)
parity_done=1'b0;
low_pkt_valid=1'b0;
@(negedge clock)
fifo_full=1'b0;
pkt_valid=1'b0;
@(negedge clock)
@(negedge clock)
fifo_full=0;
end
endtask

task TASK4;
begin
@(negedge clock)
pkt_valid=1'b1;
data_in=2'b01;
fifo_empty_1=1'b1;
@(negedge clock)
@(negedge clock)
fifo_full=1'b0;
pkt_valid=1'b0;
@(negedge clock)
@(negedge clock)
fifo_full=1'b1;
@(negedge clock)
fifo_full=1'b0;
@(negedge clock)
parity_done=1'b1;
end
endtask

initial
begin
RESET;
SOFT_RESET;
/*TASK1;
RESET;
TASK2;
RESET;
TASK3;
RESET;*/
TASK4;
end
initial $monitor("reset=%d,state=%d,nxt_state=%d",resetn,dut.state,dut.nxt_state);
initial #10000 $finish;
endmodule

