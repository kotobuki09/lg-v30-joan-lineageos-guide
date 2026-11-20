# 04 — Post-install: Root Config, Ad-block & the Optimization Layer

Everything here was installed and verified working on LOS 22.2 / joan.
Prereq: Magisk app opened once, shell root granted.

> **Honest note first:** skip the popular Magisk "performance booster"
> modules — they're placebo scripts, and the aggressive ones break thermal and
> process management. On a clean LOS base the SD835 already runs its best.
> Everything below is a *real* capability, not snake oil.

## 1 — Magisk settings

```bash
adb shell "su -c 'magisk --sqlite \"INSERT OR REPLACE INTO settings (key,value) VALUES (\\\"zygisk\\\",1),(\\\"denylist\\\",1)\"'"
adb reboot
```

- **Zygisk** — required for LSPosed and most modern modules.
- **DenyList** — add banking/payment apps here *before* first opening them.
  (Magisk → Superuser → DenyList, or the list appears in the Magisk app.)

## 2 — System-wide ad-block (hosts, zero battery cost)

Uses Magisk's **built-in** Systemless Hosts module — no VPN, no running service.

⚠️ **Key gotcha:** don't create a *new* hosts module — Magisk already ships
`/data/adb/modules/hosts` (id=hosts) which wins the mount race; a custom module
silently fails after reboot. Write into the built-in one:

```bash
# Get StevenBlack unified hosts (~76–83k domains), then:
adb push hosts_stevenblack.txt /data/local/tmp/hosts
adb shell "su -c 'cp /data/local/tmp/hosts /data/adb/modules/hosts/system/etc/hosts \
  && chmod 644 /data/adb/modules/hosts/system/etc/hosts \
  && mount --bind /data/adb/modules/hosts/system/etc/hosts /system/etc/hosts'"
adb shell "ping -c1 -W2 ads.doubleclick.net"   # "unknown host" = blocking live ✅
```

Persists across reboots (magic-mount). Verify with `wc -l /system/etc/hosts`.

**AdAway** (optional GUI): install `AdAway-6.1.4.apk` → Root mode → it manages
the *same* module — scheduled updates + custom lists.
github.com/AdAway/AdAway/releases

## 3 — LSPosed (JingMatrix fork — the only one supporting Android 15)

Official LSPosed is EOL at A14. Use **JingMatrix/Vector** — releases live under
`github.com/JingMatrix/Vector/releases` (v1.11.0+, `*-zygisk-release.zip`).

```bash
adb push LSPosed-v1.11.0-7209-zygisk-release.zip /data/local/tmp/
adb shell "su -c 'magisk --install-module /data/local/tmp/LSPosed-*.zip'"
# manager.apk is inside the module dir — install it for a proper app icon:
adb shell "su -c 'cp /data/adb/modules/zygisk_lsposed/manager.apk /data/local/tmp/'"
adb pull /data/local/tmp/manager.apk . && adb install manager.apk
adb reboot
```

Verify: `ps -A | grep lspd` → daemon running.

**Modules worth it (verified on this build):**

| Module | What it does | Scope |
|---|---|---|
| `com.github.dan.NoStorageRestrict` | Fixes A15's crippled file/folder access | External Storage |
| `io.github.lsposed.disableflagsecure` | Screenshots in protected apps (may refuse on custom ROMs — YMMV) | system + SystemUI |
| `com.darkeyes.tricks` (Dark Tricks v3.4) | **Double-tap status bar = sleep** + misc | com.android.systemui |

Enable in LSPosed manager → Modules → enable + set scope → reboot. Dark Tricks
also needs its toggle enabled in the Tricks app.

> Homescreen empty-space double-tap-to-sleep on Trebuchet is **dead code** in
> LOS — the strings exist but the implementation is disabled. If you want it,
> Neo Launcher (com.saggitt.omega, GitHub: NeoApplications/Neo-Launcher) is a
> near-identical Pixel launcher with the gesture built in.

## 4 — ViPER4Android RE (Quad DAC audio)

Check which build you need — joan runs the **legacy (non-AIDL)** audio HAL:

```bash
adb shell "su -c 'service list | grep -i IFactory'"
# no android.hardware.audio.effect.IFactory/default → NON-AIDL module
```

- Module: `ViPER4Android-RE-v2.1.2.zip` — github.com/likelikeslike/ViPERFX_RE/releases
  (AIDL variant is only for devices launched on A15+)
- App: `ViPER4Android-2.1.2.apk` — github.com/likelikeslike/ViPER4Android/releases

```bash
adb push ViPER4Android-RE-v2.1.2.zip /data/local/tmp/
adb shell "su -c 'magisk --install-module /data/local/tmp/ViPER4Android-RE-v2.1.2.zip'"
adb install ViPER4Android-2.1.2.apk && adb reboot
```

Verify: `/vendor/etc/audio_effects.xml` shows `v4a_re` entries +
`/vendor/lib64/soundfx/libv4a_re.so` exists; open the app → "Driver: OK".
Wired headphones → enable Master Power, Convolver, Viper Bass.

## 5 — Play Integrity (banking apps)

Unlocked bootloader fails Play Integrity out of the box. Working stack:

```bash
# modules (push + magisk --install-module each):
osm0sis/PlayIntegrityFork      → PlayIntegrityFork-v19.zip
5ec1cff/TrickyStore            → Tricky-Store-*.zip
KOWX712/Tricky-Addon-Update-Target-List → TrickyAddonModule-*.zip
```

```bash
adb reboot
# after boot, fetch config + reset attestation:
adb shell "su -c 'sh /data/adb/modules/playintegrityfix/action.sh'"
```

Verify with **SPIC** (herzhenr/spic-android). Expected: ✅ BASIC + DEVICE.
**STRONG needs a valid keybox** — leaked attestation keys get revoked within
days; they're shared on TrickyStore Telegram channels. Drop a valid
`keybox.xml` into `/data/adb/tricky_store/` when one is needed.

Then: banking apps → Magisk DenyList → test. Play Store → Settings → About →
"Play Protect certification" should say certified.

## 6 — Useful extras

- **AdAway 6.1.4** — hosts GUI (above)
- **Neo Backup** — root app/data backups — github.com/NeoApplications/Neo-Backup
- **GCam** — `MGC_8.7.250_A11_V15a_MGC.apk` (celsoazevedo.com → dev-BSG → dl134):
  most stable port for H930. Known quirk: occasionally freezes switching modes
  — relaunch it. The stock LOS camera works fine as fallback.
- **UI speed**: `settings put global {window,transition,animator}_animation_scale 0.5`
- **SPIC** — Play Integrity checker — github.com/herzhenr/spic-android

## Module inventory after this doc

```
/data/adb/modules/
├── hosts               (built-in → your blocklist)
├── playintegrityfix
├── tricky_store
├── TA_utl              (TrickyAddon — may self-remove after applying)
├── ViPER4Android-RE
└── zygisk_lsposed
```

---

Pitfalls? → [05 — Troubleshooting](05-troubleshooting.md)
