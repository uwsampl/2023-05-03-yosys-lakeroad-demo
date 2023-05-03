module mul(input clk, input [17:0] a, input [17:0] b, output [17:0] out);
  logic [17:0] r0, r1, r2;
  always_ff @(posedge clk) begin
    r0 <= a * b;
    r1 <= r0;
    r2 <= r1;
  end
  assign out = r2;
endmodule