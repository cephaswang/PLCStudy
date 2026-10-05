# PLC 教程 33:栓鎖與解栓指令 Latch / Unlatch
# PLC Training 33: Latch and Unlatch Logic – Allen-Bradley

> 來源 Source:<https://www.youtube.com/watch?v=fKvLdv3WXuw&list=PLI78ZBihrkE3nnGIj2WmHb_GoWjFlfFIu&index=33>
> 平台 Platform:Allen-Bradley(RSLogix 500 / SLC 500 風格 Style)

---

## 目錄 Contents

1. [簡介 Introduction](#1-簡介--introduction)
2. [傳統自保持(並聯觸點)Seal-in with Parallel Contact](#2-傳統自保持並聯觸點--seal-in-with-parallel-contact)
3. [栓鎖線圈 Latch Coil (OTL)](#3-栓鎖線圈--latch-coil-otl)
4. [常閉停止接點無法解栓 Why an NC Contact Cannot Unlatch](#4-常閉停止接點無法解栓--why-an-nc-contact-cannot-unlatch)
5. [解栓線圈 Unlatch Coil (OTU)](#5-解栓線圈--unlatch-coil-otu)
6. [優先順序與使用規則 Priority and Rules](#6-優先順序與使用規則--priority-and-rules)
7. [重點整理 Summary](#7-重點整理--summary)

---

## 1. 簡介 | Introduction

**中文**
在 Bit 指令選單中可以找到 **Latch(栓鎖,OTL)** 與 **Unlatch(解栓,OTU)** 兩個線圈指令。它們的功能與前面課程介紹的「自保持電路」相同:**即使輸入條件消失,輸出仍然保持導通**;差別是 Allen-Bradley 把這個功能做成了獨立的線圈指令,不需要再並聯接點。

**English**
The Bit instruction group contains the **Latch (OTL)** and **Unlatch (OTU)** coil instructions. They do the same job as the seal-in circuit from earlier lessons: **the output stays ON even after the input condition goes away.** The difference is that Allen-Bradley provides this as dedicated coil instructions, so no parallel contact is needed.

---

## 2. 傳統自保持(並聯觸點)| Seal-in with Parallel Contact

**中文**
先複習傳統做法,Rung 0:

- `PB1`(啟動按鈕,`I:0/0`)與 `LAMP`(`O:0/0`)的常開接點**並聯**
- 串接 `STOP`(停止按鈕,`I:0/2`)的常閉接點
- 輸出為 `LAMP`(`O:0/0`)

按下 PB1 後燈亮,放開後由並聯的 LAMP 接點「自保持」,燈仍然亮;按下 STOP 才會斷開。

**English**
First, a review of the traditional method, Rung 0:

- `PB1` (start button, `I:0/0`) is in **parallel** with a normally open contact of `LAMP` (`O:0/0`)
- A normally closed `STOP` contact (`I:0/2`) is in series
- The output is `LAMP` (`O:0/0`)

Pressing PB1 turns the lamp on; after release, the parallel LAMP contact "seals in" the rung and the lamp stays on. Only pressing STOP breaks the circuit.

---

## 3. 栓鎖線圈 | Latch Coil (OTL)

**中文**
接著在 Rung 1 使用栓鎖線圈:`PB2`(`I:0/1`)→ `LAMP2` 的 **Latch 線圈**(`O:0/1`)。

- 按下 PB2,`LAMP2` 導通。
- 放開 PB2,`LAMP2` **仍然保持導通**——不需要並聯接點。

**English**
Now Rung 1 uses a latch coil: `PB2` (`I:0/1`) → **Latch coil** on `LAMP2` (`O:0/1`).

- Press PB2 and `LAMP2` turns ON.
- Release PB2 and `LAMP2` **stays ON** – no parallel contact is required.

![栓鎖線圈使 LAMP2 保持導通 / Latch coil keeps LAMP2 ON](image/ab33_03.jpg)

*圖 1:上方 Rung 0 為並聯自保持,LAMP 導通;下方 Rung 1 為 Latch 線圈,LAMP2 導通且在放開 PB2 後仍保持。*
*Fig. 1: Rung 0 is the parallel seal-in with LAMP ON; Rung 1 uses a latch coil and LAMP2 stays ON after PB2 is released.*

---

## 4. 常閉停止接點無法解栓 | Why an NC Contact Cannot Unlatch

**中文**
如果像傳統電路一樣,在 Latch 線圈所在的 Rung 中**串接**一個停止接點(`STOP`,`I:0/2`):

- 按下 STOP 後,該 Rung 變為 false,**但 LAMP2 仍然保持導通**。
- 原因:Latch 線圈只有在 Rung 為 true 時才會「設定」輸出;Rung 變 false 時,它**不會**把輸出關掉。

因此使用 Latch 線圈時,**必須另外使用 Unlatch 線圈**來關閉輸出。

**English**
If, as in a traditional circuit, you put a stop contact (`STOP`, `I:0/2`) **in series** in the latch coil's rung:

- Pressing STOP makes the rung false, **but LAMP2 stays ON.**
- Reason: a latch coil only "sets" the output when the rung is true; when the rung goes false it does **not** turn the output off.

So whenever you use a Latch coil, you **must use a separate Unlatch coil** to turn the output off.

![在 Latch Rung 串接 STOP 仍無法關閉輸出 / A series STOP in the latch rung cannot turn the output off](image/ab33_02.jpg)

*圖 2:Rung 1 的 Latch 線圈串接了 STOP 接點;即使 Rung 變 false,LAMP2 仍維持栓鎖狀態。*
*Fig. 2: The latch rung (Rung 1) has a series STOP contact; even when the rung goes false, LAMP2 remains latched.*

---

## 5. 解栓線圈 | Unlatch Coil (OTU)

**中文**
新增 Rung 2:`STOP`(`I:0/2`)的常開接點 → **Unlatch 線圈**,位址與 Latch 線圈**相同**(`LAMP2`,`O:0/1`)。

- 兩個線圈共用同一個位址,所以 Latch 讓它 ON、Unlatch 讓它 OFF。
- 按下 STOP,Unlatch 線圈導通,`LAMP2` 熄滅。
- Unlatch 必須針對**想要關閉的那個線圈位址**。

**English**
Add Rung 2: a normally open `STOP` (`I:0/2`) contact → **Unlatch coil** with the **same address** as the latch coil (`LAMP2`, `O:0/1`).

- Both coils share one address: Latch turns it ON, Unlatch turns it OFF.
- Pressing STOP energizes the Unlatch coil and `LAMP2` turns OFF.
- The Unlatch coil must use the **address of the coil you want to turn off**.

![Latch 與 Unlatch 線圈搭配 / Latch and Unlatch coils together](image/ab33_01.jpg)

*圖 3:Rung 1 為 Latch(L)線圈,Rung 2 為 Unlatch(U)線圈,兩者皆使用 `O:0/1`。*
*Fig. 3: Rung 1 is the Latch (L) coil and Rung 2 is the Unlatch (U) coil, both using `O:0/1`.*

---

## 6. 優先順序與使用規則 | Priority and Rules

### 6.1 實驗現象 | Observed Behavior

**中文**
1. **先按 Unlatch**:輸出尚未栓鎖,所以**沒有任何作用**。
2. **先 Latch 再 Unlatch**:輸出熄滅,Unlatch 生效。
3. **Unlatch 按著不放、Latch 輸入仍為 ON**:Unlatch 具有**優先權**,輸出保持 OFF。
4. **放開 Unlatch 後**:因為 Latch 的輸入接點仍然導通,輸出會**再次導通**。

**English**
1. **Press Unlatch first:** the output is not yet latched, so **nothing happens.**
2. **Latch, then Unlatch:** the output turns OFF; Unlatch takes effect.
3. **Unlatch held while the Latch input is still ON:** Unlatch has **priority**, so the output stays OFF.
4. **Release Unlatch:** since the Latch input contact is still ON, the output turns **ON again.**

### 6.2 補充說明 | Supplementary Note

**中文**
Unlatch 之所以優先,是因為 PLC 依序掃描 Rung,**後面執行的線圈會覆蓋前面的結果**。所以建議把 **Unlatch 的 Rung 放在 Latch 之後**。(此段為補充說明,影片僅提到「Unlatch 有優先」。)

**English**
Unlatch wins because the PLC scans rungs in order and **the coil executed later overrides the earlier result.** It is therefore good practice to place the **Unlatch rung after the Latch rung.** (This note is a supplement; the video only states that Unlatch has priority.)

### 6.3 使用規則 | Rules

| # | 中文 | English |
|---|------|---------|
| 1 | 使用 Latch 時,**一定要搭配 Unlatch**。 | Whenever you use Latch, **always pair it with Unlatch.** |
| 2 | Latch 與 Unlatch 要分成**不同的 Rung**,使用相同位址。 | Put Latch and Unlatch in **separate rungs** with the **same address.** |
| 3 | 必須**先 Latch**,Unlatch 才有效果。 | **Latch first;** Unlatch has no effect otherwise. |
| 4 | 不能在 Latch Rung 中串接常閉停止接點來關閉輸出。 | You cannot turn a latched output off with a series NC stop contact in the latch rung. |

---

## 7. 重點整理 | Summary

**中文**
1. **Latch(OTL)** 在 Rung 為 true 時把輸出設為 ON,Rung 變 false 後輸出**仍保持**。
2. 關閉輸出必須使用 **Unlatch(OTU)**,且位址要與 Latch 相同。
3. 同時成立時,**Unlatch 優先**;Unlatch 輸入消失後,若 Latch 輸入仍在,輸出會再次導通。
4. 傳統做法是**一個 Rung**(並聯自保持+串接停止),Latch/Unlatch 則是**多個 Rung、不同線圈**。
5. 在 Allen-Bradley 中才有獨立的 Latch / Unlatch 線圈指令。
6. 下一節將介紹其他主題。

**English**
1. **Latch (OTL)** sets the output ON when the rung is true, and it **stays ON** after the rung goes false.
2. To turn it off you must use **Unlatch (OTU)** with the same address as the Latch.
3. When both are true, **Unlatch has priority;** once Unlatch is released, if the Latch input is still ON the output turns ON again.
4. The traditional method uses **one rung** (parallel seal-in + series stop), while Latch/Unlatch uses **multiple rungs with separate coils.**
5. Dedicated Latch / Unlatch coil instructions are found on Allen-Bradley PLCs.
6. The next lesson covers another topic.

---

## 附:檔案結構 | Appendix: File Layout

```
PLC_33_Latch_Unlatch.md
image/
├── ab33_01.jpg   # Latch + Unlatch coils (O:0/1)
├── ab33_02.jpg   # Series STOP in the latch rung
└── ab33_03.jpg   # Seal-in vs. Latch coil, both ON
```
