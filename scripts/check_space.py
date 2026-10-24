#!/usr/bin/env python3
import os
import re
import sys

MAP_FILE = "ff1.map"

# Segment budgets and friendly descriptions
SEGMENT_SPECS = {
    "BOOT_HI":      {"desc": "Boot Vector / Reset",    "budget": 0x2000},
    "BOOT_LO":      {"desc": "Cartridge Boot Loader",  "budget": 0x2000},
    "BOOT_VECTORS": {"desc": "6502 Hardware Vectors",  "budget": 0x0006},
    "KERNEL":       {"desc": "Fixed Engine (Bank 0F)", "budget": 0x4000},
    "BANK_00":      {"desc": "Game Info & Teleports",  "budget": 0x4000},
    "BANK_01":      {"desc": "Overworld Map Engine",   "budget": 0x4000},
    "BANK_02":      {"desc": "Overworld / Mapman CHR", "budget": 0x4000},
    "BANK_03":      {"desc": "Town / Dungeon CHR",     "budget": 0x4000},
    "BANK_04":      {"desc": "Standard Maps 1",        "budget": 0x4000},
    "BANK_05":      {"desc": "Standard Maps 2",        "budget": 0x4000},
    "BANK_06":      {"desc": "Standard Maps 3",        "budget": 0x4000},
    "BANK_07":      {"desc": "Battle Backdrops/Mon 1", "budget": 0x4000},
    "BANK_08":      {"desc": "Battle Backdrops/Mon 2", "budget": 0x4000},
    "BANK_09":      {"desc": "Menu CHR & Sprites",     "budget": 0x4000},
    "BANK_0A":      {"desc": "Dialogue & Items",       "budget": 0x4000},
    "BANK_0B":      {"desc": "Battle Formations/Data", "budget": 0x4000},
    "BANK_0C":      {"desc": "Equip Stats & Palettes", "budget": 0x4000},
    "BANK_0D":      {"desc": "SID Music & Audio",      "budget": 0x4000},
    "BANK_0E":      {"desc": "Intro / Title / Party",  "budget": 0x4000},
}

def parse_map(file_path):
    if not os.path.exists(file_path):
        print(f"Error: Map file '{file_path}' not found. Did the build run?")
        sys.exit(1)

    segments = {}
    in_segment_list = False

    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        for line in f:
            line_str = line.strip()
            if line_str.startswith("Segment list:"):
                in_segment_list = True
                continue
            if in_segment_list:
                if line_str.startswith("Exports list") or line_str.startswith("Modules list"):
                    break
                # Format: Name Start End Size Align
                # e.g.: KERNEL 001000 001C28 000C29 00001
                match = re.match(r"^([A-Za-z0-9_]+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)\s+([0-9A-Fa-f]+)", line_str)
                if match:
                    name = match.group(1)
                    start = int(match.group(2), 16)
                    end = int(match.group(3), 16)
                    size = int(match.group(4), 16)
                    segments[name] = {"start": start, "end": end, "size": size}

    return segments

def format_bytes(b):
    return f"{b:,} B"

def main():
    segments = parse_map(MAP_FILE)

    print("\n" + "=" * 82)
    print("  FINAL FANTASY 1 (C64) - CARTRIDGE BANK SPACE REPORT")
    print("=" * 82)
    print(f" {'Segment':<14} {'Description':<24} {'Used':>9} {'Budget':>9} {'Free':>9} {'Usage':>7}")
    print("-" * 82)

    total_used = 0
    total_budget = 0

    for seg_name, spec in SEGMENT_SPECS.items():
        budget = spec["budget"]
        desc = spec["desc"]
        seg_data = segments.get(seg_name)

        if seg_data:
            used = seg_data["size"]
        else:
            used = 0

        free = budget - used
        pct = (used / budget) * 100 if budget > 0 else 0

        total_used += used
        total_budget += budget

        # Visual indicator
        flag = " "
        if free < 0:
            flag = "!"
        elif pct >= 90.0:
            flag = "*"

        pct_str = f"{pct:5.1f}%{flag}"
        print(f" {seg_name:<14} {desc:<24} {format_bytes(used):>9} {format_bytes(budget):>9} {format_bytes(free):>9} {pct_str:>7}")

    print("-" * 82)
    total_free = total_budget - total_used
    total_pct = (total_used / total_budget) * 100
    print(f" {'TOTAL':<14} {'All Configured Banks':<24} {format_bytes(total_used):>9} {format_bytes(total_budget):>9} {format_bytes(total_free):>9} {total_pct:5.1f}% ")
    print("=" * 82)
    print(" Legend:  * = >= 90% full    ! = OVER BUDGET\n")

if __name__ == "__main__":
    main()

