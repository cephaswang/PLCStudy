# PLC 教程 40:轉換指令 TOD 與 FRD
# PLC Training 40: Converters – TOD and FRD

> 來源 Source:<https://www.youtube.com/watch?v=5784mLRttVs&list=PLI78ZBihrkE3nnGIj2WmHb_GoWjFlfFIu&index=40>
> 平台 Platform:Allen-Bradley(RSLogix 500 Pro / SLC 500 風格 Style)

---

## 目錄 Contents

1. [簡介 Introduction](#1-簡介--introduction)
2. [建立程式 Building the Rung](#2-建立程式--building-the-rung)
3. [實驗一:整數 8 Experiment 1: Integer 8](#3-實驗一整數-8--experiment-1-integer-8)
4. [實驗二:整數 14 與 888 Experiment 2: Integers 14 and 888](#4-實驗二整數-14-與-888--experiment-2-integers-14-and-888)
5. [重點整理 Summary](#5-重點整理--summary)

---

## 1. 簡介 | Introduction

**中文**
本節介紹 Compute / Math 分頁中的兩個**轉換指令**:

| 指令 | 英文 | 功能 |
|------|------|------|
| **TOD** | To BCD | 把**整數(Integer)** 轉換成 **BCD** 碼 |
| **FRD** | From BCD | 把 **BCD** 碼轉換回**整數** |

兩者都是**輸出指令**,各有一個 **Source** 與一個 **Dest**。

> **BCD(Binary Coded Decimal,二進位編碼十進位碼)**:用 4 個位元表示十進位的 1 位數字(0 到 9)。例如十進位 **14** 的 BCD 為 `0001 0100`(1 → `0001`、4 → `0100`)。

**English**
This lesson covers the two **conversion instructions** in the Compute / Math tab:

| Instruction | Name | Function |
|------|------|------|
| **TOD** | To BCD | Converts an **integer** to **BCD** |
| **FRD** | From BCD | Converts **BCD** back to an **integer** |

Both are **output instructions**, each with one **Source** and one **Dest**.

> **BCD (Binary Coded Decimal)**: each decimal digit (0–9) is represented by 4 bits. For example decimal **14** in BCD is `0001 0100` (1 → `0001`, 4 → `0100`).

---

## 2. 建立程式 | Building the Rung

**中文**
因為兩個都是輸出指令,必須以**分支(Branch)並聯**放置:

- Rung 0:`SW1`(`I:0/0`)→ 分支 { `TOD` / `FRD` }

| 指令 | Source | Dest | 說明 |
|------|--------|------|------|
| `TOD` | `N7:0`(整數) | `B3:0`(二進位) | 整數 → BCD |
| `FRD` | `B3:0`(二進位) | `N7:1`(整數) | BCD → 整數 |

重點:**TOD 的 Dest 就是 FRD 的 Source(`B3:0`)**,所以 FRD 會把 TOD 剛轉出的 BCD 再轉回整數,方便驗證兩個指令。

**English**
Since both are output instructions, place them in **parallel branches**:

- Rung 0: `SW1` (`I:0/0`) → branch { `TOD` / `FRD` }

| Instruction | Source | Dest | Description |
|------|--------|------|------|
| `TOD` | `N7:0` (integer) | `B3:0` (binary) | Integer → BCD |
| `FRD` | `B3:0` (binary) | `N7:1` (integer) | BCD → integer |

Key point: **the TOD Dest is the FRD Source (`B3:0`)**, so FRD converts the BCD that TOD just produced back to an integer, which lets you verify both instructions.

---

## 3. 實驗一:整數 8 | Experiment 1: Integer 8

**中文**
1. 在 `N7:0` 輸入 **8**,導通 `SW1`。
2. 指令中的 `B3:0` 顯示為 **`0008h`**(以十六進位顯示,不會顯示完整 16 位元二進位)。
3. 要看實際位元,開啟 **B3 資料檔**:`B3:0` 的低 4 位元為 **`1000`**(即 8)。
4. `FRD` 把 `B3:0` 轉回整數,`N7:1` = **8**。

![TOD 8 → BCD `0008h`,FRD 轉回 8 / TOD 8 → BCD `0008h`, FRD back to 8](images/ab40_01.jpg)

*圖 1:`TOD` Source `N7:0` = 8,Dest `B3:0` = `0008h`;`FRD` Source `B3:0` = `0008h`,Dest `N7:1` = 8。B3 資料檔中 `B3:0` 的 bit 3 為 1(`1000`)。*
*Fig. 1: `TOD` Source `N7:0` = 8, Dest `B3:0` = `0008h`; `FRD` Source `B3:0` = `0008h`, Dest `N7:1` = 8. In the B3 data file, bit 3 of `B3:0` is 1 (`1000`).*

**English**
1. Enter **8** in `N7:0` and turn `SW1` ON.
2. The instruction shows `B3:0` as **`0008h`** (displayed in hexadecimal, not the full 16-bit binary).
3. To see the actual bits, open the **B3 data file**: the low 4 bits of `B3:0` are **`1000`** (which is 8).
4. `FRD` converts `B3:0` back to an integer, so `N7:1` = **8**.

---

## 4. 實驗二:整數 14 與 888 | Experiment 2: Integers 14 and 888

**中文**
**整數 14**

- `N7:0` = 14 → `B3:0` = **`0014h`**。
- 二進位:`0001 0100`。低 4 位元(個位 4)為 `0100`,上一組(十位 1)為 `0001`。
- `FRD` → `N7:1` = **14**。

**整數 888**

- BCD 為 `1000 1000 1000`(三個 8,各以 `1000` 表示)= **`0888h`**。

| 整數 Integer | BCD(二進位 Binary) | 顯示 Display |
|:---:|:---|:---:|
| 8 | `0000 0000 0000 1000` | `0008h` |
| 14 | `0000 0000 0001 0100` | `0014h` |
| 888 | `0000 1000 1000 1000` | `0888h` |

![TOD 14 → BCD `0014h`,FRD 轉回 14 / TOD 14 → BCD `0014h`, FRD back to 14](images/ab40_02.jpg)

*圖 2:`TOD` Source `N7:0` = 14,Dest `B3:0` = `0014h`;`FRD` Dest `N7:1` = 14。B3 資料檔中 `B3:0` 為 `0001 0100`。*
*Fig. 2: `TOD` Source `N7:0` = 14, Dest `B3:0` = `0014h`; `FRD` Dest `N7:1` = 14. In the B3 data file `B3:0` is `0001 0100`.*

**關於 FRD 的 Source**

`FRD` 的 Source(`B3:0`)同時是 TOD 的 Dest。你雖然可以在資料檔中手動改 `B3:0`,但 **TOD 每次掃描都會重新寫入該位址**,所以實際使用的是 TOD 轉出來的值。要單獨測試 FRD,請使用**不同的位址**。

**English**
**Integer 14**

- `N7:0` = 14 → `B3:0` = **`0014h`**.
- Binary: `0001 0100`. The low 4 bits (the units digit 4) are `0100`; the next group (the tens digit 1) is `0001`.
- `FRD` → `N7:1` = **14**.

**Integer 888**

- BCD is `1000 1000 1000` (three 8s, each written `1000`) = **`0888h`**.

(See the table above.)

**About the FRD Source**

The `FRD` Source (`B3:0`) is also the TOD Dest. You can edit `B3:0` manually in the data file, but **TOD rewrites that address every scan**, so the value actually used is the one TOD produced. To test FRD on its own, use a **different address**.

---

## 5. 重點整理 | Summary

**中文**
1. **TOD**:整數 → BCD;**FRD**:BCD → 整數。兩者皆為**輸出指令**,需並聯於分支中。
2. BCD 每 **4 個位元**代表一位十進位數字,數值在指令中以**十六進位**顯示,所以 BCD 看起來像十進位數字(例如 `0014h` 代表 14)。
3. 要看實際位元,開啟 **B3(Binary)資料檔**。
4. TOD 的 Dest 可直接作為 FRD 的 Source,用來驗證轉換結果。
5. 若 FRD 的 Source 同時是 TOD 的 Dest,手動修改該位址無效,因為會被 TOD 覆寫。
6. 建議在軟體中多練習不同的數字。

**補充(非影片內容)**:BCD 常用於連接**七段顯示器、數位撥碼開關**等裝置。16 位元 BCD 最多表示 4 位十進位數(0 到 9999);BCD 每組 4 位元只允許 0 到 9。

**English**
1. **TOD**: integer → BCD; **FRD**: BCD → integer. Both are **output instructions** and must be placed in parallel branches.
2. Each **4 bits** of BCD represent one decimal digit, and the value is shown in **hexadecimal** in the instruction, so BCD looks like a decimal number (e.g. `0014h` means 14).
3. To see the actual bits, open the **B3 (Binary)** data file.
4. The TOD Dest can be used directly as the FRD Source to verify the conversion.
5. If the FRD Source is also the TOD Dest, manual edits to that address have no effect because TOD overwrites them.
6. Practice with different numbers in the software.

**Supplement (not from the video):** BCD is commonly used with **seven-segment displays and digital thumbwheel switches**. A 16-bit BCD word holds up to 4 decimal digits (0–9999), and each 4-bit group may only contain 0–9.

---

## 附:檔案結構 | Appendix: File Layout

```
PLC_40_Converters_TOD_FRD.md
images/
├── ab40_01.jpg   # TOD / FRD with integer 8 (B3:0 = 0008h)
└── ab40_02.jpg   # TOD / FRD with integer 14 (B3:0 = 0014h)
```
