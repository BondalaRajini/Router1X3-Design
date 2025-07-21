
module router_fifo(clock,resetn,write_enb,soft_reset,read_enb,data_in,lfd_state,empty,data_out,full);
input clock,resetn,write_enb,soft_reset,read_enb,lfd_state;
input [7:0]data_in;
output empty,full;
output reg [7:0]data_out;
reg [8:0]mem[15:0];
reg [4:0]rp=0,wp=0;
//reg [7:0]count;
integer i;
reg [6:0]count;
always@(posedge clock)
begin
if(!resetn)
    begin
      for(i=0;i<16;i=i+1)
        mem[i]<=0;
		  wp<=0;
    end
else if(soft_reset)
    begin
      for(i=0;i<16;i=i+1)
        mem[i]<=0;
    end
else if(write_enb && !full)
    begin
	 mem[wp[3:0]]<={lfd_state,data_in};
	 wp<=wp+1;
	 end
end
//read operation
always@(posedge clock)
begin
   if(!resetn)
	   data_out<=8'h0;
	else if(soft_reset)
	   data_out<=8'hz;
	else 
	begin
	    if(read_enb && !empty)
	     begin
	         data_out<=mem[rp[3:0]];
		         rp<=rp+1;
		  end
	    else 
		  begin
		 if(count==0 && data_out != 0)
	        begin
	           data_out<=8'hz;
				  end
	      
	end
	end
end
//internal counter logic
always@(posedge clock)
begin
   if(!resetn)
	   count<=7'h0;
	else if(soft_reset)
	   count<=7'h0;
   else if(read_enb && !empty)
	begin
	     if(mem[rp[3:0]][8]==1'b1)
	         count<=mem[rp[3:0]][7:2]+5'h1;
		  else if(count != 7'h0)
		      count<=count-1;
   end
end
assign full=(wp=={~rp[4],rp[3:0]})?1'b1:1'b0;
assign empty=(wp==rp)?1'b1:1'b0;
endmodule
	 
	 
	 
	 
