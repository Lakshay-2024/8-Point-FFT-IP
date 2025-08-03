`timescale 1ns / 1ps


module axi_protocol_slave(

input wire start,
output wire [3:0] leds,

		
input wire S_AXI_ACLK,
input wire S_AXI_ARESETN,


input wire [31:0] S_AXI_AWADDR,
input wire S_AXI_AWVALID,
output wire S_AXI_AWREADY,


input wire [31:0] S_AXI_WDATA,
input wire [3:0] S_AXI_WSTRB,
input wire S_AXI_WVALID,
output wire S_AXI_WREADY,



output wire [1:0] S_AXI_BRESP,
output wire S_AXI_BVALID,
input wire S_AXI_BREADY,


input wire [31:0] S_AXI_ARADDR,
input wire S_AXI_ARVALID,
output wire S_AXI_ARREADY,
output wire  [31:0] S_AXI_RDATA,
output wire [1:0] S_AXI_RRESP,
output wire S_AXI_RVALID,
input wire S_AXI_RREADY


    );
    
 wire display;
 wire [3:0] dout;
    
parameter idle = 0;
parameter wr_data = 1;
parameter wr_resp = 2;
parameter r_data = 3;



reg [2:0] state = idle;
reg [31:0] addr_w;
reg [31:0] addr_r;


reg aw_ready;
reg w_ready;
reg b_valid; 
reg [1:0]b_resp ;
reg ar_ready;
reg r_valid;
reg [31:0] r_data1;

reg [1:0]r_resp;


reg [31:0]slv_reg0 =0;
reg [31:0]slv_reg1 =0;
reg [31:0]slv_reg2 = 0;
reg [31:0]slv_reg3 =0;



always@(posedge S_AXI_ACLK)
begin

if(!S_AXI_ARESETN)
begin


aw_ready <=0;
w_ready <=0;
b_valid <=0; 
b_resp <=0 ;
ar_ready <=0;
r_valid <=0;
r_data1 <=0;
r_resp <=0;
state <= idle;
addr_r <=0;
addr_w<=0;
r_valid<=0;
slv_reg0 <=0;
 slv_reg1 <=0;
 slv_reg2 <= 0;
 slv_reg3 <=0;


end

else 
begin

case (state)

idle : begin

        if(S_AXI_AWVALID)
        begin
        addr_w <= S_AXI_AWADDR;
        aw_ready <= 1'b1;
        state <= wr_data; 
        w_ready <=1'b1;
        
        end
        
        else if (S_AXI_ARVALID)
        begin
        
        addr_r <= S_AXI_ARADDR ;
        ar_ready <=1'b1;
        state <= r_data;
        
        
        
        
        end
        
        else 
        begin
        
        aw_ready <=0;
        w_ready <=0;
        b_valid <=0; 
        b_resp <=0 ;
        ar_ready <=0;
        r_valid <=0;
        r_data1 <=0;
        r_resp <=0;
        state <= idle;
        addr_w <=0;
        addr_r <=0;
        
       end





end

wr_data : begin

            if(S_AXI_WVALID)
            begin
            case(addr_w[3:2])
            
            2'h0 : begin
            slv_reg0 <= S_AXI_WDATA;
            end
            
            2'h1 : begin
            slv_reg1 <= S_AXI_WDATA;
            end
            
            2'h2 : begin
            slv_reg2 <= S_AXI_WDATA;
            end
            
            2'h3 : begin
            slv_reg3 <= S_AXI_WDATA;
            end 
            
            default: begin 
            
            slv_reg0 <= slv_reg0;
	        slv_reg1 <= slv_reg1;
	        slv_reg2 <= slv_reg2;
	        slv_reg3 <= slv_reg3;
            
            end
            
            endcase
            w_ready <=0;
            state <= wr_resp;
            end
            else
            begin
            state <= wr_data;
            end
            
           end



wr_resp   : begin

            if(S_AXI_BREADY)
            begin
            b_resp <=2'b0; 
            b_valid <=1'b1; 
            state <=idle; 
            end
            else
            begin
            state <= wr_resp;
            end

            end


r_data : begin
            
            if(S_AXI_RREADY)
            begin
           // Address decoding for reading registers
	      case ( addr_r[3:2] )
	        2'h0   : r_data1 <= slv_reg0;
	        2'h1   : r_data1 <= display;
	        2'h2   : r_data1 <= dout;
	        2'h3   : r_data1 <= slv_reg3;
	        default : r_data1 <= 0;
	      endcase 
           
            r_resp <=2'b0;
            state <= idle;
            r_valid <=1'b1; 
            end
            else
            begin
            state <= r_data;
            end

           end



endcase








end

end



assign S_AXI_AWREADY = aw_ready;
assign S_AXI_WREADY = w_ready;
assign S_AXI_BVALID = b_valid; 
assign S_AXI_BRESP = b_resp;
assign S_AXI_ARREADY = ar_ready;
assign S_AXI_RVALID = r_valid; 
assign S_AXI_RDATA = r_data1;
assign S_AXI_RRESP = r_resp;

assign leds = dout;
    
endmodule
