# PLC Training 1 - Introduction to Industrial Automation
# PLC 培训第一课 — 工业自动化简介

**Video / 视频：** [PLC Training 1 - Introduction to Industrial Automation](https://www.youtube.com/watch?v=guQwwyyc5Ss&list=PLI78ZBihrkE3nnGIj2WmHb_GoWjFlfFIu)

**Summary / 摘要：** In this video, we learn the basics and introduction to industrial automation systems like PLC.
本视频介绍工业自动化系统（如 PLC）的基础知识与入门概念。

---

## Transcript / 文字稿

**[20:43:04]**

Hello everyone, in this session we are going to learn about industrial automation. So what is industrial automation? Let's split the word into "industrial" and "automation," and talk about automation first.
大家好，本节课我们要学习工业自动化。什么是工业自动化？我们先把这个词拆成"工业"和"自动化"两部分，先来谈谈"自动化"。

The word *automation* means a self-operating machine — you could say it is a mechanism that operates by itself. It is derived from the Greek words *auto*, meaning "self," and *matos*, meaning "moving." Combined, we get "automation." So any process that is handled automatically, with a minimal amount of human intervention, is called automation. This doesn't mean human effort is not present at all in automation — it will still be there, but in a very small amount.
"自动化"（automation）指的是一种能够自我运作的机制。这个词来源于希腊语，*auto* 意为"自身"，*matos* 意为"运动"，两者结合就形成了"automation"。因此，任何以极少人工干预方式自动完成的流程都可以称为自动化。这并不意味着自动化中完全没有人的参与，人的作用依然存在，只是比重非常小。

### Types of Automation / 自动化的类型

We can see automation even in our own homes — take the example of a washing machine, microwave oven, or security alarm. There is so much automation around us already.
即使在家中我们也能看到自动化的例子，比如洗衣机、微波炉、安全报警器等，我们身边已经存在大量的自动化设备。

Automation has a general classification, including:
自动化大致可以分为以下几类：

- Scientific automation / 科学自动化
- Home automation / 家庭自动化
- Public transport automation / 公共交通自动化
- Laboratory automation / 实验室自动化
- Robotic automation / 机器人自动化

Industrial automation is one of these types. Automation introduced in industries is called **industrial automation**. This can apply to various kinds of industries, such as:
工业自动化就是其中一种类型。应用在工业领域中的自动化被称为**工业自动化**，可用于多种行业，例如：

- Manufacturing industry / 制造业
- Automobile industry / 汽车工业
- Assembly industry / 装配行业
- Cement industry / 水泥行业
- Packaging industry / 包装行业

There are various types of industries, and for each of them, we need automation to increase output. So — why are we introducing automation in industry? That's the next question.
不同行业各有差异，但都需要通过自动化来提高产量。那么，为什么要在工业中引入自动化呢？这是我们接下来要讨论的问题。

### Why Automation? / 为什么需要自动化？

Consider the picture: a man handling a hand valve, checking a temperature gauge. His job is to control the hand valve — there's a fuel supply that he's controlling the quantity of inside the plant. Based on the temperature, he adjusts the valve manually.
请看这张图：一名工人正在操作手动阀门，并查看温度计。他的工作是控制手动阀门——工厂内有一股燃料供给，他需要控制其流量。他根据温度手动调节阀门。

Imagine this scenario: he is responsible for this operation. The issues here are:
设想这种情形：这名工人全权负责该操作，存在以下问题：

1. **Human error** — a person cannot be perfectly accurate; precision will be lacking.
   **人为误差** — 人不可能做到完全精确，精度会有所欠缺。
2. **Safety** — a man working near a boiler is not in a safe environment for his health.
   **安全隐患** — 长期在锅炉附近工作对健康不利，并不安全。

These are the kinds of difficulties we face with manual control.
这些都是人工控制所面临的困难。

Now look at the picture on the right: the man has been replaced by a **controller**. The hand valve has become a **control valve**, and the temperature sensor has become a **transmitter**.
再看右边的图：工人被替换成了**控制器**，手动阀门变成了**控制阀**，温度感应部分变成了**变送器（transmitter）**。

According to the temperature of the plant, the transmitter sends a signal to the controller. The controller has an already-configured **set point (SP)**, and the **process variable (PV)** — in this case, temperature — is sent to it as a signal.
变送器根据工厂的温度向控制器发送信号。控制器中已经设定了**设定值（SP，Set Point）**，而**过程变量（PV，Process Variable）**——在这里就是温度——作为信号被传送给控制器。

Based on the set point and the process variable, the controller makes a decision and sends a control output to the control valve. The control valve then automatically opens, closes, or adjusts its position according to the controller's decision.
控制器根据设定值和过程变量做出判断，并向控制阀发出控制输出信号。控制阀会根据控制器的决策自动开启、关闭或调整开度。

By replacing the man with a controller:
用控制器取代人工之后：

- The area is now safe — there is no danger to any person.
  该区域变得安全，不再有人身危险。
- Accuracy and precision are much better compared to manual control.
  相比人工控制，精度和准确性大幅提升。
- This leads to increased productivity.
  从而提高了生产效率。

### Key Benefits of Industrial Automation / 工业自动化的主要优势

- Increase productivity / 提高生产效率
- Improve product quality / 提升产品质量
- Reduce labor / production cost / 降低人力与生产成本
- Improve safety / 提高安全性
- Assist remote monitoring / 便于远程监控

As discussed, in a chemical manufacturing plant, the plant can be very large, occupying a huge area. It would be very difficult to monitor everything manually in the field with so many instruments spread out. This is where **remote monitoring** techniques come in.
正如前面提到的，化工厂的占地面积往往非常大。现场分布着大量仪表设备，仅靠人工很难对所有设备进行监控，这时就需要用到**远程监控**技术。

---

This is the introduction to automation. See you in the next session with another interesting topic. Thank you.
以上就是本节关于自动化的入门介绍，下节课再见，谢谢大家。
