# Voron 2.4 + StealthChanger on RepRapFirmware

A working multi-tool StealthChanger setup running **RepRapFirmware**, not Klipper.

Nearly every StealthChanger build out there is Klipper. There are only a handful
of us doing it in RRF, and the documentation for that path is essentially
nonexistent — everything here was ported by hand from Klipper concepts or
derived from RRF first principles. This repo exists so the next person doesn't
have to start from zero.

**Status: working, but incomplete.** Read the [Caveats](#caveats) before you
copy anything.

---

## The machine

| | |
|---|---|
| **Board** | Duet 3 Mini 5+, RRF 3.6.3 (SBC mode, Raspberry Pi 4B) |
| **Kinematics** | CoreXY, 4 independent Z (quad gantry leveling) |
| **Build volume** | X 0–300, Y 0–310, Z 0–295 |
| **Toolchanger** | StealthChanger, 6 docks — **3 tools currently built** |
| **Extruders** | Toolboard-mounted (CAN), one per tool |
| **Hotends** | Mixed — Dragon HF, TZ V6, Revolcano (REVO Volcano). Most fitted with **Rapido 2 heater cartridges**. |
| **Slicer** | OrcaSlicer |

The hotends are deliberately not all the same — different tools suit different
jobs. What they mostly share is the **Rapido 2 heater cartridge**, which is very
fast (0→240 °C in seconds). That speed is what makes the standby strategy below
practical.

The docks hang **overhead**, above the print area. The toolhead prints
*underneath* the dock canopy. This is standard StealthChanger geometry and it
drives almost every design decision below.

---

## The three things that were hardest to work out

If you read nothing else, read this section. These are the parts that cost real
time to figure out and that no existing doc explains.

### 1. Telling RRF which tools a print job actually uses

You don't want to heat six hotends for a two-color print. But `print_start.g`
has no idea which tools the job needs.

**The trick:** OrcaSlicer emits a `G10` for every tool used in the job, *before*
it calls your start macro:

```gcode
M190 S55                 ; bed
G10 S220 P0              ; set T0 active temp
G10 S220 P1              ; set T1 active temp
G10 S220 P2              ; set T2 active temp
M98 P"0:/macros/print_start.g" T2 B55 H220
```

So by the time your macro runs, the Object Model already knows: any tool with
`tools[N].active[0] > 0` is in this job. Unused tools are still at 0.

That gives you a clean audit loop — see [`macros/prime_lines.g`](macros/prime_lines.g):

```gcode
while var.i < #tools
    if tools[var.i].active[0] > 0
        ; this tool is used in the job
```

No slicer-side hacks, no passing tool lists as parameters. The temperatures
*are* the manifest.

### 2. Idle tools drooling in their docks

Tools waiting in the dock must be hot enough to be usable quickly, but **below
the temperature at which filament oozes**, or they'll drool onto the dock and
you'll drag a blob onto your first layer when you pick them up.

The pattern:

- Set used tools to **standby** at `active − 45 °C` (`M568 P{n} R{...} A1`).
  For PLA at 220 that's 175 °C — comfortably below where PLA starts to run.
- `T{n}` **automatically promotes a tool to active** when you select it. You
  don't do this yourself; it's built into RRF's tool-change machinery.
- `M116 P{n}` then waits for it to reach print temp.

With a fast heater (a Rapido 2 goes 0→240 °C in seconds) that final climb costs
you almost nothing, so there is no reason to idle tools hot. **Don't optimize
away the standby step.**

If you're running slower heaters the trade-off shifts — you may want a smaller
standby offset — but keep standby **below the ooze point of your filament**,
whatever that is for the material you run. That constraint is the one that
matters; the 45 °C figure is just what it works out to for PLA at 220.

### 3. Verifying the tool actually picked up

A dock that fails to hand off its tool is a silent, expensive failure — the
machine happily carries on printing with nothing attached.

Each toolhead has its own probe on its own CAN toolboard. After pickup,
[`sys/tpost0.g`](sys/tpost0.g) remaps the probe to that tool's board and then
**checks the sensor is actually there**:

```gcode
M558 K0 P8 C"^20.io1.in" H5:4 F400:200 A5 S0.01 T24800
G31 K0 P5 Z-1.635 X0 Y0
G4 P240                   ; let the CAN board register

if !exists(sensors.probes[0]) || sensors.probes[0].value[0] == 1000
    abort "ERROR: Tool 0 Pickup Failed! No Probe Found"
```

A reading of `1000` means "nothing there." If the tool didn't come off the dock,
the print aborts instead of air-printing. This is cheap insurance and I'd call
it mandatory.

Note the CAN address changes per tool: `^20.io1.in`, `^21.io1.in`, `^22.io2.in`
— **and T2 is on `io2`, not `io1`.** Check your own wiring; don't assume.

---

## Motion safety: why the moves look weird

You will notice that **no move is diagonal**. Everything is written as separate
axis moves in a deliberate order:

```gcode
G53 G1 Y{global.dock_safe_y_loaded} F{global.speed_xy_fast}   ; Y first
G53 G1 X{global.dock_x_0}            F{global.speed_xy_fast}   ; then X
G53 G1 Z{global.dock_z_high}         F{global.speed_z_fast}    ; then Z
```

This is not stylistic. The docks are an overhead bank at the back of the
machine. A diagonal move from a print position to a dock **cuts the corner
straight through the canopy** and destroys a toolhead. Sequencing the axes walks
the carriage around the obstruction instead of through it.

Two supporting conventions:

- **`G53` on every safety move** — machine coordinates, so a workspace offset
  can never shift a dock approach.
- **Two safe-Y corridors, not one.** An empty carriage can come closer to the
  docks (`dock_safe_y_empty`) than one carrying a toolhead
  (`dock_safe_y_loaded`), which needs clearance for the tool hanging off it.

Speeds are also split by *risk*, not by axis — see `041_define-global-vars.g`.
Open-air travel is fast (350 mm/s). Sliding into a dock is slow (50 mm/s).
Dropping onto the dock pins is very slow (15 mm/s). Don't collapse these into
one feedrate.

---

## Files

| File | What it does |
|---|---|
| [`macros/041_define-global-vars.g`](macros/041_define-global-vars.g) | **Start here.** Dock coordinates, safe-Y corridors, all speeds. Everything else reads from this. |
| [`macros/print_start.g`](macros/print_start.g) | Slicer entry point. Validates params, checks homing + tool attached, loads mesh, primes, heats. |
| [`macros/prime_lines.g`](macros/prime_lines.g) | Audits which tools the job uses, then purges each one in its own lane. The tool-detection logic lives here. |
| [`macros/05_discover_tool.g`](macros/05_discover_tool.g) | Works out which tool (if any) is currently on the carriage. |
| [`sys/tfree0.g`](sys/tfree0.g) | Put tool away. Lift → safe Y → dock X → up into canopy → slide in → drop on pins → retreat. |
| [`sys/tpre0.g`](sys/tpre0.g) | Pre-pickup positioning. |
| [`sys/tpost0.g`](sys/tpost0.g) | Pick up + **verify the tool actually attached** + restore position. |

**Only T0's tool-change files are here.** T1 and T2 are byte-identical except
for two things: `global.dock_x_0` → `dock_x_1`/`dock_x_2`, and the probe's CAN
address in `tpost`. Replicate accordingly.

---

## Caveats

**Read these before copying anything.**

- **The coordinates in `041_define-global-vars.g` are for *my* machine.** Dock
  X positions, dock Z heights, safe-Y corridors — all of it. Copying these
  blindly will drive your toolhead into your docks. Derive your own by jogging
  the machine and reading the DRO.

- **Only 3 of 6 tools are built.** The macros are written to scale to 6 and the
  audit loop iterates `#tools`, but the 6-tool case is **not yet validated** —
  in particular the purge-lane geometry (6 lanes × 35 mm from X10 runs to X215)
  has not been run for real.

- **There is no hard motion interlock.** Safety currently lives in the
  *convention* of writing non-diagonal moves in the right order. Nothing stops a
  badly-written macro from commanding a diagonal straight through the canopy.
  You'll see commented-out `M208 Z260 S0` lines in `tfree`/`tpost` — an
  abandoned attempt at a Z ceiling. It doesn't work because the forbidden zone
  is *conditional* (you can print under the canopy, just not tall), and `M208`
  axis limits are unconditional. **A real guard for this is unsolved and is the
  top open item.** If you have a good answer, please open an issue.

- **OrcaSlicer's RRF output is a fight.** Orca is excellent for multi-tool but
  is Klipper/Marlin-centric. Expect syntax friction.

---

## Contributing

If you're another RRF StealthChanger builder: issues and PRs very welcome,
especially on the motion-interlock problem. There are few enough of us that
comparing notes is worth a lot.
