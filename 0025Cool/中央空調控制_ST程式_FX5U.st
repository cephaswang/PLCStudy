(* ===================================================================
   中央空調系統控制程式 (ST 語言 - 三菱 FX5U / GX Works3)
   設備 : 冰水機(CH) / 冷卻水泵(PP) / 冷卻水塔(CT)
   模式 : 手動(Manual) / 自動(Auto)

   *** FX5U 程式(POU)注意事項 ***
   程式POU不支援 VAR_INPUT / VAR_OUTPUT 類別(那是給FB/Function用的)，
   實體I/O(X,Y)不需要宣告，直接在邏輯中使用位址即可。
   以下僅宣告「內部工作變數」(計時器/步序/旗標)。

   -------------------- I/O 分配表 --------------------
   X0   自動模式選擇 ON=自動, OFF=手動
   X1   系統啟動按鈕(自動模式用)
   X2   系統停止按鈕(自動模式用)
   X3   手動-水泵 啟動按鈕
   X4   手動-水泵 停止按鈕
   X5   手動-水塔 啟動按鈕
   X6   手動-水塔 停止按鈕
   X7   手動-冰水機 啟動按鈕
   X10  手動-冰水機 停止按鈕   (八進位位址,X7之後為X10)
   X11  冷卻水泵 流水開關回授
   X12  冷卻水泵 故障/過載回授
   X13  冷卻水塔 故障/過載回授
   X14  冰水機   故障回授

   Y0   冷卻水泵 運轉輸出
   Y1   冷卻水塔 運轉輸出
   Y2   冰水機   啟動許可/運轉接點輸出
   Y3   系統運轉指示燈
   Y4   系統故障指示燈
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
bSysFault := X12 OR X13 OR X14;
Y4 := bSysFault;

IF bSysFault THEN
    Y2 := FALSE;
    Y1 := FALSE;
    Y0 := FALSE;
    eStep    := 0;
    bSysRun  := FALSE;

ELSIF X0 THEN
    (* =============== 自動模式：依序啟動 / 依序停止 =============== *)
    CASE eStep OF

        0: (* 待機 *)
            bSysRun := FALSE;
            IF X1 THEN
                eStep := 1;
            END_IF;

        1: (* STEP1：啟動水泵，確認流水後計時 *)
            Y0 := TRUE;
            T_PP_to_CT(IN := X11, PT := tPP_to_CT_PT);
            IF T_PP_to_CT.Q THEN
                eStep := 2;
            END_IF;

        2: (* STEP2：啟動水塔，延遲後進下一步 *)
            Y1 := TRUE;
            T_CT_to_CH(IN := TRUE, PT := tCT_to_CH_PT);
            IF T_CT_to_CH.Q THEN
                eStep := 3;
            END_IF;

        3: (* STEP3：啟動冰水機 *)
            Y2 := TRUE;
            eStep := 4;

        4: (* 系統運轉中，等待停止指令 *)
            bSysRun := TRUE;
            IF X2 THEN
                eStep := 10;
            END_IF;

        10: (* 先停冰水機 *)
            Y2 := FALSE;
            T_CH_StopDelay(IN := TRUE, PT := tCH_StopDelay_PT);
            IF T_CH_StopDelay.Q THEN
                eStep := 11;
            END_IF;

        11: (* 延遲後停水塔 *)
            Y1 := FALSE;
            T_CT_StopDelay(IN := TRUE, PT := tCT_StopDelay_PT);
            IF T_CT_StopDelay.Q THEN
                eStep := 12;
            END_IF;

        12: (* 延遲後停水泵，重置所有計時器 *)
            Y0 := FALSE;
            T_PP_to_CT(IN := FALSE, PT := tPP_to_CT_PT);
            T_CT_to_CH(IN := FALSE, PT := tCT_to_CH_PT);
            T_CH_StopDelay(IN := FALSE, PT := tCH_StopDelay_PT);
            T_CT_StopDelay(IN := FALSE, PT := tCT_StopDelay_PT);
            eStep := 0;

    END_CASE;

ELSE
    (* =============== 手動模式：個別控制，仍保留基本安全連鎖 =============== *)
    eStep   := 0;   (* 手動模式時重置自動步序，避免自動/手動切換誤動作 *)
    bSysRun := Y0 OR Y1 OR Y2;

    (* 水泵：手動啟停，無連鎖 *)
    IF X3 THEN
        Y0 := TRUE;
    ELSIF X4 THEN
        Y0 := FALSE;
    END_IF;

    (* 水塔：手動啟動需水泵已運轉且有流水，避免空轉燒馬達 *)
    IF X5 AND Y0 AND X11 THEN
        Y1 := TRUE;
    ELSIF X6 THEN
        Y1 := FALSE;
    END_IF;

    (* 冰水機：手動啟動需水泵+水塔皆運轉且有流水，保護冷凝器 *)
    IF X7 AND Y0 AND X11 AND Y1 THEN
        Y2 := TRUE;
    ELSIF X10 THEN
        Y2 := FALSE;
    END_IF;

    (* 連鎖保護：水泵/流水/水塔任一中斷，冰水機強制停機 *)
    IF NOT Y0 OR NOT X11 OR NOT Y1 THEN
        Y2 := FALSE;
    END_IF;

END_IF;

Y3 := bSysRun;
