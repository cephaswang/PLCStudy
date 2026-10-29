# Fanuc PMC – Keep Relay (K Parameter) 中英對照教程
# Fanuc PMC – Keep Relays (K Parameter) Explained: Bilingual Tutorial

> **來源 Source:** YouTube – *Fanuc PMC - Keep Relays (K Parameter) Explained in English*
> https://www.youtube.com/watch?v=T8P3brt4L8U&list=PLAVTF-IF9aPXg0zNdScXJs6jOqepUE5U7
>
> **說明 Note:** 本文依據影片英文字幕與投影片截圖(`images/f01_01.jpg` ~ `f01_06.jpg`)整理成教程。字幕為自動生成,有若干辨識錯誤(如 "key parameter / keep release" 實為 K parameter / keep relay,"cheap conveyor" 實為 chip conveyor),已依投影片與上下文修正。
> Organized from the video's auto-generated English subtitles and slide screenshots (`images/f01_01.jpg` – `f01_06.jpg`). Recognition errors (e.g. "key parameter / keep release" → K parameter / keep relay; "cheap conveyor" → chip conveyor) were corrected from the slides and context.
>
> **位址寫法 Address notation:** 投影片寫 `K14#0`,影片口述與梯形圖寫 `K14.0`,兩者相同(位元組 K14 的第 0 位元)。
> Slides write `K14#0`, while the narration and ladder screen use `K14.0` — they mean the same thing (bit 0 of byte K14).

**圖檔目錄 Image folder:**

```
Fanuc_PMC_Keep_Relay_K_Parameter_中英對照教程.md
images/
├── f01_01.jpg   PMC KEEP RELAY SCREEN      (§6)
├── f01_02.jpg   PMC PARAMETER SCREEN       (§7)
├── f01_03.jpg   Keep relay addresses       (§8)
├── f01_04.jpg   How to display K900+       (§9)
├── f01_05.jpg   User Keep Relays           (§10)
└── f01_06.jpg   PMC ladder screen          (§11)
```

---

## 目錄 Contents

1. [本課學什麼 What You Will Learn](#1-本課學什麼--what-you-will-learn)
2. [什麼是 Keep Relay What Is a Keep Relay](#2-什麼是-keep-relay--what-is-a-keep-relay)
3. [非易失性記憶體 Non-Volatile Memory](#3-非易失性記憶體--non-volatile-memory)
4. [K 參數的功能 Functions of K Parameters](#4-k-參數的功能--functions-of-k-parameters)
5. [實例:遮蔽外部報警 Example: Shielding an External Alarm](#5-實例遮蔽外部報警--example-shielding-an-external-alarm)
6. [K 參數畫面與位址 The K Parameter Screen and Addressing](#6-k-參數畫面與位址--the-k-parameter-screen-and-addressing)
7. [PMC 參數畫面與 RAM Write Enable](#7-pmc-參數畫面與-ram-write-enable--pmc-parameter-screen-and-ram-write-enable)
8. [Keep Relay 位址範圍與系統 K 參數 Address Ranges and System Keep Relays](#8-keep-relay-位址範圍與系統-k-參數--address-ranges-and-system-keep-relays)
9. [如何顯示 K900 之後的參數 How to Display K900+](#9-如何顯示-k900-之後的參數--how-to-display-k900)
10. [使用者 K 參數 User Keep Relays](#10-使用者-k-參數--user-keep-relays)
11. [梯形圖中的 K How K Looks in Ladder](#11-梯形圖中的-k--how-k-looks-in-ladder)
12. [重點整理 Summary](#12-重點整理--summary)
13. [自我檢測 Quick Check](#13-自我檢測--quick-check)

---

## 1. 本課學什麼 | What You Will Learn

**中文**
本課介紹 Fanuc CNC 中使用的 Keep Relay(保持型繼電器,俗稱 K 參數)。資深的 Fanuc 工程師大多已熟悉它,但若你剛接觸 Fanuc,也沒問題,影片從基礎講起。本課內容:

- 什麼是 Keep Relay
- Keep Relay 的功能
- 如何啟用(設定)它
- 它在梯形圖(Ladder Diagram)中的樣子

**English**
In this lesson we cover the keep relay used in Fanuc CNCs. Experienced Fanuc people will probably know it already, but if you are new to Fanuc that is fine — the video starts from the basics. We will learn:

- What a keep relay is
- What its functions are
- How it is enabled
- What it looks like in a ladder diagram

---

## 2. 什麼是 Keep Relay | What Is a Keep Relay

**中文**
Keep Relay 在 Fanuc 中又稱 **K 參數(K parameter)**。不同的人有不同叫法:K 參數、Keep Relay,也有人叫「旁路繼電器(bypass relay)」。本教程統一稱為 **K 參數 / Keep Relay**。

對維修與調試人員來說,K 參數的用途**非常廣泛**。

**English**
The keep relay is also called the **K parameter** in Fanuc. People use different names: K parameter, keep relay, or even "bypass relay". In this tutorial we use **K parameter / keep relay** interchangeably.

For maintenance and commissioning (debugging) personnel, keep relays are still very widely used.

**原投影片文字 Original slide text:**

> **Keep Relay (K):**
> FANUC [PMC maintenance] K parameter, for maintenance and debugging personnel, the use is still very wide, the holding type relay is a non-volatile memory, so even if the power is cut off, its storage content will not be lost. Do you know its function?

**中譯:**
> **Keep Relay (K):**
> FANUC【PMC 維護】K 參數,對維修與調試人員而言用途仍然非常廣泛;保持型繼電器屬於非易失性記憶體,因此即使斷電,其儲存內容也不會遺失。你知道它的功能嗎?

---

## 3. 非易失性記憶體 | Non-Volatile Memory

**中文**
Keep Relay 是「保持型」繼電器,屬於**非易失性記憶體(non-volatile memory)**:即使斷電,儲存的內容也**不會遺失**。

舉例:機床運轉中,你開啟了某幾個 K 參數;之後機床關機,再次開機時,這些 K 參數仍然保持**關機前的數值**,不需要重新設定。

**English**
A keep relay is a *holding-type* relay stored in **non-volatile memory**: even if power is cut off, its stored contents are **not lost**.

Example: while the machine is running you turn on some keep relays. Later the machine is shut down. When you power it up again, the keep relay data is still at its **previous values** — nothing is lost after a power-off.

| | 普通內部繼電器 (e.g. R) | Keep Relay (K) |
|---|---|---|
| | Ordinary internal relay (e.g. R) | Keep relay (K) |
| 斷電後 After power-off | 通常不保持 Not retained* | **保持 Retained** |

> \* 此行為為補充說明,非影片原話。 / *This row is added context, not stated in the video.*

---

## 4. K 參數的功能 | Functions of K Parameters

**原投影片 Original slide — FUNCTION OF K PARAMETER**

| # | English (slide) | 中文 |
|---|---|---|
| 1 | Some machine functions can be turned on/off | 可開啟 / 關閉部分機床功能 |
| 2 | Some external alarms can be shielded | 可遮蔽(屏蔽)部分外部報警 |
| 3 | Some system interfaces can be hidden | 可隱藏部分系統介面 |
| 4 | It can play a maintenance role in PMC | 可在 PMC 中擔任維護角色 |
| 5 | It can be used as auxiliary signal in PMC | 可作為 PMC 的輔助訊號 |
| 6 | System K parameters play a special function | 系統 K 參數具有特殊功能 |

### 4.1 開啟 / 關閉部分機床功能 | Turn Some Machine Functions On/Off

**中文**
機床製造商可能把某些功能獨立出來,用 K 參數控制。例如:你可以用某個 K 參數**開啟或關閉排屑機(chip conveyor)**。

**English**
A machine builder may implement certain machine functions separately and control them with K parameters. For example, you can turn the **chip conveyor** on or off using a K parameter.

### 4.2 遮蔽(屏蔽)部分外部報警 | Shield Some External Alarms

**中文**
可以用 K 參數把某些**外部報警**遮蔽掉。詳見下一節的實例。

**English**
Some **external alarms** can be shielded (masked) using K parameters. See the worked example in the next section.

### 4.3 隱藏部分系統介面 | Hide Some System Interfaces

**中文**
部分系統介面可以被隱藏(影片稍後以系統 K 位址示範,見第 8 節)。

**English**
Some system interfaces can be hidden (the video shows the related system K addresses later — see §8).

### 4.4 在 PMC 中擔任維護與輔助訊號 | Maintenance Role and Auxiliary Signal in PMC

**中文**
K 參數可以在 PMC 程式中扮演**維護用途**,也可以當作**輔助訊號**。例如感測器壞了時,可用 K 位址代替真實的輸入訊號(見下一節)。

**English**
K parameters can play a **maintenance role** in the PMC and be used as an **auxiliary signal**. For example, when a sensor is faulty you can substitute a K address for the real input signal (see next section).

### 4.5 系統 K 參數具特殊功能 | System K Parameters Have Special Functions

**中文**
K 參數分為**一般 K 參數**與**特殊(系統)K 參數**。系統 K 參數屬於特殊 Keep Relay,見第 8 節。

**English**
There are **normal K parameters** and **special K parameters**. System K parameters belong to the special keep relays — see §8.

---

## 5. 實例:遮蔽外部報警 | Example: Shielding an External Alarm

**中文**
情境:

1. 你有一條**輸入輸送帶**,負責把工件送進 CNC。
2. 機床出現報警:**「輸送帶未旋轉」**。
3. 經排查,發現是**輸送帶旋轉偵測感測器損壞(NG)**,但輸送帶其實**仍然在運轉**。
4. 你現在沒有備品,也許將來才更換。在那之前,必須**遮蔽這個報警**,否則機床無法正常工作。

做法:原本感測器接在 **X0.0**,現在改在 PMC 程式中用 **K0.0** 取代 X0.0,並**永久把 K0.0 設為 ON**。這樣 PMC 就會「以為」感測器有訊號,報警即被旁路(bypass)。這就是 K 參數作為**輔助訊號**的用法。

**English**
Scenario:

1. You have an **input conveyor** that feeds parts into the CNC.
2. The machine shows an alarm: **"Conveyor is not rotating."**
3. Troubleshooting shows the **rotation-detection sensor is NG (faulty)**, but the conveyor is **still running** fine.
4. You have no spare right now — maybe you'll replace it in the future. Until then you must **shield that alarm**.

How: the sensor was originally wired to **X0.0**. In the PMC program you use **K0.0** instead of X0.0 and **turn K0.0 permanently ON**. The PMC then sees a "sensor signal" and the alarm is bypassed. This is the use of a K parameter as an **auxiliary signal**.

```
改前 Before:   X0.0 (真實感測器 real sensor)  ──┤ ├── ... 報警邏輯 alarm logic
改後 After :   K0.0 (永久 ON permanently ON)   ──┤ ├── ... 報警邏輯 alarm logic
```

> ⚠️ **安全提醒 Safety note(補充 added):** 旁路感測器只能是**臨時措施**,且僅限於安全無虞的檢測訊號;**不可旁路與人身安全相關的訊號**(如門鎖、急停)。修復後請恢復原狀並記錄。
> Bypassing a sensor should only be a **temporary measure**, and only for non-safety detection signals. **Never bypass personnel-safety signals** (door interlocks, E-stop, etc.). Restore the original logic after repair and document the change.

---

## 6. K 參數畫面與位址 | The K Parameter Screen and Addressing

![PMC KEEP RELAY SCREEN](images/f01_01.jpg)

*圖 1 / Figure 1(`f01_01.jpg`):PMC Keep Relay 畫面 / PMC KEEP RELAY SCREEN*

**中文**
打開 **PMC Keep Relay 畫面**(畫面標題為 `PMC PRM (KEEP RELAY) #001`),你會看到:左邊是**位址(ADDRESS)**,右邊是**資料(DATA)**。

- 本例畫面分兩欄,左欄 **K00 ~ K14**,右欄 **K15 ~ K29**,每個位址後面是 8 位數的資料。
- 每個位址是一個**位元組(byte)= 8 個位元(bit)**,位元以八進位式的 0~7 編號。例如 **K0** 包含 **K0.0、K0.1、K0.2、K0.3、K0.4、K0.5、K0.6、K0.7**;**K1** 包含 K1.0 ~ K1.7,依此類推。
- 畫面下方的軟鍵(Soft key)有:**TIMER、COUNTR、KEEPRL、DATA、SETING**,目前選中的是 **KEEPRL**。
- 在此畫面直接把位元設為 1 / 0,就可以旁路訊號或切換功能。

另外,PMC 有不同的程式類型(影片提到多個程式層級,以及 **DCS PMC**)。**DCS PMC 也可以使用 Keep Relay,畫面基本相同。**

**English**
Open the **PMC keep relay screen** (title `PMC PRM (KEEP RELAY) #001`). On the left is the **ADDRESS**, on the right the **DATA**.

- The screen has two columns: **K00 – K14** on the left and **K15 – K29** on the right; each address is followed by 8 data digits.
- Each address is one **byte = 8 bits**, numbered 0–7. For example **K0** contains **K0.0, K0.1, K0.2, K0.3, K0.4, K0.5, K0.6, K0.7**; **K1** contains K1.0 – K1.7, and so on.
- The soft keys at the bottom are **TIMER, COUNTR, KEEPRL, DATA, SETING**, with **KEEPRL** currently selected.
- Setting a bit to 1 / 0 directly on this screen bypasses a signal or switches a function.

PMC also exists in different program types (the video mentions several program levels and **DCS PMC**). **DCS PMC can use keep relays too, and the screen looks the same.**

```
ADDRESS   DATA (bit7 ... bit0)
K00       0 0 0 0 0 0 0 0      ← K0.7 ... K0.0
K01       0 0 0 0 0 0 0 0      ← K1.7 ... K1.0
K02       ...
```

---

## 7. PMC 參數畫面與 RAM Write Enable | PMC Parameter Screen and RAM Write Enable

![PMC PARAMETER SCREEN](images/f01_02.jpg)

*圖 2 / Figure 2(`f01_02.jpg`):PMC 參數(設定)畫面 / PMC PARAMETER SCREEN*

**中文**
情境:機床正在**自動模式(Auto)**下運行(或正在加工),此時出現一個可以遮蔽的報警,你想修改 K 參數——可以嗎?

可以。投影片說明:**不必等到加工結束才修改**,可提高工作效率。**前提**是先確認所修改的 K 參數**不會影響正常加工**,也不會觸發資訊報警。

設定方法:在 **PMC 設定畫面(`PMC PRM (SETTING)`)**中,把 **RAM WRITE ENABLE**(投影片稱「RAM can be written」)設為 **1(YES)**。

- 若為 **0**,在自動運轉中**不能**修改 K 參數。
- 設為 **1** 後,才能在自動模式 / 機床運轉中修改 K 參數。

**English**
Situation: the machine is running in **Auto mode** (or machining) and an alarm appears that can be shielded. You want to change a K parameter — is that possible?

Yes. The slide says you **don't have to wait until machining finishes**, which improves efficiency. **First** make sure the modified K parameter **will not affect normal processing** and no information alarm will appear.

Setting method: on the **PMC setting screen (`PMC PRM (SETTING)`)** switch **RAM WRITE ENABLE** (the slide calls it "RAM can be written") to **1 (YES)**.

- If it is **0**, you **cannot** change K parameters while in Auto / while the machine is running.
- Once set to **1**, you can modify K parameters in Auto mode or while running.

| RAM WRITE ENABLE | 自動模式下能否修改 K Can edit K in Auto? |
|---|---|
| 0 (NO) | ❌ 不能 No |
| 1 (YES) | ✅ 可以 Yes |

**截圖中的各項設定值 Settings shown in the screenshot:**

| 項目 Item | 值 Value | 選項 Options |
|---|---|---|
| TRACE START | 0 | 0: MANUAL 1: AUTO |
| EDIT ENABLE | 1 | 0: NO 1: YES |
| WRITE TO F-ROM (EDIT) | 1 | 0: NO 1: YES |
| **RAM WRITE ENABLE** | **1** | 0: NO 1: YES |
| DATA TBL CNTL SCREEN | 0 | 0: YES 1: NO |
| HIDE PMC PARAM | 0 | 0: NO 1: YES |
| PROTECT PMC PARAM | 0 | 0: NO 1: YES |
| HIDE PMC PROGRAM | 0 | 0: NO 1: YES |
| IO GROUP SELECTION | 0 | 0: HIDE 1: SHOW |
| LADDER START | 0 | 0: AUTO 1: MANUAL |
| ALLOW PMC STOP | 0 | 0: NO 1: YES |
| PROGRAMMER ENABLE | 1 | 0: NO 1: YES |

---

## 8. Keep Relay 位址範圍與系統 K 參數 | Address Ranges and System Keep Relays

![Keep relay addresses](images/f01_03.jpg)

*圖 3 / Figure 3(`f01_03.jpg`):Keep relay 位址與部分系統 Keep Relay(Oi-D PMC) / Keep relay addresses and some system keep relays (Oi-D PMC)*

### 8.1 位址範圍 | Address Ranges

| 資料種類 Data kind | Oi-D PMC |
|---|---|
| 使用者區 User area (Size) | **K0 – K99**(100 Bytes) |
| 系統區 System area (Size) | **K900 – K999**(100 Bytes) |
| 非易失性記憶體控制位址 Non-volatile memory control address | **K909** |

> 字幕將此處辨識成 "K90.909",實際依投影片為 **K909**。
> The subtitle garbled this as "K90.909"; the slide shows **K909**.

### 8.2 部分系統 Keep Relay | Some System Keep Relays

**中文**
**系統 Keep Relay** 用來啟用 / 停用許多系統層級的選項功能。例如,**安全電路介面(Safety circuit interface)**對應 **安全 I/O 單元(Safety IO unit)**,用 **K928.7** 與 **K929.0** 啟用或停用。通常我們**不會**隨意去動這些系統 K 參數。

**English**
**System keep relays** enable or disable many system-level option functions. For example, the **safety circuit interface** (using the **Safety IO unit**) is enabled/disabled with **K928.7** and **K929.0**. Normally we **do not** touch these system K parameters casually.

| 選項名稱 Option name | 需增加的 I/O I/O to be added | Keep relay |
|---|---|---|
| 自動滅火器 Automatic fire-extinguisher<br>機器人介面 Robot interface<br>側面自動門 Side automatic door<br>中心出水 Center-through coolant<br>錐形部位排屑功能 Function for cleaning chips from tapered portions | Wiring PCB I/O Module (Basic) | **K928.4** |
| 刀具偏擺檢測功能 Tool runout detection function | Wiring PCB I/O Module (Basic) | **K928.5** |
| KAWATATEC 托盤交換器 KAWATATEC pallet changer | Wiring PCB I/O module type-2 | **K928.6** |
| 安全電路介面 Safety circuit interface | Safety IO unit | **K928.7**<br>**K929.0** |
| I/O 單元 A 型 I/O unit model A | FANUC I/O Unit-MODEL A | **K932.0** |
| I/O Link 連接單元 I/O link connection unit | FANUC I/O Link connection unit | **K932.1** |
| 附加 I/O 基本 Additional I/O basic<br>附加 I/O 擴充 1/2/3 Additional I/O expansion 1/2/3 | Wiring PCB I/O Module (Basic) /<br>Wiring PCB I/O module (Expansion B) | **K932.2** |
| 副操作面板附加 I/O(控制器櫃側 / 操作面板側)<br>Additional I/O for sub-operator's panel (Controller cabinet side / Operator's panel side) | Power magnetics cabinet I/O module | **K932.3** |

**關鍵特性 Key characteristics:**

- 在一般模式下,**看不到**這些 K 位址的真實數值(可以看到位址 K900、K901…,但**數值無法監視**)——詳見第 9 節。
  In normal mode you **cannot see** the actual values of these K addresses (you see addresses K900, K901 … but **not the values**) — see §9.
- 這些是**特殊 Keep Relay**,系統區共 **100 個位元組**。
  These are the **special keep relays**; the system area is **100 bytes**.

> ⚠️ 修改系統 K 參數可能影響機床安全與系統穩定,**務必確認用途並先備份 PMC / 參數**。影片建議可暫停影片抄下此表或截圖。
> Changing system K parameters can affect machine safety and system stability — **know exactly what a bit does, and back up PMC / parameters first**. The video suggests pausing to note this table down or taking a screenshot. *(safety note added)*

---

## 9. 如何顯示 K900 之後的參數 | How to Display K900+

![How to display parameters after K900](images/f01_04.jpg)

*圖 4 / Figure 4(`f01_04.jpg`):左—未按急停,K900 區為空白;右—按下急停後顯示實際數值 / Left — E-stop not pressed, K900 area blank; Right — values shown after pressing E-stop*

**投影片標題 Slide title:** *How to display parameters the after K900?*
**投影片說明 Slide text:** *The No. 900 to 999 keep relay setting screen can be displayed by pressing the EMERGENCY STOP button.*
**中譯:** 第 900 ~ 999 號 Keep Relay 設定畫面,按下**急停按鈕**即可顯示。

**中文**
- **左圖(正常狀態,MDI,急停未按下)**:K900 區的資料顯示為**空白**,無法監視數值;畫面下方提示「**此功能被保護**」(This function is protected)。
- **右圖(按下急停後)**:可看到 **K900 ~ K999** 的**實際數值**(8 位元二進位 + 兩位十六進位值),並且**可以修改**。截圖中可見例如 K900 = `02`、K902 = `01`、K906 = `04`、K920 = `04`。

**English**
- **Left (normal state, MDI, E-stop not pressed):** the K900 area data is **blank** — values cannot be monitored; the message line shows "**此功能被保護**" ("This function is protected").
- **Right (after pressing E-stop):** you can see the **actual values** of **K900 – K999** (8 binary bits plus a two-digit hex value) and you **can change** them. In the screenshot, for example, K900 = `02`, K902 = `01`, K906 = `04`, K920 = `04`.

| 狀態 State | K900–K999 顯示 Display | 可修改 Editable |
|---|---|---|
| 急停未按 E-stop released | 空白 / 受保護 Blank / protected | ❌ |
| 急停按下 E-stop pressed | 顯示實際值 Actual values shown | ✅ |

---

## 10. 使用者 K 參數 | User Keep Relays

![User Keep Relays](images/f01_05.jpg)

*圖 5 / Figure 5(`f01_05.jpg`):使用者 Keep Relay(K14、K15) / User Keep Relays (K14, K15)*

**中文**
**使用者 K 參數**的功能由機床製造商(或 PMC 程式設計者)定義。下表為投影片中的 **K14、K15**(符號 ○ 通常表示預設值):

**K14**

| 位址 Address | 設定 Setting | 功能 Function |
|---|---|---|
| K14#0 | 0 ○ | 啟用自訂 PMC 編輯 / Enables custom PMC editing |
| | 1 | 停用自訂 PMC 編輯 / Disables custom PMC editing |
| K14#1 | 0 ○ | 自訂 PMC 功能不控制主軸與切削進給倍率 / The custom PMC function does not control spindle and cutting feed overrides |
| | 1 | 自訂 PMC 功能控制主軸與切削進給倍率 / The custom PMC function controls spindle and cutting feed overrides |
| K14#2 | 0 ○ | 在 MEM 模式 / 遠端模式下開啟 SI8.0 / Turns on SI8.0 in the MEM mode/remote mode |
| | 1 | 僅在 MEM 模式下開啟 SI8.0 / Turns on SI8.0 in the MEM mode |
| K14#3 | 0 ○ | 使用標準的附加軸夾緊控制訊號 / Uses the additional axis clamp control signal as standard |
| | 1 | 以自訂 PMC 功能指派附加軸夾緊控制訊號 / Assigns the additional axis clamp control signal with the custom PMC function |
| K14#4 | 0 ○ | 不允許自訂 PMC 功能控制機內清洗冷卻液 / Does not allow the custom PMC function to control the coolant for cleaning the inside of the machine |
| | 1 | 允許自訂 PMC 功能控制機內清洗冷卻液 / Allows the custom PMC function to control that coolant |
| K14#5 | 0 ○ | 不以自訂 PLC 功能執行軸互鎖控制 / Does not execute axis interlock control using the custom PLC function |
| | 1 | 以自訂 PLC 功能執行軸互鎖控制 / Executes axis interlock control using the custom PLC function |
| K14#6 | 0 ○ | 不以自訂 PLC 功能執行急停控制 / Does not execute emergency stop control using the custom PLC function |
| | 1 | 以自訂 PLC 功能執行急停控制 / Executes emergency stop control using the custom PLC function |
| K14#7 | 0 ○ | 不以自訂 PLC 功能執行進給保持控制 / Does not execute feed hold control using the custom PLC function |
| | 1 | 以自訂 PLC 功能執行進給保持控制 / Executes feed hold control using the custom PLC function |

**K15**

| 位址 Address | 設定 Setting | 功能 Function |
|---|---|---|
| K15#0, #1, #2, #4, #5 | — | 出廠時依機床規格調整 / Factory-adjusted according to the specifications of the machine |
| K15#3, K15#6 | 0 ○ / 1 | 保留 / Reservation |
| **K15#7** | 0 ○ | **不使用**自訂 PLC 功能 / Does not use the custom PLC function |
| | 1 | **使用**自訂 PLC 功能 / Uses the custom PLC function |

**影片範例(K15.7)/ Video example (K15.7):**

1. 你在梯形圖中為**排屑機(chip conveyor)**寫了一段自訂邏輯。
2. 執行時,**輸入訊號正常**(可在監視畫面看到輸入 ON/OFF 變化),但**輸出沒有反應**。
3. 原因:**K15.7 = 0(停用)**,自訂 PLC 功能未被使用。
4. 把 **K15.7 設為 1(啟用)** 後,排屑機輸出就恢復正常。

此外,機床製造商會依需求自訂其他 K 位元,用來**遮蔽**某項檢測、**啟用**某項功能、**旁路門開關**、**啟用手動進料按鈕**等。具體用途**取決於機床製造商**。如果你自己是程式設計者,在編寫 PMC 程式時就可以**自行決定**哪些 K 位址控制哪些功能。

**English**
**User keep relays** are defined by the machine builder (or the PMC programmer). The tables above (bilingual) are the **K14 and K15** bytes from the slide (the ○ mark normally denotes the default value).

**Video example (K15.7):**

1. In your ladder program you wrote custom logic to control the **chip conveyor**.
2. When you run it, the **input is fine** (you can monitor the input turning ON/OFF), but the **output does not respond**.
3. Cause: **K15.7 = 0 (disabled)**, so the custom PLC function is not used.
4. After you **set K15.7 to 1 (enabled)**, the chip conveyor output works.

Machine builders also define other K bits to **shield** a check, **enable** a function, **bypass a door**, **enable a manual-feed button**, etc. The exact usage **depends on the machine builder**. If you are the programmer, you can **decide yourself** which K address controls which function when you write the PMC program.

> ⚠️ **安全提醒 Safety note(補充 added):** K14#5(軸互鎖)、K14#6(急停控制)、K14#7(進給保持)涉及安全功能,變更前務必確認機床廠說明。
> K14#5 (axis interlock), K14#6 (emergency stop control) and K14#7 (feed hold) are safety-related — confirm with the machine builder's documentation before changing them.

---

## 11. 梯形圖中的 K | How K Looks in Ladder

![PMC ladder screen](images/f01_06.jpg)

*圖 6 / Figure 6(`f01_06.jpg`):PMC 梯形圖監視畫面 / PMC LADDER DIAGRAM MONITOR*

**中文**
在 **PMC 梯形圖畫面**(`PMC LADDER DIAGRAM MONITOR`)中,K 參數就像一般接點出現。截圖中被高亮的線圈是 **R0546.1**,其邏輯為:

- 串聯:**R0450.5**(常開)→ **R0450.4**(常閉)→ **K0018.2**(常開)→ 線圈 **R0546.1**
- 並聯:**R0546.1** 自保持(與 R0450.5 並聯);**K0004.0**(與 K0018.2 並聯,即「K18.2 **或** K4.0」)

也就是說,透過 K 參數,我們可以在梯形圖裡**給出實際訊號、旁路訊號,或啟用 / 停用某段邏輯**。

**English**
On the **PMC ladder screen** (`PMC LADDER DIAGRAM MONITOR`), K parameters appear as ordinary contacts. The highlighted coil in the screenshot is **R0546.1**, with this logic:

- Series path: **R0450.5** (NO) → **R0450.4** (NC) → **K0018.2** (NO) → coil **R0546.1**
- Parallel branches: **R0546.1** self-holding (parallel with R0450.5); **K0004.0** (parallel with K0018.2, i.e. "K18.2 **OR** K4.0")

In other words, through K parameters we can **supply an actual signal, bypass a signal, or enable / disable a piece of logic** in the ladder.

```
 R0450.5    R0450.4/    K0018.2                       R0546.1
─┤ ├────────┤/├─────────┤ ├──────────────────────────( )──
  │                      │
 R0546.1                K0004.0
─┤ ├──────┘             ─┤ ├────┘
```

*(文字示意圖,依截圖整理;實際接點以機台畫面為準。 / Text sketch based on the screenshot; refer to the real screen for exact contacts.)*

---

## 12. 重點整理 | Summary

| # | 中文 | English |
|---|---|---|
| 1 | K 參數 = Keep Relay,Fanuc PMC 的保持型繼電器 | K parameter = keep relay, the holding-type relay in Fanuc PMC |
| 2 | 屬非易失性記憶體,斷電不丟失 | Non-volatile: data survives power loss |
| 3 | 可開關機床功能(如排屑機)、遮蔽外部報警、隱藏系統介面 | Can switch machine functions (e.g. chip conveyor), shield external alarms, hide system interfaces |
| 4 | 可作 PMC 輔助 / 維修訊號,例如用 K0.0 取代壞掉的 X0.0 | Usable as auxiliary / maintenance signal, e.g. K0.0 replacing a faulty X0.0 |
| 5 | 位址為八位元一組,如 K0.0 ~ K0.7;Oi-D PMC 使用者區 K0–K99 | 8 bits per byte, e.g. K0.0 – K0.7; Oi-D PMC user area K0–K99 |
| 6 | 自動模式下改 K 參數需 RAM WRITE ENABLE = 1(並確認不影響加工) | Editing K in Auto mode requires RAM WRITE ENABLE = 1 (and must not affect machining) |
| 7 | 系統區 K900–K999(100 位元組),K909 為非易失記憶體控制位址;需按急停才能看 / 改數值 | System area K900–K999 (100 bytes), K909 = non-volatile memory control address; press E-stop to view/edit values |
| 8 | 例:K928.7、K929.0 控制安全電路介面 | e.g. K928.7 and K929.0 control the safety circuit interface |
| 9 | 使用者 K 參數(K14、K15)用途由機床製造商定義;K15.7 = 1 才使用自訂 PLC 功能 | User K bits (K14, K15) are defined by the machine builder; K15.7 = 1 enables the custom PLC function |
| 10 | 梯形圖中 K 以接點形式出現,可旁路或啟用邏輯 | In ladder, K appears as contacts to bypass or enable logic |

---

## 13. 自我檢測 | Quick Check

1. **K 參數斷電後會遺失嗎?** / *Is K parameter data lost at power-off?*
   → 不會,它是非易失性記憶體。 / No — it is non-volatile.

2. **感測器 X0.0 損壞但設備仍可運作,如何臨時遮蔽報警?** / *Sensor X0.0 is faulty but the equipment still works. How do you temporarily shield the alarm?*
   → 在 PMC 中改用 K0.0 取代 X0.0,並把 K0.0 設為 ON。 / Use K0.0 in place of X0.0 in the PMC and turn K0.0 ON.

3. **自動運轉中想改 K 參數,要先做什麼?** / *What must you do first to edit K parameters during Auto operation?*
   → 把 PMC 設定畫面的 RAM WRITE ENABLE 設為 1。 / Set RAM WRITE ENABLE to 1 on the PMC setting screen.

4. **系統 K 區是哪個範圍?如何看到其數值?** / *What is the system K range and how do you see its values?*
   → K900 ~ K999;按下急停後即可看到並修改。 / K900 – K999; press E-stop to view and edit.

5. **排屑機輸入正常但輸出沒反應,可能是哪個 K 位元?** / *Chip conveyor input is fine but the output does not respond — which K bit might be the cause (video example)?*
   → K15.7 = 0,需設為 1 以使用自訂 PLC 功能。 / K15.7 = 0; set it to 1 to use the custom PLC function.

6. **哪兩個 K 位元控制安全電路介面?** / *Which two K bits control the safety circuit interface?*
   → K928.7 與 K929.0。 / K928.7 and K929.0.

---

*感謝觀看 / Thanks for watching — 如喜歡原影片,可分享給朋友。 / If you like the original video, share it with your friends.*
