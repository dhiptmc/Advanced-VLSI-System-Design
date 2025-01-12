module reset_sync (
    input  logic clk,         // 系統時鐘
    input  logic rst_async,   // 異步重置信號
    output logic rst_sync,    // 同步後的重置信號
    output logic rstn_sync
);

logic sync_stage1;
logic sync_stage2;

// 同步器的第一級
always_ff @ (posedge clk or posedge rst_async)
begin
if (rst_async) 
    sync_stage1 <= 1'b1;  // 捕獲並傳遞異步重置信號
else 
    sync_stage1 <= 1'b0;  // 正常工作時保持低
end

// 同步器的第二級
always_ff @ (posedge clk or posedge rst_async)
begin
if (rst_async) 
    sync_stage2 <= 1'b1;  // 確保穩定同步
else 
    sync_stage2 <= sync_stage1;
end

// 輸出同步化後的重置信號
assign rst_sync  = sync_stage2;
assign rstn_sync = ~rst_sync;

endmodule