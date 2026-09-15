(* ===================================================================
   中央空調系統控制程式 (ST 語言 - 三菱 PLC / GX Works3, iQ-R / iQ-F 系列)
   設備 : 冰水機(CH) / 冷卻水泵(PP) / 冷卻水塔(CT)
   模式 : 手動(Manual) / 自動(Auto)
   啟動順序(自動) : 水泵 -> 確認流水 -> 水塔 -> 延遲 -> 冰水機
   停止順序(自動) : 冰水機 -> 延遲(散熱保護) -> 水塔 -> 延遲 -> 水泵
   說明 : 啟動順序若貴廠慣例為「水塔先啟動」，只需對調 STEP 1/2 內容即可。
   =================================================================== *)

(* -------------------- 輸入 -------------------- *)
VAR_INPUT
    X_Auto_Mode      : BOOL;   (* 自動模式選擇 ON=自動, OFF=手動 *)
    X_Sys_Start_PB   : BOOL;   (* 系統啟動按鈕 (自動模式用) *)
    X_Sys_Stop_PB    : BOOL;   (* 系統停止按鈕 (自動模式用) *)

    X_Man_PP_Start   : BOOL;   (* 手動-水泵 啟動按鈕 *)
    X_Man_PP_Stop    : BOOL;   (* 手動-水泵 停止按鈕 *)
    X_Man_CT_Start   : BOOL;   (* 手動-水塔 啟動按鈕 *)
    X_Man_CT_Stop    : BOOL;   (* 手動-水塔 停止按鈕 *)
    X_Man_CH_Start   : BOOL;   (* 手動-冰水機 啟動按鈕 *)
    X_Man_CH_Stop    : BOOL;   (* 手動-冰水機 停止按鈕 *)

    X_PP_FlowSW      : BOOL;   (* 冷卻水泵 流水開關回授 (確認有循環水) *)
    X_PP_Fault       : BOOL;   (* 冷卻水泵 故障/過載回授 *)
    X_CT_Fault       : BOOL;   (* 冷卻水塔 故障/過載回授 *)
    X_CH_Fault       : BOOL;   (* 冰水機   故障回授 *)
END_VAR

(* -------------------- 輸出 -------------------- *)
VAR_OUTPUT
    Y_PP_Run        : BOOL;    (* 冷卻水泵 運轉輸出 *)
    Y_CT_Run        : BOOL;    (* 冷卻水塔 運轉輸出 *)
    Y_CH_Run        : BOOL;    (* 冰水機 啟動許可/運轉接點輸出 *)
    Y_Sys_RunLamp   : BOOL;    (* 系統運轉指示燈 *)
    Y_Sys_AlarmLamp : BOOL;    (* 系統故障指示燈 *)
END_VAR

(* -------------------- 內部變數 -------------------- *)
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

    bSysFault        : BOOL;
    bSysRun          : BOOL;
END_VAR

(* =================== 主程式 =================== *)

(* 系統總故障判斷：任一設備故障，立即全部停機並重置步序 *)
bSysFault := X_PP_Fault OR X_CT_Fault OR X_CH_Fault;
Y_Sys_AlarmLamp := bSysFault;

IF bSysFault THEN
    Y_CH_Run := FALSE;
    Y_CT_Run := FALSE;
    Y_PP_Run := FALSE;
    eStep    := 0;
    bSysRun  := FALSE;

ELSIF X_Auto_Mode THEN
    (* =============== 自動模式：依序啟動 / 依序停止 =============== *)
    CASE eStep OF

        0: (* 待機 *)
            bSysRun := FALSE;
            IF X_Sys_Start_PB THEN
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
    eStep   := 0;   (* 手動模式時重置自動步序，避免自動/手動切換誤動作 *)
    bSysRun := Y_PP_Run OR Y_CT_Run OR Y_CH_Run;

    (* 水泵：手動啟停，無連鎖 *)
    IF X_Man_PP_Start THEN
        Y_PP_Run := TRUE;
    ELSIF X_Man_PP_Stop THEN
        Y_PP_Run := FALSE;
    END_IF;

    (* 水塔：手動啟動需水泵已運轉且有流水，避免空轉燒馬達 *)
    IF X_Man_CT_Start AND Y_PP_Run AND X_PP_FlowSW THEN
        Y_CT_Run := TRUE;
    ELSIF X_Man_CT_Stop THEN
        Y_CT_Run := FALSE;
    END_IF;

    (* 冰水機：手動啟動需水泵+水塔皆運轉且有流水，保護冷凝器 *)
    IF X_Man_CH_Start AND Y_PP_Run AND X_PP_FlowSW AND Y_CT_Run THEN
        Y_CH_Run := TRUE;
    ELSIF X_Man_CH_Stop THEN
        Y_CH_Run := FALSE;
    END_IF;

    (* 連鎖保護：水泵/流水/水塔任一中斷，冰水機強制停機 *)
    IF NOT Y_PP_Run OR NOT X_PP_FlowSW OR NOT Y_CT_Run THEN
        Y_CH_Run := FALSE;
    END_IF;

END_IF;

Y_Sys_RunLamp := bSysRun;
