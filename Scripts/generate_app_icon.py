#!/usr/bin/env python3
import math
import os
import struct
import zlib
from pathlib import Path


ROOT = Path.cwd()
RESOURCES = ROOT / "Resources"
ICONSET = RESOURCES / "AppIcon.iconset"
PNG = RESOURCES / "AppIcon.png"
ICNS = RESOURCES / "AppIcon.icns"


def clamp(value, low=0.0, high=1.0):
    return max(low, min(high, value))


def mix(a, b, t):
    return a + (b - a) * t


def blend(dst, src):
    sr, sg, sb, sa = src
    dr, dg, db, da = dst
    out_a = sa + da * (1 - sa)
    if out_a <= 0:
        return 0, 0, 0, 0
    return (
        (sr * sa + dr * da * (1 - sa)) / out_a,
        (sg * sa + dg * da * (1 - sa)) / out_a,
        (sb * sa + db * da * (1 - sa)) / out_a,
        out_a,
    )


def rounded_rect_alpha(x, y, size, radius):
    px = abs(x - size / 2) - (size / 2 - radius)
    py = abs(y - size / 2) - (size / 2 - radius)
    ox = max(px, 0)
    oy = max(py, 0)
    outside = math.hypot(ox, oy) + min(max(px, py), 0) - radius
    return clamp(0.5 - outside)


def point_segment_distance(px, py, ax, ay, bx, by):
    vx = bx - ax
    vy = by - ay
    wx = px - ax
    wy = py - ay
    length_sq = vx * vx + vy * vy
    if length_sq == 0:
        return math.hypot(px - ax, py - ay)
    t = clamp((wx * vx + wy * vy) / length_sq)
    cx = ax + vx * t
    cy = ay + vy * t
    return math.hypot(px - cx, py - cy)


def line_alpha(px, py, ax, ay, bx, by, width):
    distance = point_segment_distance(px, py, ax, ay, bx, by)
    return clamp((width / 2 + 0.75 - distance) / 1.5)


def hill_top(x, size):
    t = clamp((x - size * 0.18) / (size * 0.64))
    start = size * 0.25
    end = size * 0.25
    control_1 = size * 0.36
    control_2 = size * 0.16
    return (
        (1 - t) ** 3 * start
        + 3 * (1 - t) ** 2 * t * control_1
        + 3 * (1 - t) * t**2 * control_2
        + t**3 * end
    )


def render(size):
    pixels = []
    center = size * 0.5, size * 0.58
    long_arm = size * 0.22
    short_arm = size * 0.055
    main_width = max(3, size * 0.018)
    branch_width = max(2, size * 0.012)

    for y in range(size):
        row = []
        fy = size - y - 0.5
        for x in range(size):
            fx = x + 0.5
            top = (0.12, 0.24, 0.34, 1.0)
            bottom = (0.06, 0.12, 0.20, 1.0)
            t = fy / size
            color = (
                mix(bottom[0], top[0], t),
                mix(bottom[1], top[1], t),
                mix(bottom[2], top[2], t),
                1.0,
            )

            if size * 0.18 <= fx <= size * 0.82 and size * 0.19 <= fy <= hill_top(fx, size):
                color = blend(color, (0.82, 0.91, 0.96, 1.0))

            snow_alpha = 0.0
            cx, cy = center
            for index in range(6):
                angle = index * math.pi / 3
                dx = math.cos(angle) * long_arm
                dy = math.sin(angle) * long_arm
                snow_alpha = max(snow_alpha, line_alpha(fx, fy, cx - dx, cy - dy, cx + dx, cy + dy, main_width))

                bx = cx + dx * 0.58
                by = cy + dy * 0.58
                for branch_angle in (angle + math.pi * 0.75, angle - math.pi * 0.75):
                    ex = bx + math.cos(branch_angle) * short_arm
                    ey = by + math.sin(branch_angle) * short_arm
                    snow_alpha = max(snow_alpha, line_alpha(fx, fy, bx, by, ex, ey, branch_width))

            core = math.hypot(fx - center[0], fy - center[1])
            snow_alpha = max(snow_alpha, clamp((size * 0.035 - core + 0.75) / 1.5))
            if snow_alpha > 0:
                color = blend(color, (0.88, 0.97, 1.0, snow_alpha))

            row.append(tuple(round(clamp(channel) * 255) for channel in color))
        pixels.append(row)
    return pixels


def write_png(path, pixels):
    height = len(pixels)
    width = len(pixels[0])
    raw = bytearray()
    for row in pixels:
        raw.append(0)
        for r, g, b, _ in row:
            raw.extend((r, g, b))

    def chunk(kind, data):
        return (
            struct.pack(">I", len(data))
            + kind
            + data
            + struct.pack(">I", zlib.crc32(kind + data) & 0xFFFFFFFF)
        )

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", width, height, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(bytes(raw), 9))
    png += chunk(b"IEND", b"")
    path.write_bytes(png)


def write_icns(path, iconset):
    chunks = [
        ("icp4", "icon_16x16.png"),
        ("icp5", "icon_32x32.png"),
        ("icp6", "icon_32x32@2x.png"),
        ("ic07", "icon_128x128.png"),
        ("ic08", "icon_256x256.png"),
        ("ic09", "icon_512x512.png"),
        ("ic10", "icon_512x512@2x.png"),
    ]
    body = bytearray()
    for code, filename in chunks:
        data = (iconset / filename).read_bytes()
        body.extend(code.encode("ascii"))
        body.extend(struct.pack(">I", len(data) + 8))
        body.extend(data)
    path.write_bytes(b"icns" + struct.pack(">I", len(body) + 8) + bytes(body))


def main():
    RESOURCES.mkdir(exist_ok=True)
    if ICONSET.exists():
        for child in ICONSET.iterdir():
            child.unlink()
    else:
        ICONSET.mkdir()

    write_png(PNG, render(1024))
    sizes = [
        ("icon_16x16.png", 16),
        ("icon_16x16@2x.png", 32),
        ("icon_32x32.png", 32),
        ("icon_32x32@2x.png", 64),
        ("icon_128x128.png", 128),
        ("icon_128x128@2x.png", 256),
        ("icon_256x256.png", 256),
        ("icon_256x256@2x.png", 512),
        ("icon_512x512.png", 512),
        ("icon_512x512@2x.png", 1024),
    ]
    for filename, size in sizes:
        write_png(ICONSET / filename, render(size))

    write_icns(ICNS, ICONSET)
    print(f"Wrote {PNG}")
    print(f"Wrote {ICNS}")


if __name__ == "__main__":
    os.chdir(ROOT)
    main()
