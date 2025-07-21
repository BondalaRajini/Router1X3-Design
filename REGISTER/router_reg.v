
module router_reg(clock,resetn,pkt_valid,data_in,fifo_full,rst_int_reg,
                  detect_add,ld_state,laf_state,full_state,lfd_state,
						parity_done,low_pkt_valid,err,dout);
input clock,resetn,pkt_valid,fifo_full,rst_int_reg,
      detect_add,ld_state,laf_state,full_state,lfd_state;
input [7:0]data_in;

output reg err,low_pkt_valid,parity_done;
output reg [7:0]dout;
reg [7:0]header,packet_parity,internal_parity,full_state_byte;

//dout
always@(posedge clock)
begin
if(!resetn)
  dout<=0;
  else if(!(detect_add&&pkt_valid&&data_in[1:0]!=3))
  begin
  if(lfd_state)
    dout<=header;
  else if(ld_state&&(~fifo_full))
    dout<=data_in;
  else 
     begin
     if(!(ld_state&&fifo_full))
	     if(laf_state)
	         dout<=full_state_byte;
	  end
	end
 end
 always@(posedge clock)
 begin
 if(!resetn)
 full_state_byte<=0;
 else if(full_state)
 full_state_byte<=data_in;
 end
 
 
 //header
 always@(posedge clock)
  begin
  if(!resetn)
    header<=0;
  else if(detect_add&&pkt_valid&&data_in[1:0]!=3)
    header<=data_in;
  end

 //internal parity 
 always@(posedge clock)
 begin
 if(!resetn)
    internal_parity<=0;
 else if(detect_add)
    internal_parity<=0;
 else if(lfd_state)
    internal_parity<=internal_parity^header;
 else if(pkt_valid&&ld_state&&(~full_state))
    internal_parity<=internal_parity^data_in;
 end
 
 //packet_patity 
 always@(posedge clock)
 begin
 if(!resetn)
    packet_parity<=0;
 else if(detect_add)
    packet_parity<=0;
 else if(ld_state&&(~pkt_valid))
    packet_parity<=data_in;
 end
 
 //low packet valid
 always@(posedge clock)
 begin
 if(!resetn || rst_int_reg)
   low_pkt_valid<=1'b0;
 else if(ld_state && !pkt_valid)
	low_pkt_valid<=1'b1;
	else 
	low_pkt_valid<=1'b0;
 end
 
 //parity_done
 always@(posedge clock)
 begin
 if(!resetn||detect_add)
 parity_done<=1'b0;
 else if((ld_state && (!fifo_full && !pkt_valid)) || (laf_state && low_pkt_valid && (!parity_done)))
 parity_done<=1'b1;
 else 
 parity_done<=1'b0;
 end
 
 //error
 always@(posedge clock)
 begin
 if(!resetn)
 err<=0;
 else if(packet_parity==0)
 err<=0;
   else
     begin
   if(packet_parity == internal_parity)
     err<=1'b0;
	 else 
	 err<=1'b1;
	end

 end
 
 endmodule
 