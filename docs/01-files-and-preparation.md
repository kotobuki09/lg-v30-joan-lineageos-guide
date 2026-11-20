# 01 — Files & Preparation

Everything you need *before* touching the phone. Do not skip the verification
steps — the #1 cause of failure on this device is bad/mislabeled firmware files.

## Required downloads

| # | File | Size | SHA/MD5 | Purpose |
|---|------|------|---------|---------|
| 1 | `US99810d_01_0411.kdz` | ~2.9 GB | verify header = `US99810d_01` | Frankenstein step 1 (Nougat) |
| 2 | `US99820a_04_0330.kdz` | ~2.9 GB | **MD5 `5654dd3238db691c1e6e633fe16092c4`** | Exploit firmware — the canonical WTF file |
| 3 | `H93031a_00_OPEN_EU_OP_1105.kdz` | ~3.3 GB | **MD5 `ddd83ac54746e75210fed671a44e1285`** | Return to H930 Pie + unbrick image |
| 4 | `new_unlock.bin` | 1,024 bytes | exact size = 1024 | The exploit key |
| 5 | `LGUP_DualMode.zip` | ~15 MB | MD5 `0265e2d5dd98f59bcfa02e192e8be288` | Patched LGUP (enables PARTITION DL + dev DLL) |
| 6 | `LGMobileDriver_WHQL_Ver_4.4.2.exe` | ~15 MB | MD5 `3cf43fac010f5a44b80d9115422f3fd4` | LG Download Mode driver |
| 7 | platform-tools (adb/fastboot) | ~15 MB | — | Official Google: developer.android.com/tools/releases/platform-tools |
| 8 | Lineage `recovery.img` | ~34 MB | verify vs download.lineageos.org API | Lineage Recovery |
| 9 | `lineage-22.2-YYYYMMDD-nightly-joan-signed.zip` | ~1 GB | verify SHA256 vs LOS API | The ROM |
| 10 | `MindTheGapps-15.0.0-arm64-*.zip` | ~500 MB | — | Google apps (optional but recommended) |
| 11 | `Magisk-v*.apk` + renamed `.zip` copy | ~11 MB | — | Root (sideload the .zip, install the .apk after) |

### Where to get them (as of Nov 2026 — mirrors rot constantly)

- **KDZ files**: AndroidFileHost is effectively dead (API returns zero mirrors).
  Working sources found:
  - **vnrom.net / addROM** — maintain a per-model table of Google-Drive +
    OneDrive mirrors for H930/US998 KDZs. This is where all three KDZs in the
    manifest came from.
  - **Verified-good US99820a mirror** (header-checked, matched the canonical
    MD5): Google Drive id `1D5uEPOVbxp15LVZVeMcCay4hinzeEiuu` →
    `https://drive.google.com/uc?id=1D5uEPOVbxp15LVZVeMcCay4hinzeEiuu&export=download&confirm=t`
  - **archive.org "AFHArchive" collection** — preserved AFH uploads:
    LGUP_DualMode and drivers live there with direct download.
- **Google Drive direct download pattern** (no page scraping needed):
  `https://drive.google.com/uc?id=FILE_ID&export=download&confirm=t`
- **LGUP backup mirror** (Hovatek's patched Dev build — arguably better than
  DualMode): `https://mega.nz/file/kpYjgSrC#fhAVz5QpEMPU-s-JV9ZjEcjAhaOSQS8Za4WQqATLla0`
  (Store version: `https://mega.nz/file/st5xESKS#T5wE5-5OuDcfGLtaWJ1kXzMlawDGPcZvsV5I10KsJA`)
- **LG driver**: official LG CDN is dead — MediaFire mirrors of
  `LGMobileDriver_WHQL_Ver_4.4.2.exe` exist (e.g. via thecustomdroid.com);
  verify the MD5 above.
- **LOS + recovery**: `download.lineageos.org/devices/joan/builds` — always
  verify SHA256 against the LOS API: `download.lineageos.org/api/v2/devices/joan/builds`
- **MindTheGapps**: `github.com/MindTheGapps/15.0.0-arm64/releases`
- **Magisk**: `github.com/topjohnwu/Magisk/releases` (v31.1 verified here)
- **`new_unlock.bin`**: XDA WTF-unlock thread — file must be exactly **1024 bytes**.

> 🚫 **NEVER flash an H932 (T-Mobile) KDZ** — different carrier customization,
> known to cause radio/brick issues on open-market joan. Stick to OPEN_EU/OPEN_IL
> H930 or US998 files.

## Verify a KDZ *before* you flash it

Filenames lie. The internal version string is stored in the KDZ header at
**offset 8** (length-prefixed ASCII). Check it two ways:

**HTTP range request** (before downloading 3 GB):
```bash
curl -s -r 8-200 -L "URL" --max-time 30 | strings | grep -oE '[A-Z0-9]{4,}[0-9]{2}[a-z]_[0-9]{2}'
# expect e.g. US99820a_04
```

**On a downloaded file** (Git Bash / WSL):
```bash
head -c 256 file.kdz | strings | head -5   # or dd + xxd
```

❗ **Known-bad mirror pattern**: files named `H93020a_00`, `H93020b_00`,
`H93020d_00` (any region: OPEN_EU / OPEN_IL / OPEN_IN / TIM_IT) on vnrom and
similar mirrors were checked and all contained **20q / 20s / 20t / 22l** — too
new, patched against the exploit. If your H930 early-Oreo KDZ shows anything
other than `20a`–`20d`, do **not** flash it.

> **Why US998 then?** Because no correctly-labeled H930 early-Oreo KDZ survives
> online. `US99820a_04` (March 2018) is the exact firmware the WTF exploit was
> developed on, MD5-documented, and the joan hardware is identical — the
> Frankenstein crossflash is a documented, proven route.

## PC setup (Windows)

1. Install `LGMobileDriver_WHQL_Ver_4.4.2.exe` → **reboot**.
2. Extract `LGUP_DualMode.zip` → run `LGUP_Store_Frame_Ver_1_14_3.msi`.
   - If the installer appears to do nothing: run
     `msiexec /i LGUP_Store_Frame_Ver_1_14_3.msi /l*v lgup.log` and check the log.
3. Run **`SetDev.bat` as Administrator** — this installs the dev LGUP DLL that
   unlocks PARTITION DL mode. Verify `LGUP_Common.dll` got patched in the install
   dir (`C:\Program Files (x86)\LG Electronics\LGUP\` by default, but confirm —
   it may install elsewhere).
4. Extract platform-tools somewhere short (`D:\platform-tools`).

## Phone prep

1. **Remove every Google account**: Settings → Accounts → each account → Remove.
   (Skip this and FRP will demand the old account after flashing.)
2. Back up everything — internal storage gets wiped.
3. Charge to **≥60 %**.
4. Enable Developer options → **USB debugging** → authorize the PC.
   Verify: `adb devices` shows `device` (not `unauthorized`).

## Button cheat-sheet (memorize — you'll use it a lot)

| Action | Combo |
|---|---|
| **Download Mode** | Power off → hold **Vol+** → plug USB in (keep holding ~5 s). Screen shows *Firmware Update* |
| **Fastboot** | Power off → hold **Vol−** → plug USB in. Screen shows *FASTBOOT MODE* |
| **Force off / reboot** | Hold **Power** ~10 s (release the instant screen goes black, or it reboots) |
| **Recovery / factory-reset dance** | Off → hold **Vol− + Power** → at LG logo **release Power ~1 s then press again** (keep Vol− held) → *Factory data reset* menu → Yes → Yes |
| **Into Download Mode from a bootloop** | USB connected → hold **Vol+** continuously → also hold **Power** until screen dies → release Power, keep Vol+ |

On stock, the factory-reset dance wipes the phone. **Once a custom recovery is
flashed, the same dance boots the recovery instead** — this is the standard way
into Lineage Recovery, forever.

---

Next → [02 — Bootloader Unlock](02-bootloader-unlock.md)
