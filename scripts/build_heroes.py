import os

def build_heroes():
    heroes = ['fighter.asm', 'thief.asm', 'blackbelt.asm', 'redmage.asm', 'whitemage.asm', 'blackmage.asm']
    all_bytes = bytearray()
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    heros_dir = os.path.join(base_dir, 'res', 'heros')

    for h in heroes:
        path = os.path.join(heros_dir, h)
        lines = open(path, 'r', encoding='utf-8', errors='ignore').readlines()
        h_bytes = bytearray()
        for l in lines:
            l = l.strip()
            if l.startswith('!byte') or l.startswith('.byte'):
                parts = l.replace('!byte', '').replace('.byte', '').split(',')
                for p in parts:
                    p = p.strip()
                    if p:
                        h_bytes.append(int(p.replace('$', '0x'), 16))
        if len(h_bytes) != 256:
            raise ValueError(f'{h} is {len(h_bytes)} bytes, expected 256')
        all_bytes.extend(h_bytes)

    out_path = os.path.join(heros_dir, 'heroes.bin')
    with open(out_path, 'wb') as f:
        f.write(all_bytes)
    print(f'Wrote {len(all_bytes)} bytes to {out_path}')

if __name__ == '__main__':
    build_heroes()

