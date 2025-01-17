module WDT (
    input  logic        clk,
    input  logic        rstn,
    input  logic        clk2,
    input  logic        rstn2,
    
    input  logic        WTOCNT_load,

    input  logic        WDEN,
    input  logic        WDLIVE,
    input  logic [31:0] WTOCNT,
    output logic        WTO
);

//CDC single bit
logic WDEN_clk_reg;
logic WDLIVE_clk_reg;

logic WDEN_clk2_reg_stage1;
logic WDEN_clk2_reg_stage2;

logic WDLIVE_clk2_reg_stage1;
logic WDLIVE_clk2_reg_stage2;
//CDC multi bit
logic [31:0] WTOCNT_clk_reg;
logic [31:0] WTOCNT_clk2_reg;

//multi bit load signal
logic load_clk_reg;
logic load_clk2_stage1;
logic load_clk2_stage2;


//single bit
always_ff @ (posedge clk or negedge rstn) //這段程式碼是跨時鐘域訊號同步的第一步，透過暫存確保訊號穩定，並為後續同步到 clk2 域做好準備。
begin
    if(!rstn)
    begin
        WDEN_clk_reg   <= 1'b0;
        WDLIVE_clk_reg <= 1'b0;
    end
    else
    begin
        WDEN_clk_reg   <= WDEN;
        WDLIVE_clk_reg <= WDLIVE;
    end
end

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
    begin
        WDEN_clk2_reg_stage1 <= 1'b0;
        WDEN_clk2_reg_stage2 <= 1'b0;
    end
    else
    begin
        WDEN_clk2_reg_stage1 <= WDEN_clk_reg;
        WDEN_clk2_reg_stage2 <= WDEN_clk2_reg_stage1;
    end
end

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
    begin
        WDLIVE_clk2_reg_stage1 <= 1'b0;
        WDLIVE_clk2_reg_stage2 <= 1'b0;
    end
    else
    begin
        WDLIVE_clk2_reg_stage1 <= WDLIVE_clk_reg;
        WDLIVE_clk2_reg_stage2 <= WDLIVE_clk2_reg_stage1;
    end
end

//multi bit
always_ff @ (posedge clk or negedge rstn) // since using load signal, we don't have to preprocess it
begin
    if(!rstn)
        WTOCNT_clk_reg <= 32'd0;
    else
        WTOCNT_clk_reg <= WTOCNT;
end

always_ff @ (posedge clk2 or negedge rstn2) // need to use in clk2 domain
begin
    if(!rstn2)
        load_clk_reg <= 1'b0;
    else
        load_clk_reg <= WTOCNT_load;
end

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
    begin
        load_clk2_stage1 <= 1'b0;
        load_clk2_stage2 <= 1'b0;
    end
    else
    begin
        load_clk2_stage1 <= load_clk_reg;
        load_clk2_stage2 <= ~load_clk2_stage1; //取反
        /*                                                                  
        1.避免元穩態的影響：
        在跨時鐘域的情況下，如果信號變化非常接近兩個時鐘的邊緣，會產生元穩態，即信號不穩定，可能會在一段時間內處於未知狀態。
        為了消除這種情況，我們需要通過對信號進行延遲並取反來幫助檢測信號是否穩定，並防止錯誤的狀態傳遞。
        2.反向操作確保信號穩定：
        如果我們不取反，load_clk2_stage1 和 load_clk2_stage2 可能會同步更新，這樣可能導致兩者在短時間內變為相同狀態，從而失去同步的效果。
        取反之後，load_clk2_stage2 總是會跟隨 load_clk2_stage1 更新，但會有一個時鐘週期的延遲。這樣可以保證第二個寄存器（load_clk2_stage2）能夠穩定地捕捉到 load_clk_reg 信號的變化，避免兩者同步更新而引起的元穩態。
        3.加強信號穩定性檢測：
        在這段程式中，反向操作的目的是增加穩定性，並且確保 load_pulse 只有在信號穩定且確定變化之後才被觸發。
        換句話說，load_clk2_stage1 和 load_clk2_stage2 是用來避免因為時鐘域之間的信號延遲或不穩定而引起的誤判，並且確保 load_pulse 只在信號真正穩定之後才有效。

        以上 我沒有很懂……
        */
    end
end

logic  load_pulse;
assign load_pulse = load_clk2_stage1 && load_clk2_stage2;

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
        WTOCNT_clk2_reg <= 32'd0;
    else
        WTOCNT_clk2_reg <= (load_pulse) ? WTOCNT_clk_reg : WTOCNT_clk2_reg;
end

//FSM
logic [1:0] cur_state, nxt_state;
localparam [1:0]    INIT    = 2'b00,
                    CNTDOWN = 2'b01,
                    RSTCNT  = 2'b10,
                    TIMEOUT = 2'b11;

logic [31:0] WDT_cnt;
logic        cnt_exceed;
assign       cnt_exceed = ( (cur_state == CNTDOWN) && (WDT_cnt == 32'd0) );

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
        cur_state <= INIT;
    else
        cur_state <= nxt_state;
end

always_comb
begin
    case(cur_state)
    INIT:
    begin
        if(WDEN_clk2_reg_stage2)
            nxt_state = CNTDOWN;
        else if(WDLIVE_clk2_reg_stage2)
            nxt_state = RSTCNT;
        else
            nxt_state = INIT;
    end

    CNTDOWN:
        nxt_state = (cnt_exceed) ? TIMEOUT : CNTDOWN;

    RSTCNT:
        nxt_state = INIT;

    TIMEOUT:
        nxt_state = (WDEN_clk2_reg_stage2) ? INIT : TIMEOUT;
    endcase
end

always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
        WDT_cnt <= 32'd0;
    else
    begin
        case(cur_state)
        INIT:
            WDT_cnt <= WTOCNT_clk2_reg;
        CNTDOWN:
            WDT_cnt <= (WDLIVE_clk2_reg_stage2) ? WTOCNT_clk2_reg : (WDT_cnt - 32'd1);
        RSTCNT:
            WDT_cnt <= 32'd0;
        TIMEOUT:
            WDT_cnt <= WDT_cnt;
        endcase
    end
end

//WTO
always_ff @ (posedge clk2 or negedge rstn2)
begin
    if(!rstn2)
        WTO <= 1'b0;
    else
    begin
        WTO <= (cur_state == TIMEOUT);
    end
end

endmodule