(* ===================================================================
   中央空調系統控制程式 (ST 語言 - 三菱 FX5U / GX Works3)
   設備 : 冰水機(CH) / 冷卻水泵(PP) / 冷卻水塔(CT)
   模式 : 手動(Manual) / 自動(Auto)

   *** FX5U 程式(POU)注意事項 ***
   程式POU不支援 VAR_INPUT / VAR_OUTPUT 類別(那是給FB/Function用的)，
   實體I/O(X,Y)不需要宣告，直接在邏輯中使用位址即可。
   以下僅宣告「內部工作變數」(計時器/步序/旗標)。

   -------------------- I/O 對照表 (位址 / 原變量名 / 註解) --------------------
   X0   X_Auto_Mode      自動模式選擇 ON=自動, OFF=手動
   X1   X_Sys_Start_PB   系統啟動按鈕(自動模式用)
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

   Y0   Y_PP_Run         冷卻水泵 運轉輸出
   Y1   Y_CT_Run         冷卻水塔 運轉輸出
   Y2   Y_CH_Run         冰水機   啟動許可/運轉接點輸出
   Y3   Y_Sys_RunLamp    系統運轉指示燈
   Y4   Y_Sys_AlarmLamp  系統故障指示燈
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

    bSysFault        : BOOL;
    bSysRun          : BOOL;
END_VAR

(* =================== 主程式 =================== *)

(* 系統總故障判斷：任一設備故障，立即全部停機並重置步序 *)
bSysFault := X12 OR X13 OR X14;    (* X_PP_Fault OR X_CT_Fault OR X_CH_Fault *)
Y4 := bSysFault;                   (* Y_Sys_AlarmLamp *)

IF bSysFault THEN
    Y2 := FALSE;    (* Y_CH_Run *)
    Y1 := FALSE;    (* Y_CT_Run *)
    Y0 := FALSE;    (* Y_PP_Run *)
    eStep    := 0;
    bSysRun  := FALSE;

ELSIF X0 THEN    (* X_Auto_Mode *)
    (* =============== 自動模式：依序啟動 / 依序停止 =============== *)
    CASE eStep OF

        0: (* 待機 *)
            bSysRun := FALSE;
            IF X1 THEN    (* X_Sys_Start_PB *)
                eStep := 1;
            END_IF;

        1: (* STEP1：啟動水泵，確認流水後計時 *)
            Y0 := TRUE;    (* Y_PP_Run *)
            T_PP_to_CT(IN := X11, PT := tPP_to_CT_PT);    (* X11 = X_PP_FlowSW *)
            IF T_PP_to_CT.Q THEN
                eStep := 2;
            END_IF;

        2: (* STEP2：啟動水塔，延遲後進下一步 *)
            Y1 := TRUE;    (* Y_CT_Run *)
            T_CT_to_CH(IN := TRUE, PT := tCT_to_CH_PT);
            IF T_CT_to_CH.Q THEN
                eStep := 3;
            END_IF;

        3: (* STEP3：啟動冰水機 *)
            Y2 := TRUE;    (* Y_CH_Run *)
            eStep := 4;

        4: (* 系統運轉中，等待停止指令 *)
            bSysRun := TRUE;
            IF X2 THEN    (* X_Sys_Stop_PB *)
                eStep := 10;
            END_IF;

        10: (* 先停冰水機 *)
            Y2 := FALSE;    (* Y_CH_Run *)
            T_CH_StopDelay(IN := TRUE, PT := tCH_StopDelay_PT);
            IF T_CH_StopDelay.Q THEN
                eStep := 11;
            END_IF;

        11: (* 延遲後停水塔 *)
            Y1 := FALSE;    (* Y_CT_Run *)
            T_CT_StopDelay(IN := TRUE, PT := tCT_StopDelay_PT);
            IF T_CT_StopDelay.Q THEN
                eStep := 12;
            END_IF;

        12: (* 延遲後停水泵，重置所有計時器 *)
            Y0 := FALSE;    (* Y_PP_Run *)
            T_PP_to_CT(IN := FALSE, PT := tPP_to_CT_PT);
            T_CT_to_CH(IN := FALSE, PT := tCT_to_CH_PT);
            T_CH_StopDelay(IN := FALSE, PT := tCH_StopDelay_PT);
            T_CT_StopDelay(IN := FALSE, PT := tCT_StopDelay_PT);
            eStep := 0;

    END_CASE;

ELSE
    (* =============== 手動模式：個別控制，仍保留基本安全連鎖 =============== *)
    eStep   := 0;   (* 手動模式時重置自動步序，避免自動/手動切換誤動作 *)
    bSysRun := Y0 OR Y1 OR Y2;    (* Y_PP_Run OR Y_CT_Run OR Y_CH_Run *)

    (* 水泵：手動啟停，無連鎖 *)
    IF X3 THEN                    (* X_Man_PP_Start *)
        Y0 := TRUE;                (* Y_PP_Run *)
    ELSIF X4 THEN                 (* X_Man_PP_Stop *)
        Y0 := FALSE;
    END_IF;

    (* 水塔：手動啟動需水泵已運轉且有流水，避免空轉燒馬達 *)
    IF X5 AND Y0 AND X11 THEN     (* X_Man_CT_Start AND Y_PP_Run AND X_PP_FlowSW *)
        Y1 := TRUE;                (* Y_CT_Run *)
    ELSIF X6 THEN                 (* X_Man_CT_Stop *)
        Y1 := FALSE;
    END_IF;

    (* 冰水機：手動啟動需水泵+水塔皆運轉且有流水，保護冷凝器 *)
    IF X7 AND Y0 AND X11 AND Y1 THEN   (* X_Man_CH_Start AND Y_PP_Run AND X_PP_FlowSW AND Y_CT_Run *)
        Y2 := TRUE;                     (* Y_CH_Run *)
    ELSIF X10 THEN                      (* X_Man_CH_Stop *)
        Y2 := FALSE;
    END_IF;

    (* 連鎖保護：水泵/流水/水塔任一中斷，冰水機強制停機 *)
    IF NOT Y0 OR NOT X11 OR NOT Y1 THEN    (* Y_PP_Run / X_PP_FlowSW / Y_CT_Run *)
        Y2 := FALSE;    (* Y_CH_Run *)
    END_IF;

END_IF;

Y3 := bSysRun;    (* Y_Sys_RunLamp *)
