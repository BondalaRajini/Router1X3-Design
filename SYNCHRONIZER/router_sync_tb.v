
module router_sync_tb();

reg detect_add,write_enb_reg,clock,resetn,
		empty_0,empty_1,empty_2,full_0,full_1,full_2,
		read_enb_0,read_enb_1,read_enb_2;
reg [1:0]data_in;
wire vld_out_0,vld_out_1,vld_out_2;
wire fifo_full,soft_reset_0,soft_reset_1,soft_reset_2;
wire [2:0]write_enb;

router_sync dut(detect_add,data_in,write_enb_reg,clock,resetn,
						 empty_0,empty_1,empty_2,full_0,full_1,full_2,
						 read_enb_0,read_enb_1,read_enb_2,
						 write_enb,fifo_full,
						 vld_out_0,vld_out_1,vld_out_2,
						 soft_reset_0,soft_reset_1,soft_reset_2);
		
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

initial
begin
RESET;
@(negedge clock)
detect_add=1'b1;
data_in=2'b10;
@(negedge clock)
detect_add=1'b0;
write_enb_reg=1'b1;
@(negedge clock)
{full_0,full_1,full_2}=3'b001;
@(negedge clock)
{empty_0,empty_1,empty_2}=3'b110;
@(negedge clock)
{read_enb_0,read_enb_1,read_enb_2}=3'b000;
#500;
end
endmodule
