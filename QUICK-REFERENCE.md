# Quick Reference — LG V30 (joan)

For repeat runs and daily use. Full detail → [README](README.md) → docs/01–05.

## Buttons

| Mode | Combo |
|---|---|
| Download Mode | off → hold **Vol+** → plug USB |
| Fastboot | off → hold **Vol−** → plug USB |
| Recovery (custom installed) | off → **Vol− + Power** → release/repress Power at LG logo → Yes/Yes |
| Force off | hold Power ~10 s, release the instant it goes black |
| Loop → Download Mode | USB in → hold Vol+ → also hold Power till screen dies → release Power only |

## Flash sequence (repeat run)

```bash
# 1. Download Mode → LGUP PARTITION DL → US99810d_01_0411.kdz  → Select All
# 2. Download Mode → LGUP PARTITION DL → US99820a_04_0330.kdz  → Select All
# 3. Fastboot:
fastboot flash unlock new_unlock.bin     # "wrong key size" = SUCCESS
fastboot getvar unlocked                 # → unlocked: yes
# 4. Download Mode → LGUP PARTITION DL → H93031a_00_OPEN_EU_OP_1105.kdz
# 5. Fastboot:
fastboot boot recovery.img               # temporary — boot it NOW
# 6. Recovery → Factory reset → Format data        # MANDATORY — skip = bootloop
# 7. Recovery → Apply from ADB, then sideload in order:
adb sideload lineage-22.2-*-joan-signed.zip   # ~47% pause = normal
adb sideload MindTheGapps-15.0.0-arm64-*.zip  # signature warn → Yes
adb sideload Magisk-v*.zip                    # root
# 8. Reboot system (≤15 min first boot) → finish setup → re-enable USB debugging
# 9. Make recovery permanent:
adb reboot bootloader && fastboot flash recovery recovery.img && fastboot reboot
adb install Magisk-v*.apk
```

## File checksums (verify before flashing — filenames lie)

| File | Verify |
|---|---|
| `US99820a_04_0330.kdz` | **MD5 `5654dd3238db691c1e6e633fe16092c4`** |
| `H93031a_00_OPEN_EU_OP_1105.kdz` | **MD5 `ddd83ac54746e75210fed671a44e1285`** |
| `US99810d_01_0411.kdz` | header contains `US99810d_01.dz` |
| `LGUP_DualMode.zip` | MD5 `0265e2d5dd98f59bcfa02e192e8be288` |
| `LGMobileDriver_WHQL_Ver_4.4.2.exe` | MD5 `3cf43fac010f5a44b80d9115422f3fd4` |
| `new_unlock.bin` | exactly 1024 bytes |
| LOS zip / recovery.img | SHA256 vs download.lineageos.org API |

## Post-install quick commands

```bash
# Ad-block (into the BUILT-IN hosts module — custom module won't mount)
adb push hosts.txt /data/local/tmp/hosts
adb shell "su -c 'cp /data/local/tmp/hosts /data/adb/modules/hosts/system/etc/hosts && chmod 644 $_'"

# Magisk module from a zip (no app GUI needed)
adb push mod.zip /data/local/tmp/ && adb shell "su -c 'magisk --install-module /data/local/tmp/mod.zip'"

# Zygisk + DenyList
adb shell "su -c 'magisk --sqlite \"INSERT OR REPLACE INTO settings (key,value) VALUES (\\\"zygisk\\\",1),(\\\"denylist\\\",1)\"'" && adb reboot

# PIF refresh after integrity modules
adb shell "su -c 'sh /data/adb/modules/playintegrityfix/action.sh'"

# Faster animations
adb shell "for s in window transition animator; do settings put global \${s}_animation_scale 0.5; done"
```

## Health checks

```bash
adb shell getprop ro.lineage.version        # ROM build
fastboot getvar unlocked                    # unlock state
adb shell "su -c 'wc -l /system/etc/hosts'" # ad-block mounted?
adb shell "ps -A | grep -E 'lspd|magiskd'"  # daemons up?
```

## After every LOS OTA (non-A/B device)

Recovery → Apply from ADB → `adb sideload Magisk-*.zip` → reboot. No data loss.

## Unbrick

Download Mode → LGUP PARTITION DL → `H93031a` KDZ → Select All. Always works;
unlock survives. **Keep this KDZ forever.**
