(* ================================================================
   中央空調系統 機房控制盤 PLC 程式
   適用機型: 三菱 FX5U 系列 (GX Works3, ST 結構化文字語言)
   對應規劃書: 0909_中央空調電控系統規劃企劃書
   內容涵蓋:
     1. 開機連鎖程序 (水塔/冷卻水泵 -> 確認冷卻水流量 -> 冰水泵
        -> 確認冰水流量 -> 冰水主機啟動)
     2. 停機程序 (先停主機 -> 延時排除餘熱 -> 停泵浦與水塔)
     3. 保護連鎖 (流量開關、高低壓、防凍、過載、緊急停止)
     4. 手動/自動模式切換
     5. 水塔風扇/水泵 VFD 頻率參考輸出 (簡易溫度回授調整範例)
   注意: 本程式為機房控制盤 PLC 邏輯,冰水主機內部製冷能力調節由
        機組原廠內建 PLC/變頻器自行控制,本 PLC 僅下達啟停指令並
        讀取運轉/故障狀態,不介入機組內部迴路 (依規劃書 4.2 節)。
   ================================================================ *)

PROGRAM MC_ChillerPlant_Control
VAR
    (* ---------------- 數位輸入 DI ---------------- *)
    X_Manual              : BOOL;  (* 手動模式選擇 (面板選擇開關) *)
    X_Auto                : BOOL;  (* 自動模式選擇 *)
    X_EStop               : BOOL;  (* 緊急停止 (常閉接點斷路=TRUE觸發) *)
    X_StartCmd            : BOOL;  (* 啟動指令 (HMI/SCADA/面板按鈕) *)
    X_StopCmd             : BOOL;  (* 停止指令 (HMI/SCADA/面板按鈕) *)
    X_AlarmReset          : BOOL;  (* 警報復歸按鈕 *)

    X_CT_BasinLevelLow    : BOOL;  (* 水塔水盤液位低 (禁止啟動,防空轉) *)
    X_CT_BasinLevelHigh   : BOOL;  (* 水塔水盤液位高 (溢流警報,不停機) *)
    X_CT_FanRun           : BOOL;  (* 冷卻水塔風扇運轉回授 *)
    X_CT_FanFault         : BOOL;  (* 冷卻水塔風扇/VFD故障回授 *)

    X_CWP_Run             : BOOL;  (* 冷卻水泵浦運轉回授 *)
    X_CWP_Fault           : BOOL;  (* 冷卻水泵浦/VFD故障回授 *)
    X_CHWP_Run            : BOOL;  (* 冰水泵浦運轉回授 *)
    X_CHWP_Fault          : BOOL;  (* 冰水泵浦/VFD故障回授 *)

    X_CW_FlowSw           : BOOL;  (* 冷卻水流量開關 ON=有流量 *)
    X_CHW_FlowSw          : BOOL;  (* 冰水流量開關 ON=有流量 *)

    X_Chiller_Run         : BOOL;  (* 冰水主機運轉回授 (主機控制箱接點/通訊) *)
    X_Chiller_Fault       : BOOL;  (* 冰水主機故障回授 (含高低壓/欠相逆相/防凍/過載,由主機彙整) *)
    X_HiLoPressure_Fault  : BOOL;  (* 現場加裝之高低壓開關動作 (如另設) *)
    X_Freeze_Fault        : BOOL;  (* 現場加裝之防凍開關動作 (如另設) *)

    (* ---------------- 數位輸出 DO ---------------- *)
    Y_CT_FanStart         : BOOL;  (* 冷卻水塔風扇啟動指令 -> 風扇啟動器/VFD *)
    Y_CWP_Start           : BOOL;  (* 冷卻水泵浦啟動指令 -> 馬達啟動器/VFD *)
    Y_CHWP_Start           : BOOL; (* 冰水泵浦啟動指令 -> 馬達啟動器/VFD *)
    Y_Chiller_StartCmd    : BOOL;  (* 冰水主機遠端啟動指令 -> 主機控制箱端子 *)
    Y_RunLamp             : BOOL;  (* 系統運轉指示燈 *)
    Y_AlarmLamp           : BOOL;  (* 警報指示燈 *)
    Y_AlarmBuzzer         : BOOL;  (* 警報蜂鳴器 (閃爍輸出) *)

    (* ---------------- 類比輸入 AI (經類比模組換算為工程單位) ---------------- *)
    D_CHW_SupplyTemp      : REAL;  (* 冰水出水溫度 degC *)
    D_CHW_ReturnTemp      : REAL;  (* 冰水回水溫度 degC *)
    D_CW_SupplyTemp       : REAL;  (* 冷卻水出水溫度 degC *)
    D_CW_ReturnTemp       : REAL;  (* 冷卻水回水溫度 degC *)

    (* ---------------- 類比輸出 AO (經類比模組送出至VFD) ---------------- *)
    D_CT_Fan_FreqCmd      : REAL;  (* 冷卻水塔風扇頻率指令 Hz *)
    D_CWP_FreqCmd         : REAL;  (* 冷卻水泵浦頻率指令 Hz *)

    (* ---------------- 參數 (可依現場調機調整) ---------------- *)
    TM_CWFlowDelay        : TIME := T#20S;   (* 冷卻水流量確認延時,規劃書建議10~30秒 *)
    TM_CHWFlowDelay       : TIME := T#20S;   (* 冰水流量確認延時 *)
    TM_ChillerStopDelay   : TIME := T#180S;  (* 主機停機後餘熱排除延時,建議數分鐘,可調 *)
    TM_AlarmBlink         : TIME := T#500MS; (* 警報燈/蜂鳴閃爍週期 *)

    CT_Fan_FreqMax        : REAL := 60.0;    (* 水塔風扇最高頻率 Hz *)
    CT_Fan_FreqMin        : REAL := 20.0;    (* 水塔風扇最低頻率 Hz (避免馬達過熱) *)
    CW_ReturnTemp_SP      : REAL := 35.0;    (* 冷卻水回水溫度設定值 degC (依機組型錄) *)
    CW_ReturnTemp_Band    : REAL := 5.0;     (* 比例調整頻寬 degC *)

    (* ---------------- 內部狀態 ---------------- *)
    SEQ_STEP              : INT := 0;
    (* 0:待機  1:啟動水塔+冷卻水泵,等待冷卻水流量
       2:啟動冰水泵,等待冰水流量  3:下達主機啟動指令,等待主機運轉回授
       4:運轉中  10:停主機,餘熱排除延時中  12:停泵浦與水塔 *)
    Sys_Fault             : BOOL;  (* 故障條件即時狀態 *)
    Sys_FaultLatch        : BOOL;  (* 故障鎖定,需人員確認復歸 *)
    Sys_Running           : BOOL;  (* 系統運轉中旗標 *)

    (* ---------------- 功能塊實例 ---------------- *)
    T_CWFlowDelay         : TON;
    T_CHWFlowDelay        : TON;
    T_ChillerStopDelay    : TON;
    T_AlarmBlink          : TON;
    R_StartCmd            : R_TRIG;
    R_StopCmd             : R_TRIG;
    R_Reset               : R_TRIG;
END_VAR

(* ================================================================
   一、邊緣觸發偵測
   ================================================================ *)
R_StartCmd(CLK := X_StartCmd);
R_StopCmd(CLK := X_StopCmd);
R_Reset(CLK := X_AlarmReset);

(* ================================================================
   二、保護連鎖故障彙整 (規劃書 4.3節【保護連鎖】)
   任一流量開關斷訊、高低壓開關動作、防凍開關動作、馬達過載跳脫、
   緊急停止時,立即連鎖停機並發出警報。
   ================================================================ *)
Sys_Fault := X_EStop
          OR X_CT_FanFault
          OR X_CWP_Fault
          OR X_CHWP_Fault
          OR X_Chiller_Fault
          OR X_HiLoPressure_Fault
          OR X_Freeze_Fault
          OR (SEQ_STEP >= 1 AND SEQ_STEP <= 4 AND NOT X_CW_FlowSw)   (* 冷卻水流量斷訊 (啟動延時期間除外由計時器自行處理) *)
          OR (SEQ_STEP >= 3 AND SEQ_STEP <= 4 AND NOT X_CHW_FlowSw); (* 冰水流量斷訊 *)

IF Sys_Fault THEN
    Sys_FaultLatch := TRUE;
END_IF;
IF R_Reset.Q AND NOT Sys_Fault THEN
    Sys_FaultLatch := FALSE;
END_IF;

(* ================================================================
   三、主控制狀態機
   ================================================================ *)
IF Sys_FaultLatch THEN
    (* 故障鎖定:全部設備立即停止,狀態歸零,等待人員確認復歸後才可重新啟動 *)
    Y_CT_FanStart      := FALSE;
    Y_CWP_Start        := FALSE;
    Y_CHWP_Start       := FALSE;
    Y_Chiller_StartCmd := FALSE;
    Sys_Running        := FALSE;
    SEQ_STEP           := 0;
    T_CWFlowDelay(IN := FALSE, PT := TM_CWFlowDelay);
    T_CHWFlowDelay(IN := FALSE, PT := TM_CHWFlowDelay);
    T_ChillerStopDelay(IN := FALSE, PT := TM_ChillerStopDelay);

ELSIF X_Manual THEN
    (* 手動模式:各設備由現場手動啟動器操作,PLC 自動連鎖不介入,狀態機歸零待命 *)
    SEQ_STEP := 0;

ELSE
    (* ---------------- 自動模式 ---------------- *)
    CASE SEQ_STEP OF

    0:  (* 待機 *)
        Y_CT_FanStart      := FALSE;
        Y_CWP_Start        := FALSE;
        Y_CHWP_Start       := FALSE;
        Y_Chiller_StartCmd := FALSE;
        Sys_Running        := FALSE;
        IF R_StartCmd.Q AND NOT X_CT_BasinLevelLow THEN
            (* 規劃書4.3【開機程序】1: 確認無故障、水塔液位正常,方允許啟動 *)
            SEQ_STEP := 1;
        END_IF;

    1:  (* 啟動冷卻水塔風扇與冷卻水泵浦,建立冷卻水循環 *)
        Y_CT_FanStart := TRUE;
        Y_CWP_Start   := TRUE;
        T_CWFlowDelay(IN := X_CW_FlowSw, PT := TM_CWFlowDelay);
        IF T_CWFlowDelay.Q THEN
            (* 確認冷卻水流量開關ON且延時10~30秒後,進入下一步 *)
            SEQ_STEP := 2;
        END_IF;
        IF R_StopCmd.Q THEN
            SEQ_STEP := 12;  (* 尚未啟動泵/主機,直接停止水塔與冷卻水泵 *)
        END_IF;

    2:  (* 啟動冰水泵浦,建立冰水循環 *)
        Y_CHWP_Start := TRUE;
        T_CHWFlowDelay(IN := X_CHW_FlowSw, PT := TM_CHWFlowDelay);
        IF T_CHWFlowDelay.Q THEN
            SEQ_STEP := 3;
        END_IF;
        IF R_StopCmd.Q THEN
            SEQ_STEP := 10;
        END_IF;

    3:  (* 確認冰水流量後,下達冰水主機啟動指令,機組以變頻軟啟動方式運轉 *)
        Y_Chiller_StartCmd := TRUE;
        IF X_Chiller_Run THEN
            SEQ_STEP := 4;
        END_IF;
        IF R_StopCmd.Q THEN
            SEQ_STEP := 10;
        END_IF;

    4:  (* 系統運轉中:主機製冷能力由機組內建PLC/變頻器依冰水出水溫度自動控制 *)
        Sys_Running := TRUE;
        IF R_StopCmd.Q THEN
            SEQ_STEP := 10;
        END_IF;

    10: (* 停機程序1: 先停冰水主機,延遲數分鐘待機組餘熱排除 *)
        Sys_Running        := FALSE;
        Y_Chiller_StartCmd := FALSE;
        T_ChillerStopDelay(IN := TRUE, PT := TM_ChillerStopDelay);
        IF T_ChillerStopDelay.Q THEN
            SEQ_STEP := 12;
        END_IF;

    12: (* 停機程序2: 餘熱排除完畢,停止冰水泵、冷卻水泵及冷卻水塔風扇 *)
        Y_CHWP_Start  := FALSE;
        Y_CWP_Start   := FALSE;
        Y_CT_FanStart := FALSE;
        T_ChillerStopDelay(IN := FALSE, PT := TM_ChillerStopDelay);
        SEQ_STEP := 0;

    ELSE
        SEQ_STEP := 0;
    END_CASE;
END_IF;

(* ================================================================
   四、警報輸出 (故障燈恆亮,蜂鳴器閃爍;水塔溢流僅警示不停機)
   ================================================================ *)
T_AlarmBlink(IN := (Sys_FaultLatch OR X_CT_BasinLevelHigh), PT := TM_AlarmBlink);
Y_AlarmLamp   := Sys_FaultLatch OR X_CT_BasinLevelHigh;
Y_AlarmBuzzer := (Sys_FaultLatch OR X_CT_BasinLevelHigh) AND NOT T_AlarmBlink.Q;
Y_RunLamp     := Sys_Running;

(* ================================================================
   五、冷卻水塔風扇 VFD 頻率參考輸出 (節能運轉,規劃書3.2/4.3節)
   依冷卻水回水溫度與設定值之偏差,比例調整風扇運轉頻率;
   實際比例增益、上下限與是否採PID控制,建議於調機階段依現場
   特性微調,亦可改採內建 PID 指令 (S.PID) 實現更精確控制。
   ================================================================ *)
IF Y_CT_FanStart THEN
    IF D_CW_ReturnTemp <= (CW_ReturnTemp_SP - CW_ReturnTemp_Band) THEN
        D_CT_Fan_FreqCmd := CT_Fan_FreqMin;
    ELSIF D_CW_ReturnTemp >= (CW_ReturnTemp_SP + CW_ReturnTemp_Band) THEN
        D_CT_Fan_FreqCmd := CT_Fan_FreqMax;
    ELSE
        D_CT_Fan_FreqCmd := CT_Fan_FreqMin + (CT_Fan_FreqMax - CT_Fan_FreqMin) *
                             ((D_CW_ReturnTemp - (CW_ReturnTemp_SP - CW_ReturnTemp_Band)) /
                              (2.0 * CW_ReturnTemp_Band));
    END_IF;
ELSE
    D_CT_Fan_FreqCmd := 0.0;
END_IF;

(* 冷卻水泵浦一般採定壓差或定流量控制,實際控制點位(壓差變送器)
   未於本範例輸入變數中定義,建議於詳細設計階段依SCADA廠牌
   及變送器規格另行擴充比例/PID運算區塊。 *)

END_PROGRAM

(* ================================================================
   附註:
   1. 通訊介接 (規劃書4.5節):
      - 冰水主機資料讀取: 若採 RS-485 MODBUS RTU 與主機內建通訊
        模組連線,建議使用 FX5U 內建 RS-485 通訊板 (FX5-485-BD) 搭配
        ADPRW 指令,或使用 GX Works3 之「簡易PLC間通訊」/「無協議
        通訊」功能實現 Modbus RTU Master;讀取內容包含主機運轉狀態、
        故障碼、溫度、壓力等,可另建獨立 FB (Function Block) 處理。
      - 上層 SCADA 介接: 若採 MODBUS TCP,可利用 FX5U 內建乙太網路
        埠設定為 Modbus TCP Server (透過參數設定,無需另編ST程式),
        供 SCADA/BAS 作為 Client 讀取內部軟元件;若採 BACnet IP,
        需另加裝 BACnet 閘道器轉換。
   2. 本程式為機房控制盤層級之開機/停機/連鎖保護邏輯範例,實際
      I/O 位址配置 (X/Y/D 元件編號)、Fail-safe 邏輯 (常開/常閉選擇)、
      以及台數控制/群控邏輯 (未來多台主機擴充) 應於詳細設計階段
      依正式 I/O 清單與現場設備規格確認後補充。
   3. 建議於 GX Works3 專案中,將本 ST 程式作為一個 Program POU,
      並於 Global Label 或 Program Label 中完成 X/Y/D 元件對應配置。
   ================================================================ *)
