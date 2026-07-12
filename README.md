# Voron StealthChanger Mods

Hardware mods and firmware config for a **Voron 2.4 with a 6-tool
StealthChanger**.

## What's here

| Folder | |
|---|---|
| **[RepRap-RRF-Stuff](RepRap-RRF-Stuff/)** | **RepRapFirmware config for a multi-tool StealthChanger** — tool-change macros, priming, tool detection. Not Klipper. See below. |
| [Anthead Fan Cowl Mods - Magneat-O](Anthead%20Fan%20Cowl%20Mods%20-%20Magneat-O/) | Magnetic fan cowl mods for the Anthead |
| [Anthead-Stealthchanger-Spacers](Anthead-Stealthchanger-Spacers/) | Spacers for mounting Anthead on StealthChanger |
| [FLY-SHT36 Stuff](FLY-SHT36%20Stuff/) | FLY SHT36 toolboard bits |
| [Modular Docks-Mag-A-Palooza](Modular%20Docks-Mag-A-Palooza/) | Modular magnetic dock design |

## The RRF angle

Essentially every multi-tool StealthChanger build out there runs **Klipper**.
This one runs **RepRapFirmware**, and there are only a handful of us doing it —
which means there was no prior art to copy. The configs in
[RepRap-RRF-Stuff](RepRap-RRF-Stuff/) were ported by hand from Klipper concepts
or derived from RRF first principles.

If you're trying to do a StealthChanger in RRF, that folder is the thing you
couldn't find anywhere else. It documents the reasoning, not just the files —
how to detect which tools a job uses, how to keep docked tools from drooling,
and how to verify a tool actually attached instead of air-printing.

It's honest about what isn't done, too: 3 of 6 tools are built, and there's no
hard motion interlock yet. Issues and PRs welcome, especially on that last one.
