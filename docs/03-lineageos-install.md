# 03 — LineageOS 22.2 + Magisk Root

Prereq: bootloader unlocked (doc 02), on an Android-9-based stock or freshly
wiped state. Everything happens via fastboot + `adb sideload` in Lineage
Recovery — **no TWRP** (unsupported on LOS 21+).

## Step 1 — Boot Lineage Recovery

You can flash recovery to the partition OR boot it temporarily — **temporary is
safer** (a stock boot overwrites the recovery partition):

```bash
# fastboot mode: power off → hold Vol− → plug USB
fastboot boot recovery.img
```

> ⚠️ The trap that bites everyone: `fastboot flash recovery` then letting the
> phone boot to **stock Android** → stock restores its own recovery on first
> boot and your flash is gone. Either `fastboot boot` it, or go
> recovery-dance → recovery *immediately* without a stock boot in between.

## Step 2 — Format data (do NOT skip)

In Lineage Recovery:

**Factory reset → Format data / factory reset → Yes**

> Skipping this is what causes the **"V30+ logo → reboot" bootloop** on first
> LOS start — the data partition still holds stock's encrypted userdata and LOS
> can't mount it. If you hit that loop: get back to recovery (`fastboot boot`
> or the dance) and just format data — the installed ROM is fine.

## Step 3 — Sideload everything

In recovery: **Apply update → Apply from ADB**, then from the PC (in order):

```bash
adb sideload lineage-22.2-*-nightly-joan-signed.zip   # pauses at ~47% — NORMAL, it's installing device-side
# back to Apply from ADB:
adb sideload MindTheGapps-15.0.0-arm64-*.zip          # "signature verification failed" → Yes — expected for addons
# back to Apply from ADB:
adb sideload Magisk-v31.1.zip                         # root; stops ~71% — normal
```

Rules:
- **Gapps must go in before first boot** — flash later = wipe and redo.
- `install completed with status 0` = success each time.
- Reboot **system** only after all three.

## Step 4 — First boot

- First boot takes up to ~15 min through the unlock-warning screen — normal.
- Land on the LOS setup wizard → connect WiFi → add Google account.
- **Re-enable USB debugging now** (Developer options → USB debugging →
  authorize the PC) — everything after this needs `adb`.

## Step 5 — Make recovery permanent

The `fastboot boot` recovery was temporary — the recovery partition still holds
stock, which would break future updates. Once LOS is up:

```bash
adb reboot bootloader
fastboot flash recovery recovery.img
fastboot reboot
```

Now the factory-reset **dance boots Lineage Recovery** (it no longer wipes —
that's just how you get in).

## Step 6 — Finish root

The sideloaded Magisk patched the boot image, but the manager app isn't installed:

```bash
adb install Magisk-v31.1.apk
```

Open the Magisk app once → it finishes setup. Grant shell root when you need it
(Superuser tab → Shell → Allow, or approve the prompt when it pops).

## Verify the end state

```bash
adb shell getprop ro.lineage.version   # 22.2-YYYYMMDD-NIGHTLY-joan
adb shell "ps -A | grep magiskd"       # daemon running
fastboot getvar unlocked               # unlocked: yes
```

## Updating LOS later (important — non-A/B device!)

The V30 is **non-A/B** — every LOS OTA update wipes the Magisk boot patch.

After each update: recovery (dance) → Apply from ADB → `adb sideload Magisk.zip`
→ reboot. ~5 min, no data loss. You don't need to update every nightly —
monthly is fine.

---

Next → [04 — Post-install optimization](04-root-and-optimization.md)
