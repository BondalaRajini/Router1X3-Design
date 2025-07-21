
module router_top_tb;
reg clock,resetn,read_enb_0,read_enb_1,read_enb_2,pkt_valid;
reg [7:0]data_in;
wire vld_out_0,vld_out_1,vld_out_2,error,busy;
wire [7:0]data_out_0,data_out_1,data_out_2;

router_top dut(clock,resetn,read_enb_0,read_enb_1,read_enb_2,data_in,pkt_valid,
                  data_out_0,data_out_1,data_out_2,vld_out_0,vld_out_1,vld_out_2,
						error,busy);
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

//payload length 14 packet generation
task pkt_gen_14;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
begin
@(negedge clock)
   wait(~busy)
@(negedge clock)
    payload_len=6'd14;
	 addr=2'b01;//valid packet;
	 header={payload_len,addr};
	 parity=1'b0;
	 data_in=header;
	 pkt_valid=1'b1;
	 parity=parity^header;
@(negedge clock)
    wait(~busy)
	   for(i=0;i<payload_len;i=i+1)
		  begin
		     @(negedge clock)
			     wait(~busy)
				  payload_data={$random}%256;
				  data_in=payload_data;
				  parity=parity^payload_data;
		  end
@(negedge clock)
    wait(~busy)
	 pkt_valid=1'b0;
	 data_in=parity;
end
endtask

//payload length <14 packet generation
task pkt_gen_9;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
begin
@(negedge clock)
   wait(~busy)
@(negedge clock)
    payload_len=6'd9;
	 addr=2'b01;//valid packet;
	 header={payload_len,addr};
	 parity=1'b0;
	 data_in=header;
	 pkt_valid=1'b1;
	 parity=parity^header;
@(negedge clock)
    wait(~busy)
	   for(i=0;i<payload_len;i=i+1)
		  begin
		     @(negedge clock)
			     wait(~busy)
				  payload_data={$random}%256;
				  data_in=payload_data;
				  parity=parity^payload_data;
		  end
@(negedge clock)
    wait(~busy)
	 pkt_valid=1'b0;
	 data_in=parity;
end
endtask


//payload lenth 17 packet generation
task pkt_gen_17;
reg [7:0]payload_data,parity,header;
reg [5:0]payload_len;
reg [1:0]addr;
begin
@(negedge clock)
   wait(~busy)
@(negedge clock)
    payload_len=6'd20;
	 addr=2'b01;//valid packet;
	 header={payload_len,addr};
	 parity=1'b0;
	 data_in=header;
	 pkt_valid=1'b1;
	 parity=parity^header;
@(negedge clock)
    wait(~busy)
	   for(i=0;i<payload_len;i=i+1)
		  begin
		     @(negedge clock)
			     wait(~busy)
				  payload_data={$random}%256;
				  data_in=payload_data;
				  parity=parity^payload_data;
		  end
@(negedge clock)
    wait(~busy)
	 pkt_valid=1'b0;
	 data_in=parity;
end
endtask


initial
 begin
  RESET;
  //repeat(3)
@(negedge clock)
  pkt_gen_17;
@(negedge clock)
  read_enb_1=1'b1;
  //repeat(14)
  wait(~vld_out_1)

@(negedge clock)
  read_enb_1=1'b0;
end
initial $monitor("%d",dut.fifo_1.mem[16]);
endmodule
