# PLC Training 53 — ON/OFF Motor and Lamp Ladder Logic (Allen-Bradley)

## 1. Problem Statement

Design ladder logic for a simple ON/OFF control of a **Conveyor Motor** and **two Lamps**, using six input switches.

| # | Condition | Action |
|---|-----------|--------|
| 1 | Switch 1 ON | Conveyor Motor ON |
| 2 | Switch 2 ON **and** Switch 3 ON | Lamp 1 ON & Lamp 2 ON |
| 3 | Switch 4 **or** Switch 5 ON | Conveyor Motor OFF |
| 4 | Switch 6 ON | Lamp 1 OFF & Lamp 2 OFF |

**Key behavior:** All switches are treated as *momentary* pushbuttons. Once the Motor (or Lamps) is turned ON, it must **stay ON** even after the triggering switch is released, until the corresponding OFF condition occurs. This requires **latching logic** (Set/Reset or Seal-in).

---

## 2. I/O Addressing (Allen-Bradley / Studio 5000 style)

| Tag Name | Description | Type | Address (example, Micro800/CompactLogix) |
|----------|-------------|------|--------------------------------------------|
| `Switch_1` | Motor Start pushbutton | BOOL Input | Local:1:I.Data.0 |
| `Switch_2` | Lamp Start condition A | BOOL Input | Local:1:I.Data.1 |
| `Switch_3` | Lamp Start condition B | BOOL Input | Local:1:I.Data.2 |
| `Switch_4` | Motor Stop pushbutton A | BOOL Input | Local:1:I.Data.3 |
| `Switch_5` | Motor Stop pushbutton B | BOOL Input | Local:1:I.Data.4 |
| `Switch_6` | Lamp Stop pushbutton | BOOL Input | Local:1:I.Data.5 |
| `Conveyor_Motor` | Conveyor Motor output | BOOL Output | Local:2:O.Data.0 |
| `Lamp_1` | Lamp 1 output | BOOL Output | Local:2:O.Data.1 |
| `Lamp_2` | Lamp 2 output | BOOL Output | Local:2:O.Data.2 |

> In RSLogix5000/Studio 5000, you can use **OTL (Output Latch)** and **OTU (Output Unlatch)** instructions instead of a seal-in contact, which is the cleanest way to implement this requirement.

---

## 3. Ladder Diagram (LD)

```
Rung 0: Motor ON (Latch)
 |  Switch_1                                  Conveyor_Motor  |
 |  ─┤ ├─────────────────────────────────────────( L )──────  |

Rung 1: Motor OFF (Unlatch) — Switch 4 OR Switch 5
 |  Switch_4                                  Conveyor_Motor  |
 |  ─┤ ├───┬─────────────────────────────────────( U )──────  |
 |          │                                                 |
 |  Switch_5│                                                 |
 |  ─┤ ├───┘                                                  |

Rung 2: Lamps ON (Latch) — Switch 2 AND Switch 3
 |  Switch_2      Switch_3                    Lamp_1          |
 |  ─┤ ├──────────┤ ├────────────────────────────( L )──────  |
 |                                              Lamp_2          |
 |                                              ───( L )──────  |

Rung 3: Lamps OFF (Unlatch) — Switch 6
 |  Switch_6                                   Lamp_1          |
 |  ─┤ ├─────────────────────────────────────────( U )──────  |
 |                                              Lamp_2          |
 |                                              ───( U )──────  |
```

### Explanation of each rung
- **Rung 0:** A single momentary press of `Switch_1` latches `Conveyor_Motor` ON. It stays ON even after the switch is released (memory retained by the `OTL` instruction).
- **Rung 1:** `Switch_4` **OR** `Switch_5` (either one, in parallel branches) unlatches (`OTU`) the `Conveyor_Motor`, turning it OFF.
- **Rung 2:** `Switch_2` **AND** `Switch_3` (in series) must both be ON at the same time to latch `Lamp_1` and `Lamp_2` ON.
- **Rung 3:** `Switch_6` unlatches both `Lamp_1` and `Lamp_2`, turning them OFF.

> **Note on OTL/OTU behavior:** Latch/Unlatch bits are retentive — they remain in their last state even through a PLC power cycle (unless the memory is non-retentive by configuration). If a *non-latching* behavior is preferred (reset on power-down), the same result can be achieved with a **Seal-in circuit** using normal `OTE` (Output Energize) coils instead — shown as an alternative below.

---

## 4. Alternative: Seal-in Circuit (using OTE instead of OTL/OTU)

```
Rung 0: Conveyor Motor Seal-in
 |  Switch_1     Switch_4     Switch_5         Conveyor_Motor |
 |  ─┤ ├──┬──────┤/├──────────┤/├─────────────────( )───────  |
 |         │                                                   |
 |  Conveyor_Motor                                              |
 |  ─┤ ├──┘                                                     |

Rung 1: Lamps Seal-in
 |  Switch_2   Switch_3     Switch_6            Lamp_1          |
 |  ─┤ ├───────┤ ├──────────┤/├────────────────────( )───────  |
 |     │                                            Lamp_2       |
 |  Lamp_1                                          ────( )───  |
 |  ─┤ ├──────────┘  (seal-in parallel with Switch_2 & Switch_3)|
```

Here `Switch_4`/`Switch_5`/`Switch_6` are wired as **normally-closed (NC) contacts** in the rung (shown as `┤/├`) so that when pressed, they break the circuit and drop out the seal-in coil.

---

## 5. Structured Text (ST) Equivalent Code

Allen-Bradley Studio 5000 / CompactLogix / Micro800 also supports Structured Text. Below is the ST version using the **latch/unlatch (Set/Reset) method**, which directly mirrors the LD logic in Section 3.

```pascal
// ==========================================================
// PLC Training 53 - Motor & Lamp ON/OFF - Structured Text
// ==========================================================

// Rung 0: Motor ON (Latch)
IF Switch_1 THEN
    Conveyor_Motor := TRUE;
END_IF;

// Rung 1: Motor OFF (Unlatch) - Switch 4 OR Switch 5
IF Switch_4 OR Switch_5 THEN
    Conveyor_Motor := FALSE;
END_IF;

// Rung 2: Lamps ON (Latch) - Switch 2 AND Switch 3
IF Switch_2 AND Switch_3 THEN
    Lamp_1 := TRUE;
    Lamp_2 := TRUE;
END_IF;

// Rung 3: Lamps OFF (Unlatch) - Switch 6
IF Switch_6 THEN
    Lamp_1 := FALSE;
    Lamp_2 := FALSE;
END_IF;
```

### Important scan-order note
In ST (and in ladder), **rung/statement order matters** when two conditions could be true in the same scan. As written above, the **OFF conditions are evaluated after the ON conditions**, so if `Switch_1` and `Switch_4` happen to be true in the same scan, the Motor will end up OFF (OFF has priority). If you want ON to have priority instead, simply reverse the order of the IF blocks (put the ON logic after the OFF logic).

---

## 6. Timing Diagram (Conceptual)

```
Switch_1   __|‾|______________________________________
Switch_4   ________________________|‾|________________
Conveyor   ____|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|________________  (Motor stays ON until Sw4/Sw5)

Switch_2   __|‾‾‾‾‾|__________________________________
Switch_3   __|‾‾‾‾‾|__________________________________
Switch_6   ________________________|‾|________________
Lamp_1/2   __|‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾|________________  (Lamps stay ON until Sw6)
```

---

## 7. Summary

| Logic Block | Ladder Instruction | ST Equivalent |
|-------------|--------------------|----------------|
| Motor ON | `Switch_1` → `OTL Conveyor_Motor` | `IF Switch_1 THEN Conveyor_Motor := TRUE;` |
| Motor OFF | `Switch_4 OR Switch_5` → `OTU Conveyor_Motor` | `IF Switch_4 OR Switch_5 THEN Conveyor_Motor := FALSE;` |
| Lamps ON | `Switch_2 AND Switch_3` → `OTL Lamp_1, Lamp_2` | `IF Switch_2 AND Switch_3 THEN Lamp_1:=TRUE; Lamp_2:=TRUE;` |
| Lamps OFF | `Switch_6` → `OTU Lamp_1, Lamp_2` | `IF Switch_6 THEN Lamp_1:=FALSE; Lamp_2:=FALSE;` |

This design satisfies all four requirements from the assignment, using standard Allen-Bradley latch/unlatch instructions (or an equivalent seal-in circuit), plus a matching Structured Text program for platforms/preferences that use ST instead of LD.
