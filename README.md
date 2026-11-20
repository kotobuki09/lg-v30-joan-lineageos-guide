# LG V30 / V30+ (joan) — Bootloader Unlock, LineageOS 22.2 & Root Guide

A complete, field-tested guide for taking a **stock LG V30/V30+ (`joan`)** to an
unlocked bootloader running **LineageOS 22.2 (Android 15)** with **Magisk root**,
plus a curated post-install optimization layer (system-wide ad-block, LSPosed,
ViPER4Android, Play Integrity fixes).

This documents a *real* executed run on an **LG-H930DS** (V30+ dual SIM) that was
still on stock Pie — including every pitfall hit along the way and how it was
solved. It differs from most online guides in two important ways:

- It covers the **US998 Frankenstein route** for the bootloader unlock when your
  H930 has no early-Oreo KDZ available (all known mirrors are mislabeled — see below).
- It verifies every file with **hashes and KDZ header inspection**, not just filenames.

---

## ⚠️ Read this first

- **Everything gets wiped multiple times.** Back up your data. There is no way
  around this — the unlock itself force-wipes the phone.
- **Remove ALL Google accounts from the phone before starting.** If you don't,
  Factory Reset Protection (FRP) may lock you out after flashing.
- **Permanent bootloader-unlock warning screen** at every boot after unlocking.
  Cosmetic, unremovable.
- **Widevine L1 is lost** on unlock → Netflix/streaming drops to SD or stops working.
- **Risk of bricking is real but low** if you follow the exact order and verify
  every file's checksum/header before flashing. The H930 Pie KDZ in the files
  manifest is your unbrick path — Download Mode + LGUP always restores stock.
- This is for **`joan` only**: LG V30, V30+, V30S — H930 / H930DS / H930G /
  H931 / H932 / VS996 / US998 / US998U / V300K/L/S / l01k.
  Do **not** flash these files on a V35/V40/G7.

## 🔑 The single most important warning in this guide

**Almost every surviving mirror of "H930 early Oreo" KDZ files is mislabeled.**
Files named `H93020a`, `H93020b`, `H93020d` on popular mirrors were verified to
contain *late* firmware (20q/20s/20t/22l — all patched against the unlock
exploit). Flashing one of those will **silently defeat the exploit** and waste
hours.

**Never trust the filename.** Always verify the internal version by reading the
KDZ header at offset 8 before flashing (see [docs/01](docs/01-files-and-preparation.md#verify-a-kdz-before-you-flash-it)).
This is the main reason this guide uses the US998 Frankenstein path.

## 🗺️ The path at a glance

```
Stock Pie (any version)
   │  LGUP PARTITION DL
   ▼
US99810d Nougat  ─── LGUP PARTITION DL ───▶  US99820a Oreo  (exploit firmware)
   │                                                │  fastboot flash unlock new_unlock.bin
   │                                                ▼
   │                                        BOOTLOADER UNLOCKED
   │                                                │  LGUP PARTITION DL
   ▼                                                ▼
Unbrick path (H930 Pie KDZ)  ◀───  H930 Pie restored (required LOS base)
                                                 │  fastboot flash recovery + factory reset
                                                 ▼
                              Lineage Recovery → adb sideload
                              LOS 22.2 + MindTheGapps + Magisk
                                                 ▼
                              Android 15 + root + optimization layer
```

The unlock **survives** KDZ reflashing — once unlocked, it stays unlocked.

**In a hurry / doing this a second time?** → [QUICK-REFERENCE.md](QUICK-REFERENCE.md)
— one-page cheat sheet: buttons, flash order, checksums, key commands, unbrick.

## 📚 Guide documents

| Step | Doc | Time |
|---|---|---|
| 1 | [Files & preparation](docs/01-files-and-preparation.md) — downloads, checksums, drivers, LGUP, phone prep | ~1 h (mostly downloads) |
| 2 | [Bootloader unlock](docs/02-bootloader-unlock.md) — 3× KDZ flash + WTF exploit | ~45 min |
| 3 | [LineageOS + root](docs/03-lineageos-install.md) — recovery, sideload, first boot | ~30 min |
| 4 | [Post-install optimization](docs/04-root-and-optimization.md) — ad-block, LSPosed, ViPER, Play Integrity | ~30 min |
| 5 | [Troubleshooting](docs/05-troubleshooting.md) — every pitfall + fix | as needed |

## ✅ What you end up with

- LineageOS 22.2 (Android 15), official nightly, on a 2017 phone
- Magisk root (systemless), Zygisk + DenyList
- 76k+ domain system-wide ad-block (hosts, no VPN, no battery cost)
- LSPosed (JingMatrix fork — the only Xposed that supports A15)
- ViPER4Android RE audio engine driving the Quad DAC
- PlayIntegrityFix + TrickyStore (banking apps — DEVICE integrity achievable;
  STRONG needs a rotating keybox, explained in doc 04)
- Double-tap status bar = sleep

## 🤝 Credits

- `messi2050` / XDA — original joan unlock research
- The WTF (Weak Two-factor Flash) unlock exploit community
- LineageOS joan maintainers: `lifehackerhansol`, `SGCMarkus`
- JingMatrix (LSPosed fork for A15+), likelikeslike (ViPER4Android RE),
  osm0sis (PlayIntegrityFork), 5ec1cff (TrickyStore), KOWX712 (TrickyAddon),
  Darkeyes (Dark Tricks)

## License

MIT — documentation. All referenced tools/files belong to their authors.
Use at your own risk; no warranty.
