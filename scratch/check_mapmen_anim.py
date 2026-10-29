with open("res/maps/mapmen/mapmen.spr", "rb") as f:
    data = f.read()

print(f"Total size: {len(data)} bytes ({len(data)//64} sprites)")

# Let's inspect Fighter sprites (Class 0: Sprites 0..15)
# In mapmen.md:
# Pose 0: South Frame 0 -> Sprite 0 (outline), Sprite 1 (base)
# Pose 1: South Frame 1 -> Sprite 2 (outline), Sprite 3 (base)
# Pose 2: North Frame 0 -> Sprite 4, 5
# Pose 3: North Frame 1 -> Sprite 6, 7
# Pose 4: West Frame 0  -> Sprite 8, 9
# Pose 5: West Frame 1  -> Sprite 10, 11
# Pose 6: East Frame 0  -> Sprite 12, 13
# Pose 7: East Frame 1  -> Sprite 14, 15

for pose in range(8):
    spr_out = data[pose*2 * 64 : (pose*2+1) * 64]
    spr_base = data[(pose*2+1) * 64 : (pose*2+2) * 64]
    non_zero_out = sum(1 for b in spr_out if b != 0)
    non_zero_base = sum(1 for b in spr_base if b != 0)
    print(f"Pose {pose}: Outline non-zero bytes={non_zero_out}, Base non-zero bytes={non_zero_base}")
    # Compare with other poses:
    if pose % 2 == 1:
        prev_out = data[(pose-1)*2 * 64 : ((pose-1)*2+1) * 64]
        prev_base = data[((pose-1)*2+1) * 64 : ((pose-1)*2+2) * 64]
        diff_out = sum(1 for a, b in zip(spr_out, prev_out) if a != b)
        diff_base = sum(1 for a, b in zip(spr_base, prev_base) if a != b)
        print(f"  Frame 1 vs Frame 0 diff: Outline diff={diff_out}, Base diff={diff_base}")

