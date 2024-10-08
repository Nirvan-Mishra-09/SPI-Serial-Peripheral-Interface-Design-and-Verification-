 module spi_master(
input clk, newd,rst,
input [11:0] din, 
output reg sclk,cs,mosi
    );
  
     typedef enum bit[1:0] {idle = 2'b00, enable = 2'b01, send = 2'b10, comp = 2'b11} state_type;
    state_type state = idle;

    int countc = 0; // this counter counts the clk's of system clk
    int count = 0; // this counter counts the no. of bits transmiited serially

    // generating sclk 

    always @(posedge clk) begin
        if (rst == 1'b1) begin
            countc <= 0;
            sclk <= 0;
            
        end
        else begin
          if (countc < 10) begin	//assuming system clk being 20, so the sclk being fclk/2
                countc <= countc + 1;
            end
            else begin
                countc <= 0;
                sclk <= ~sclk;
            end
        end
    end

    // State machine

    reg [11:0] temp;

    always @(posedge sclk) begin
        if (rst == 1'b1) begin
            cs <= 1'b1;
            mosi <= 1'b0;
        end

        else begin
            case (state) 
            // If in idle state and newd == 1: change state -> send; send data on temp bus; cs -> 0
                idle: begin
                    if(newd == 1'b1) begin
                        state <= send;
                        temp <= din;
                        cs <= 1'b0;
                    end

                    else begin
                        state <= idle;
                        temp <= 8'h00;
                    end
                end
            // If send: 1 bit will be sent at one clock pulse at mosi pin since we have 12 bit data_in therefore as the count reaches 11 -> reset count; state -> idle; cs -> 1; mosi -> 0  
                send: begin
                    if (count <= 11) begin
                        mosi <= temp[count];
                        count <= count + 1;
                    end

                    else begin
                        count <= 0;
                        state <= idle;
                        cs <= 1'b1;
                        mosi <= 1'b0;
                    end
                end 
                default: state <= idle;
            endcase
        end
    end
  
endmodule

module spi_slave(
  input sclk, cs, mosi,
  output [11:0] dout,
  output reg done);
  
  typedef enum bit {detect_start = 1'b0, read_data = 1'b1} state_type;
  state_type state = detect_start;
  int count = 0;
  reg [11:0] temp = 12'h000;
  
  always @ (posedge sclk) begin
    case (state)
      detect_start: begin
        done <= 1'b0;
        if(cs == 1'b0) 
			state <= read_data;
        else 
			state <= detect_start;
      end
      
      read_data: begin
        if (count <= 11) begin
          count <= count + 1;
          temp <= {mosi, temp[11:1]};
        end
        
        else begin
          count <= 0;
          done <= 1'b1;
          state <= detect_start;
        end
      end
    endcase
  end
  assign dout = temp;
endmodule

module top (
    input clk, rst, 
    input newd,
    input [11:0] din,
    output [11:0] dout,
    output done
);
    wire sclk, cs, mosi;

    spi_master m1 (clk, newd, rst, din, sclk, cs, mosi);
    spi_slave s1 (sclk, cs, mosi, dout, done);
endmodule
// Interface

interface spi_if;
    logic clk, rst;
    logic sclk;
    logic [11:0] din;
    logic newd;
    logic cs;
    logic mosi;
    logic done;
    logic [11:0] dout;
endinterface  
