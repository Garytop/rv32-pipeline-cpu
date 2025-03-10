module pl_reg #(parameter WIDTH = 32)(
    input clk, rst, flush, stall_id_ex, stall_if_id,
    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out
    );
    
    always@(posedge clk, posedge rst)
        begin
            if(rst)
                out <= 0;
            else if (flush)
                out <= 0;
            else if (stall_id_ex)
                out <= 0;
            else if (stall_if_id)
                out <= out;            
            else 
                out <= in;
        end
    
endmodule
