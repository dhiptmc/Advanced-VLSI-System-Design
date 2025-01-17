module reset_sync_dual (
    input  logic clk1,         // 第一個系統時鐘
    input  logic clk2,         // 第二個系統時鐘
    input  logic rst1_async,   // 第一個異步重置信號
    input  logic rst2_async,   // 第二個異步重置信號
    output logic rst1n_sync,   // 第一個同步後的反向重置信號
    output logic rst2n_sync    // 第二個同步後的反向重置信號
);

logic rst1_sync; // 第一個同步後的重置信號
logic rst2_sync; // 第二個同步後的重置信號

// 第一個時鐘域的同步器暫存器
logic sync1_stage1;
logic sync1_stage2;

// 第二個時鐘域的同步器暫存器
logic sync2_stage1;
logic sync2_stage2;

// 第一個時鐘域的同步器
always_ff @ (posedge clk1 or posedge rst1_async)
begin
    if (rst1_async) 
        sync1_stage1 <= 1'b1;
    else 
        sync1_stage1 <= 1'b0;
end

always_ff @ (posedge clk1 or posedge rst1_async)
begin
    if (rst1_async) 
        sync1_stage2 <= 1'b1;
    else 
        sync1_stage2 <= sync1_stage1;
end

assign rst1_sync  = sync1_stage2;
assign rst1n_sync = ~rst1_sync;

// 第二個時鐘域的同步器
always_ff @ (posedge clk2 or posedge rst2_async)
begin
    if (rst2_async) 
        sync2_stage1 <= 1'b1;
    else 
        sync2_stage1 <= 1'b0;
end

always_ff @ (posedge clk2 or posedge rst2_async)
begin
    if (rst2_async) 
        sync2_stage2 <= 1'b1;
    else 
        sync2_stage2 <= sync2_stage1;
end

assign rst2_sync  = sync2_stage2;
assign rst2n_sync = ~rst2_sync;

endmodule
