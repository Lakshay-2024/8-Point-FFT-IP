module fft(

input wire clk,
input wire rst,
input wire start,
output wire done,

//Input ports

input wire signed [31:0] in1,
input wire signed [31:0] in2,
input wire signed [31:0] in3,
input wire signed [31:0] in4,
input wire signed [31:0] in5,
input wire signed [31:0] in6,
input wire signed [31:0] in7,
input wire signed [31:0] in8,

//Output Ports For Real Values

output wire signed [31:0] out1_real,
output wire signed [31:0] out2_real,
output wire signed [31:0] out3_real,
output wire signed [31:0] out4_real,
output wire signed [31:0] out5_real,
output wire signed [31:0] out6_real,
output wire signed [31:0] out7_real,
output wire signed [31:0] out8_real,

//Output Ports for imaginary values

output wire signed [31:0] out1_img,
output wire signed [31:0] out2_img,
output wire signed [31:0] out3_img,
output wire signed [31:0] out4_img,
output wire signed [31:0] out5_img,
output wire signed [31:0] out6_img,
output wire signed [31:0] out7_img,
output wire signed [31:0] out8_img

    );
    
// Declaration of Memory 
    
reg signed [31:0] mem_1_real [7:0];
reg signed [31:0] mem_1_img [7:0];
reg signed [31:0] mem_2_real [7:0];
reg signed [31:0] mem_2_img [7:0];

// Registers to fetch data from memory

reg  signed [31:0] a_re;  
reg  signed [31:0] a_im ;  
reg  signed [31:0] b_re ; 
reg  signed [31:0] b_im; 
reg  signed [31:0] c_re;  
reg  signed [31:0] c_im ;  
reg  signed [31:0] d_re ; 
reg  signed [31:0] d_im; 


// Registers to transfer output of logic to output ports

reg  signed [31:0] out_1_real;
reg  signed [31:0] out_2_real;
reg  signed [31:0] out_3_real;
reg  signed [31:0] out_4_real;
reg  signed [31:0] out_5_real;
reg  signed [31:0] out_6_real;
reg  signed [31:0] out_7_real;
reg  signed [31:0] out_8_real;

reg  signed [31:0] out_1_img;
reg  signed [31:0] out_2_img;
reg  signed [31:0] out_3_img;
reg  signed [31:0] out_4_img;
reg  signed [31:0] out_5_img;
reg  signed [31:0] out_6_img;
reg  signed [31:0] out_7_img;
reg  signed [31:0] out_8_img;

// Register For Different states in FSM

reg [3:0] state;
reg done_it;


// Registers for second Stage

reg  signed [31:0] w_re;
reg  signed [31:0] w_im;
  
reg signed[31:0] tw_re;
reg signed[31:0] tw_im;   

integer w_idx;
integer idx1;
integer idx2;

integer i;
integer j;


// Twiddle Factors Defination

// Twiddle factors Wn^k (cos, -sin) in Q1.15 fixed point
reg signed [31:0] W_RE [0:3];   // cos
reg signed [31:0] W_IM [0:3]; // -sin




// Working Logic Implementation

always @ (posedge clk)
begin

//<----------------------------------------If Reset ------------------------------------------------------->

if(!rst)
begin

// Initializing all registers

a_re <= 0;  
a_im <= 0;  
b_re <= 0; 
b_im <= 0; 
c_re <= 0;
c_im <= 0;
d_re <= 0;
d_im <=0;

out_1_real <= 0;
out_2_real <= 0;
out_3_real <= 0;
out_4_real <= 0;
out_5_real <= 0;
out_6_real <= 0;
out_7_real <= 0;
out_8_real <= 0;

out_1_img <= 0;
out_2_img <= 0;
out_3_img <= 0;
out_4_img <= 0;
out_5_img <= 0;
out_6_img <= 0;
out_7_img <= 0;
out_8_img <= 0;


// For Second Stage

w_re <= 0;
w_im <= 0;

tw_re <= 0;
tw_im <= 0;

w_idx <= 0;
idx1 <= 0;
idx2 <= 0;
i <=0;

// Initializing state register

state <=0;
done_it <=0;

// Initializing memory

for( i=0;i<8;i=i+1)
begin

mem_1_real[i] <= 0;
mem_1_img[i] <= 0;
mem_2_real[i] <= 0;
mem_2_img[i] <= 0;


end

  W_RE [0] = 32767;
 W_RE [1] = 23170;
 W_RE [2] = 0;
 W_RE [3] = -23170;

 W_IM[0] = 0;
 W_IM[1] = -23170;
 W_IM[2] = -32767;
 W_IM[3] = -23170;


end


//<---------------------------------// If Reset Off //----------------------------------------------------------------->

else
begin
if(start)
begin

case(state)

3'd0 : begin
        mem_1_real[0] <= in1;
        mem_1_real[1] <= in2;
        mem_1_real[2] <= in3;
        mem_1_real[3] <= in4;
        mem_1_real[4] <= in5;
        mem_1_real[5] <= in6;
        mem_1_real[6] <= in7;
        mem_1_real[7] <= in8;
        
        state <= 3'd1;
        
        
        end

3'd1 : begin
            for( i=0; i<4;i=i+1)
            begin
                a_re = mem_1_real[i];
                a_im = mem_1_img[i];
                b_re = mem_1_real[i+4];
                b_im = mem_1_img[i+4];
                
                mem_2_real[i]    <= a_re + b_re;
                mem_2_img[i]     <= a_im + b_im;
                mem_2_real[i+4]  <= a_re - b_re;
                mem_2_img[i+4]   <= a_im - b_im; 
                
                
                
             end   
             state <= 3'd2;
      end
      

3'd2 : begin
        for (  i = 0; i < 2; i=i+1) begin
                        for (  j = 0; j < 2; j=j+1) begin
                             idx1 = i*4 + j;
                             idx2 = idx1 + 2;

                            a_re = mem_2_real[idx1];
                            a_im = mem_2_img[idx1];
                            b_re = mem_2_real[idx2];
                            b_im = mem_2_img[idx2];

                            w_idx = i*2;
                        
                             
                            w_re = W_RE[w_idx];
                            w_im = W_IM[w_idx];
                             
                            tw_im = (b_re * w_im+ b_im * w_re) >>> 15;
                            tw_re = (b_re * w_re+ b_im * w_im) >>> 15;
                            

                            mem_1_real[idx1] <= a_re + tw_re[31:0];
                            mem_1_img[idx1] <= a_im + tw_im[31:0];
                            mem_1_real[idx2] <= a_re - tw_re[31:0];
                            mem_1_img[idx2] <= a_im - tw_im[31:0];
                        end
                    end  
              state <= 3'd3;          

        end


3'd3 : begin

         for ( i = 0; i < 7; i=i+2) begin
                         
                             idx1 = i;
                             idx2 = i + 1;

                             a_re = mem_1_real[idx1];
                             a_im = mem_1_img[idx1];
                             b_re = mem_1_real[idx2];
                             b_im = mem_1_img[idx2];
                            
                            
                            if(i==0 || i==2)
                            w_idx = i;
                             
                            else if(i==4)
                            w_idx=1;
                            
                            else
                            w_idx=3;
                             
                             
                             w_re = W_RE[w_idx];
                             w_im = W_IM[w_idx];
                             
                             
                             tw_re = (b_re * w_re- b_im * w_im)>>>15;
                             tw_im = (b_re * w_im + b_im * w_re)>>>15;
                              
                             
                             
                            mem_2_real[idx1] <= a_re + tw_re[31:0];
                            mem_2_img[idx1] <= a_im + tw_im[31:0];
                            mem_2_real[idx2] <= a_re - tw_re[31:0];
                            mem_2_img[idx2] <= a_im - tw_im[31:0];
                        
                    end
                    
                    state <= 3'd4; 
                    
             end       


3'd4 : begin
                 a_re <= mem_2_real[1];
                 a_im <= mem_2_img[1];
                 b_re <= mem_2_real[4];
                 b_im <= mem_2_img[4];
                 c_re <= mem_2_real[3];
                 c_im <= mem_2_img[3];
                 d_re <= mem_2_real[6];
                 d_im <= mem_2_img[6];  
                 
                 state <= 3'd5;
                 
        end         


3'd5 : begin

            mem_2_real[1] <= b_re;
            mem_2_img[1] <= b_im;
            mem_2_real[4] <= a_re;
            mem_2_img[4] <= a_im;  
            mem_2_real[3] <= d_re;
            mem_2_img[3] <= d_im;
            mem_2_real[6] <= c_re;
            mem_2_img[6] <= c_im;
            
            state <= 3'd6;
            
       end     
   
3'd6 : begin

        out_1_real <= mem_2_real[0];
        out_2_real <= mem_2_real[1];
        out_3_real <= mem_2_real[2];
        out_4_real <= mem_2_real[3];
        out_5_real <= mem_2_real[4];
        out_6_real <= mem_2_real[5];
        out_7_real <= mem_2_real[6];
        out_8_real <= mem_2_real[7];
        
        
        out_1_img <= mem_2_img[0];
        out_2_img <= mem_2_img[1];        
        out_3_img <= mem_2_img[2];
        out_4_img <= mem_2_img[3];        
        out_5_img <= mem_2_img[4];        
        out_6_img <= mem_2_img[5];       
        out_7_img <= mem_2_img[6];      
        out_8_img <= mem_2_img[7];
        
        done_it <=1'b1;
        
        
        
        
        
        
        
       end 
        
 default : begin
 
            state <= 3'd0;
            
          end         




endcase
end

end
end


// Assignment of the output registers to output ports

assign out1_real = out_1_real;
assign out2_real = out_2_real;
assign out3_real = out_3_real;
assign out4_real = out_4_real;
assign out5_real = out_5_real;
assign out6_real = out_6_real;
assign out7_real = out_7_real;
assign out8_real = out_8_real;

assign out1_img = out_1_img;
assign out2_img = out_2_img;
assign out3_img = out_3_img;
assign out4_img = out_4_img;
assign out5_img = out_5_img;
assign out6_img = out_6_img;
assign out7_img = out_7_img;
assign out8_img = out_8_img;

assign done = done_it;



  
    
endmodule
