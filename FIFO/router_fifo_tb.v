
module router_fifo_tb();
reg clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
reg [7:0]data_in;
wire empty,full;
wire [7:0]data_out;
router_fifo dut(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);

initial 
begin
clock=1'b0;
forever #10 clock=~clock;
end

task initialise;
begin
{write_enb,read_enb,data_in}=0;
end
endtask

task RESET;
begin
@(negedge clock);
resetn=1'b0;
@(negedge clock);
resetn=1'b1;
end
endtask

task SOFT_RESET;
begin
@(negedge clock)
soft_reset=1'b1;
@(negedge clock)
soft_reset=1'b0;
end
endtask

task enables(input re);
begin
//write_enb=0;
read_enb=re;
end
endtask

task write;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
integer k;
begin
@(negedge clock)
payload_len=6'd5;
addr=2'b01;
header={payload_len,addr};
data_in=header;
lfd_state=1'b1;
write_enb=1;
for(k=0;k<payload_len;k=k+1)
begin
@(negedge clock)
lfd_state=0;
payload_data={$random}%256;
data_in=payload_data;
end
@(negedge clock)
parity={$random}%256;
data_in=parity;
end
endtask

task read;
begin
write_enb=0;
read_enb=1;
end
endtask

initial
begin
initialise;
RESET;
SOFT_RESET;
write;
//enables(1,0);
repeat(14)
@(negedge clock)
repeat(14)
read;
///enables(1);
repeat(14)
@(negedge clock);

//enables(0);
end
initial $monitor("rst=%b,srst=%b,we=%b,re=%b,empty=%b,full=%b,mem[5]=%b,wp=%b,rp=%b",resetn,soft_reset,write_enb,read_enb,empty,full,dut.mem[5],dut.wp,dut.rp);
initial #10000 $finish;
endmodule


