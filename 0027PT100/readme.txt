https://github.com/cephaswang/PLCStudy/tree/main/0027PT100

https://www.youtube.com/watch?v=QcMftg8IStQ&list=PLuSPGhP07aFudeih2OP-DMY82AP_2fi3X
Analog Input on Mitsubishi PLC Q Series | PLC | HMI | Mitsubishi PLC

I will be sharing knowledge about Industrial Automation as PLC SCADA HMI VFD and other knowledge on this Channel, so, please subscribe to my channel to get the next video. Thank you!

TIA Portal, SCADA, VFD, PLC Program, Automation, Industrial Automation, Siemens, HMI Design, PLC program, Motor Control


Step7 V5.7.7z (2.7G) 

https://drive.usercontent.google.com/download?id=1VBpI9DZ4vNxLQBR_3fKgZThAq1k8-zQC&export=download&authuser=0


https://blog.csdn.net/weixin_67913271/article/details/135185265
【附三菱MX OPC Server 6.04的安装包】

https://pan.baidu.com/s/1JcLNqko5lk10E8ZNWjAt_A?pwd=jiuh#list/path=%2F


Download MX OPC Server 6.10 Mitsubishi Software.RAR
https://drive.google.com/file/d/1SvA2Bj5xOxP0a5AycRQ6EWx5q_TX8Dv5/view
Password Extract Software: plc4me.com


功能說明

這支 ST 程式對應原梯形圖邏輯（INT2FLT → E/ → E*），功能是把 Q64AD 類比輸入模組讀到的原始數位值，換算成有意義的工程單位實際值：

D0 → D20（整數轉浮點）：Q64AD 透過 Auto_Refresh 自動把數位輸出值寫進 D0，程式先用 INT_TO_REAL 轉成浮點數 D20，方便後續浮點運算。
D22 = E100 / E4000（計算換算係數）：E100、E4000 是兩個浮點常數，分別代表「感測器滿量程」與「該解析度模式下的最大數位值（一般解析度模式為 0~4000）」。兩者相除得到一個固定的比例係數（例如 100/4000 = 0.025），只要硬體規格不變，這個係數在程式執行期間就不會改變。
D24 = D20 × D22（換算成實際值）：把原始浮點值乘上係數，就把 0~4000 的數位範圍線性映射成 0~100（或你設定的其他滿量程）的實際物理量，例如壓力、液位百分比等。

實務上使用時，只要依現場感測器規格修改 E100（滿量程）與 E4000（對應解析度模式的最大數位值，如高解析度模式改為 16000）這兩個常數即可套用到不同的類比輸入場景，不需更動運算邏輯本身。
