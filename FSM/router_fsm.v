module router_fsm(clock,resetn,pkt_valid,parity_done,data_in,
                  soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
						low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,
						detect_add,ld_state,laf_state,full_state,write_enb_reg,
						rst_int_reg,lfd_state,busy);
input clock,resetn,pkt_valid,parity_done,
      soft_reset_0,soft_reset_1,soft_reset_2,fifo_full,
		low_pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2;
input [1:0]data_in;
output detect_add,ld_state,laf_state,full_state,write_enb_reg,
		 rst_int_reg,lfd_state,busy;
parameter DECODE_ADDRESS=3'b000,
          WAIT_TILL_EMPTY=3'b001,
          LOAD_FIRST_DATA=3'b010,
			 LOAD_DATA=3'b011,
			 FIFO_FULL_STATE=3'b100,
			 LOAD_AFTER_FULL=3'b101,
			 LOAD_PARITY=3'b110,
			 CHECK_PARITY_ERROR=3'b111;
reg [2:0]state,nxt_state;
reg [1:0]temp_add;

always@(posedge clock)
begin
if(!resetn&&(soft_reset_0)||(soft_reset_1)||(soft_reset_2))
state<=DECODE_ADDRESS;
else
state<=nxt_state;
end

always@(posedge clock)
begin
if(!resetn)
temp_add<=2'b0;
else if(detect_add)
temp_add<=data_in;
end


always@(*)
begin
nxt_state<=DECODE_ADDRESS;

  case(state)
  DECODE_ADDRESS:if((pkt_valid & (data_in[1:0]==0) & !fifo_empty_0)|
                    (pkt_valid & (data_in[1:0]==1) & !fifo_empty_1)|
						  (pkt_valid & (data_in[1:0]==2) & !fifo_empty_2))
						  nxt_state<=WAIT_TILL_EMPTY;
						else if((pkt_valid & (data_in[1:0]==0) & fifo_empty_0)|
                          (pkt_valid & (data_in[1:0]==1) & fifo_empty_1)|
						        (pkt_valid & (data_in[1:0]==2) & fifo_empty_2))
						   nxt_state<=LOAD_FIRST_DATA;
						else
						  nxt_state<=DECODE_ADDRESS;
 WAIT_TILL_EMPTY:if((fifo_empty_0 && (temp_add == 0))||
                    (fifo_empty_1 && (temp_add == 1))||
                    (fifo_empty_2 && (temp_add == 2)))
                  nxt_state<=LOAD_FIRST_DATA;
                  else
                  nxt_state<=WAIT_TILL_EMPTY;
 LOAD_FIRST_DATA:nxt_state<=LOAD_DATA;
 
       LOAD_DATA:if(!fifo_full && !pkt_valid)
		            nxt_state<=LOAD_PARITY;
						else if(fifo_full)
						nxt_state<=FIFO_FULL_STATE;
						else
						nxt_state<=LOAD_DATA;
 FIFO_FULL_STATE:if(!fifo_full)
                 nxt_state<=LOAD_AFTER_FULL;
					  else if(fifo_full)
					  nxt_state<=FIFO_FULL_STATE;
 LOAD_AFTER_FULL:if(!parity_done && !low_pkt_valid)
                 nxt_state<=LOAD_DATA;
					  else if(!parity_done && low_pkt_valid)
					  nxt_state<=LOAD_PARITY;
					  else if(parity_done)
					  nxt_state<=DECODE_ADDRESS;
     LOAD_PARITY:nxt_state<=CHECK_PARITY_ERROR;
CHECK_PARITY_ERROR:if(!fifo_full)
                   nxt_state<=DECODE_ADDRESS;
						 else if(fifo_full)
						 nxt_state<=FIFO_FULL_STATE;
endcase
end
assign detect_add=(state==DECODE_ADDRESS);
assign ld_state=(state==LOAD_DATA);
assign laf_state=(state==LOAD_AFTER_FULL);
assign full_state=(state==FIFO_FULL_STATE);
assign write_enb_reg=(state==LOAD_DATA)||(state==LOAD_PARITY)||(state==LOAD_AFTER_FULL);
assign rst_int_reg=(state==CHECK_PARITY_ERROR);
assign lfd_state=(state==LOAD_FIRST_DATA);
assign busy=((state==WAIT_TILL_EMPTY)||(state==LOAD_FIRST_DATA)||(state==FIFO_FULL_STATE)||
             (state==LOAD_AFTER_FULL)||(state==LOAD_PARITY)||(state==CHECK_PARITY_ERROR));

endmodule
						
						
  
						  
			 
			
