module router_FIFO_tb();
reg clock,resetn,soft_reset_write_enb,read_enb,lfd_state;
reg[7:0] data_in;
wire[7:0]data_out;

parameter period = 10;
reg[7:0]header,parity;
reg[1:0]addr;
imteger i;
router_FIFO DUT(clock,resetn,soft_reset,write_enb,read_enb,lfd_state,data_in,full,empty,data_out);

initial
	begin
		clock=1'b0;
		forever#(period/2)clock=~clock;
	end
	task rst();
	 begin
	  @(negedge clock)
	  resetn=1'b0;
	  @(negedge clock)
	  resetn=1'b1;
	 end
	endtask
	task soft_rst();
	 begin
	  @(negedge clock)
	  soft_reset=1'b1;
	  @(negedge clock)
	  soft_reset=1'b0;
	end endtask
	task initialize();
	 begin
	  write_enb=1,b0;
	  soft_reset=1'b0;
	  read_enb=1'b0;
	  data_in=0;
	  lfd_state=1'b0;
	 end
	endtask

// Read and Write Test block

task pkt_gen;
	reg[7:0]payload_data;
	reg[5:0]payload_len;
	 begin
	 @(negedge clock);
	 payload_len=6'd14;
	 addr=2'b01;
	 header=(payload_len,addr);
	 data_in=header;
	 lfd_state=1'b1;write_enb=1;
	  for(i=0;i<payload_len;i=i+1)
	 begin
	 @(negedge clock);
	 lfd_state=0;
	 payload_data=($random)%256;
	 data_in=payload_data;
	 end
	 @(negedge clock);
	 parity=($random)%256;
	 data-in=parity;
	 end
endtask
	 
	 initial
	 begin
	 rst();
	 soft_rst;
	 pkt_gen;
	 
	 repeat(2)
	 @(negedge clock);
	 read_enb=1;
	 write_enb=0;
	 @(negedge clock);
	 wait(empty)
	  @(negedge clock);
	 read_enb=0;
	 
	 #100$finish;
	 end
	 
	 initial
	 begin
	 $dumpfile("router_FIFO_tb.vcd");
	 $dumpvars();
	 end
endmodule
	 
	
