module mac8 (
    input  logic clk,
    input  logic rst,
    input  logic valid,
    input  logic signed [7:0] a,
    input  logic signed [7:0] b,
    output logic signed [31:0] acc
);

    logic signed [15:0] product;

    assign product = a * b;

    always_ff @(posedge clk) begin
        if (rst) begin
            acc <= 32'sd0;
        end
        else if (valid) begin
            acc <= acc + product;
        end
    end

endmodule
