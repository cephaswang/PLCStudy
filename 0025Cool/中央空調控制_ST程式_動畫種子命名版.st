(* ===================================================================
   中央空調系統控制程式 (ST 語言 - 三菱 FX5U / GX Works3)
   設備 : 冰水機(CH) / 冷卻水泵(PP) / 冷卻水塔(CT)
   模式 : 手動(Manual) / 自動(Auto)

   *** 本次新增 ***
   動畫種子(Animation Seed)：wAnim_PP / wAnim_CT / wAnim_CH，
   給 GT Designer3 或網頁 HMI 用來驅動運轉動畫（風扇轉動/水流/壓縮機脈動等）。
   數值定義：0=停止, 1~4=運轉中循環（每250ms前進一格，跑到4後歸1）。
   HMI端做法：在GT Designer3用「順序顯示(部品移動)」或「動作動畫」功能，
   把動畫圖檔的切換條件設定為讀取這個字元件，值1~4對應4張不同角度的圖，
   值0時顯示靜止圖。網頁版則是用這個數值當CSS animation-frame的index，
   或直接用 CSS animation-play-state 依 0/非0 切換播放/暫停。

   -------------------- I/O 對照表 (位址 / 原變量名 / 註解) --------------------
   X0   X_Auto_Mode      自動模式選擇 ON=自動, OFF=手動
   X1   X_Sys_Start_PB   系統啟動按鈕(自動模式用，上升緣觸發)
   X2   X_Sys_Stop_PB    系統停止按鈕(自動模式用)
   X3   X_Man_PP_Start   手動-水泵 啟動按鈕
   X4   X_Man_PP_Stop    手動-水泵 停止按鈕
   X5   X_Man_CT_Start   手動-水塔 啟動按鈕
   X6   X_Man_CT_Stop    手動-水塔 停止按鈕
   X7   X_Man_CH_Start   手動-冰水機 啟動按鈕
   X10  X_Man_CH_Stop    手動-冰水機 停止按鈕 (八進位位址,X7之後為X10)
   X11  X_PP_FlowSW      冷卻水泵 流水開關回授
   X12  X_PP_Fault       冷卻水泵 故障/過載回授
   X13  X_CT_Fault       冷卻水塔 故障/過載回授
   X14  X_CH_Fault       冰水機   故障回授
   X15  X_Fault_Reset    故障重置按鈕 (僅在故障已清除時有效)

   Y0   Y_PP_Run         冷卻水泵 運轉輸出
   Y1   Y_CT_Run         冷卻水塔 運轉輸出
   Y2   Y_CH_Run         冰水機   啟動許可/運轉接點輸出
   Y3   Y_Sys_RunLamp    系統運轉指示燈
   Y4   Y_Sys_AlarmLamp  系統故障指示燈

   D0   wAnim_PP  水泵動畫種子   0=停止 1~4=運轉循環(HMI讀取用，非實體輸出)
   D1   wAnim_CT  水塔動畫種子   0=停止 1~4=運轉循環(HMI讀取用，非實體輸出)
   D2   wAnim_CH  冰水機動畫種子 0=停止 1~4=運轉循環(HMI讀取用，非實體輸出)
   ===================================================================
   啟動順序(自動) : 水泵 -> 確認流水 -> 水塔 -> 延遲 -> 冰水機
   停止順序(自動) : 冰水機 -> 延遲(散熱保護) -> 水塔 -> 延遲 -> 水泵
   =================================================================== *)

VAR
    T_PP_to_CT       : TON;    (* 水泵確認流水後，延遲啟動水塔 *)
    T_CT_to_CH       : TON;    (* 水塔啟動後，延遲啟動冰水機 *)
    T_CH_StopDelay   : TON;    (* 冰水機停機後，延遲停水塔(散熱保護) *)
    T_CT_StopDelay   : TON;    (* 水塔停機後，延遲停水泵 *)

    tPP_to_CT_PT     : TIME := T#5S;
    tCT_to_CH_PT     : TIME := T#30S;
    tCH_StopDelay_PT : TIME := T#60S;
    tCT_StopDelay_PT : TIME := T#10S;

    eStep            : INT := 0;
    (* 0=待機 1=啟動水泵 2=啟動水塔 3=啟動冰水機 4=運轉中
       10=停冰水機 11=停水塔 12=停水泵 *)

    bSysFault        : BOOL;   (* 即時故障狀態(原始訊號OR結果) *)
    bFaultLatch      : BOOL;   (* 故障鎖存，需手動重置才會解除 *)
    bSysRun          : BOOL;

    bStartPrev       : BOOL;   (* 系統啟動按鈕前次狀態，供上升緣判斷用 *)
    bStartEdge       : BOOL;   (* 系統啟動按鈕上升緣 *)

    (* ---- 動畫種子相關 ---- *)
    T_Anim_Pulse     : TON;    (* 動畫時脈產生器(自激盪) *)
    tAnimStep_PT     : TIME := T#250MS;   (* 動畫每格切換週期，可依HMI圖檔張數調整 *)
    bAnimPulsePrev   : BOOL;
    bAnimPulse       : BOOL;   (* 動畫步進脈波(每週期TRUE一次掃描) *)

END_VAR

(* =================== 主程式 =================== *)

(* -------- 故障偵測與鎖存 -------- *)
bSysFault := X_PP_Fault OR X_CT_Fault OR X_CH_Fault;

IF bSysFault THEN
    bFaultLatch := TRUE;
ELSIF X_Fault_Reset AND NOT bSysFault THEN
    bFaultLatch := FALSE;
END_IF;

Y_Sys_AlarmLamp := bSysFault OR bFaultLatch;

(* -------- 系統啟動按鈕上升緣偵測 -------- *)
bStartEdge := X_Sys_Start_PB AND NOT bStartPrev;
bStartPrev := X_Sys_Start_PB;

(* -------- 主邏輯 -------- *)
IF bSysFault OR bFaultLatch THEN
    Y_CH_Run := FALSE;
    Y_CT_Run := FALSE;
    Y_PP_Run := FALSE;
    eStep    := 0;
    bSysRun  := FALSE;

    T_PP_to_CT(IN := FALSE, PT := tPP_to_CT_PT);
    T_CT_to_CH(IN := FALSE, PT := tCT_to_CH_PT);
    T_CH_StopDelay(IN := FALSE, PT := tCH_StopDelay_PT);
    T_CT_StopDelay(IN := FALSE, PT := tCT_StopDelay_PT);

ELSIF X_Auto_Mode THEN
    (* =============== 自動模式：依序啟動 / 依序停止 =============== *)
    CASE eStep OF

        0: (* 待機：需故障已重置，且啟動按鈕為新按下(上升緣)才會進入啟動程序 *)
            bSysRun := FALSE;
            IF bStartEdge THEN
                eStep := 1;
            END_IF;

        1: (* STEP1：啟動水泵，確認流水後計時 *)
            Y_PP_Run := TRUE;
            T_PP_to_CT(IN := X_PP_FlowSW, PT := tPP_to_CT_PT);
            IF T_PP_to_CT.Q THEN
                eStep := 2;
            END_IF;

        2: (* STEP2：啟動水塔，延遲後進下一步 *)
            Y_CT_Run := TRUE;
            T_CT_to_CH(IN := TRUE, PT := tCT_to_CH_PT);
            IF T_CT_to_CH.Q THEN
                eStep := 3;
            END_IF;

        3: (* STEP3：啟動冰水機 *)
            Y_CH_Run := TRUE;
            eStep := 4;

        4: (* 系統運轉中，等待停止指令 *)
            bSysRun := TRUE;
            IF X_Sys_Stop_PB THEN
                eStep := 10;
            END_IF;

        10: (* 先停冰水機 *)
            Y_CH_Run := FALSE;
            T_CH_StopDelay(IN := TRUE, PT := tCH_StopDelay_PT);
            IF T_CH_StopDelay.Q THEN
                eStep := 11;
            END_IF;

        11: (* 延遲後停水塔 *)
            Y_CT_Run := FALSE;
            T_CT_StopDelay(IN := TRUE, PT := tCT_StopDelay_PT);
            IF T_CT_StopDelay.Q THEN
                eStep := 12;
            END_IF;

        12: (* 延遲後停水泵，重置所有計時器 *)
            Y_PP_Run := FALSE;
            T_PP_to_CT(IN := FALSE, PT := tPP_to_CT_PT);
            T_CT_to_CH(IN := FALSE, PT := tCT_to_CH_PT);
            T_CH_StopDelay(IN := FALSE, PT := tCH_StopDelay_PT);
            T_CT_StopDelay(IN := FALSE, PT := tCT_StopDelay_PT);
            eStep := 0;

    END_CASE;

ELSE
    (* =============== 手動模式：個別控制，仍保留基本安全連鎖 =============== *)
    eStep   := 0;
    bSysRun := Y_PP_Run OR Y_CT_Run OR Y_CH_Run;

    IF X_Man_PP_Start THEN
        Y_PP_Run := TRUE;
    ELSIF X_Man_PP_Stop THEN
        Y_PP_Run := FALSE;
    END_IF;

    IF X_Man_CT_Start AND Y_PP_Run AND X_PP_FlowSW THEN
        Y_CT_Run := TRUE;
    ELSIF X_Man_CT_Stop THEN
        Y_CT_Run := FALSE;
    END_IF;

    IF X_Man_CH_Start AND Y_PP_Run AND X_PP_FlowSW AND Y_CT_Run THEN
        Y_CH_Run := TRUE;
    ELSIF X_Man_CH_Stop THEN
        Y_CH_Run := FALSE;
    END_IF;

    IF NOT Y_PP_Run OR NOT X_PP_FlowSW OR NOT Y_CT_Run THEN
        Y_CH_Run := FALSE;
    END_IF;

END_IF;

Y_Sys_RunLamp := bSysRun;

(* =================== 動畫種子產生 (供 HMI 引用) =================== *)

(* 動畫時脈：TON自激盪，每 tAnimStep_PT 週期產生一次上升緣脈波 *)
T_Anim_Pulse(IN := NOT T_Anim_Pulse.Q, PT := tAnimStep_PT);
bAnimPulse     := T_Anim_Pulse.Q AND NOT bAnimPulsePrev;
bAnimPulsePrev := T_Anim_Pulse.Q;

(* 水泵動畫種子 *)
IF Y_PP_Run THEN
    IF wAnim_PP = 0 THEN
        wAnim_PP := 1;
    ELSIF bAnimPulse THEN
        wAnim_PP := wAnim_PP + 1;
        IF wAnim_PP > 4 THEN
            wAnim_PP := 1;
        END_IF;
    END_IF;
ELSE
    wAnim_PP := 0;
END_IF;

(* 水塔動畫種子 *)
IF Y_CT_Run THEN
    IF wAnim_CT = 0 THEN
        wAnim_CT := 1;
    ELSIF bAnimPulse THEN
        wAnim_CT := wAnim_CT + 1;
        IF wAnim_CT > 4 THEN
            wAnim_CT := 1;
        END_IF;
    END_IF;
ELSE
    wAnim_CT := 0;
END_IF;

(* 冰水機動畫種子 *)
IF Y_CH_Run THEN
    IF wAnim_CH = 0 THEN
        wAnim_CH := 1;
    ELSIF bAnimPulse THEN
        wAnim_CH := wAnim_CH + 1;
        IF wAnim_CH > 4 THEN
            wAnim_CH := 1;
        END_IF;
    END_IF;
ELSE
    wAnim_CH := 0;
END_IF;
