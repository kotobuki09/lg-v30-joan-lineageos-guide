# 05 — Troubleshooting

Every problem below was actually hit during the reference run — these are the
real fixes, not generic advice.

## During the KDZ flashes

**"Dead Android" / bootloop screen after a LGUP flash**
Expected after the Nougat step (and possibly Oreo). The flash didn't fail —
just get back into Download Mode.

**Can't get into Download Mode — Power+Vol− keeps rebooting**
Power+Vol− is the *reboot* combo, not power-off. Two reliable paths:
- Unplug USB → hold **Power ~10 s** until fully black (release immediately or it
  reboots) → hold **Vol+** → plug USB.
- Or from a reboot loop: USB plugged in → hold **Vol+ continuously** → also hold
  Power until the screen dies → release Power only, keep Vol+ → boots straight
  to *Firmware Update*.

**LGUP: "Can't find handset"**
Unplug/replug USB. Verify the LG driver installed and you rebooted after.

**LGUP MSI installs nothing**
Run `msiexec /i LGUP_Store_Frame_Ver_1_14_3.msi /l*v lgup.log`, read the log.
Then run `SetDev.bat` **as Administrator** — dev mode is required for
PARTITION DL.

## During fastboot/unlock

**`fastboot devices` shows `????` and every command fails**
Windows bound the Qualcomm driver (v1.0.1.7) — it's broken for joan fastboot.
Device Manager → the fastboot device → Update driver → *Let me pick* →
**Android Bootloader Interface** (Google, from the USB driver). If the device
vanishes after the swap, replug into a different USB port and re-enter fastboot.
**Prefer a USB-2 port** — V30 fastboot is flaky over USB3.

**`fastboot flash unlock` printed an error like "Wrong unlock key size"**
**That's success.** The exploit abuses the error path — it then erases userdata
and the bootloader is open. Confirm: `fastboot getvar unlocked` → `yes`.

**Unlock "didn't work"**
You flashed a patched firmware. Re-verify the KDZ header (doc 01) — it was
almost certainly a mislabeled late-build mirror.

## During LineageOS install

**Bootloop at "V30+" logo after first LOS boot**
You skipped **Format data** — stock's encrypted userdata is still there.
Fix: `fastboot boot recovery.img` → Factory reset → Format data → reboot.
The ROM itself is untouched — 2-minute fix.

**Factory-reset dance did a REAL factory reset instead of booting recovery**
Stock recovery was still resident — or a stock boot happened after flashing
recovery, which **restores stock recovery on first boot**. Reflash recovery and
boot it immediately (`fastboot boot`, or dance straight after flash with no
stock boot in between).

**Sideload stalls at ~47% / ~71%**
Normal — the transfer pauses but device-side install continues. Wait for
"Install completed with status 0".

**"Signature verification failed" on gapps/Magisk**
Expected for addon zips in Lineage Recovery — select **Yes**.

## After install / root

**Magisk app shows "Installed: N/A" but magiskd is running**
Root is fine — only the manager APK is missing: `adb install Magisk.apk`.
Open it once to finish setup.

**su denied from ADB shell**
Open Magisk → Superuser tab → Shell → **Allow** (a pending request may be
queued; also check the response isn't set to deny).

**Custom hosts module doesn't mount after reboot (hosts reverts to tiny file)**
Magisk's **built-in `hosts` module** exists and wins the mount. Don't fight it —
write your blocklist into `/data/adb/modules/hosts/system/etc/hosts` and delete
your custom module dir. Same result, done properly.

**Lineage Recovery replaced by stock recovery**
You booted stock once after flashing recovery. Reflash, then go to recovery
immediately — never let stock boot in between.

## Daily-use quirks (not bugs)

- Unlocked-bootloader warning screen every boot — cosmetic, unremovable.
- Netflix/streaming: Widevine L1 lost → SD or not working. GCam unaffected.
- VoLTE: works for most; verify with your carrier early.
- GCam occasionally freezes switching modes — relaunch (known joan quirk).
- Every LOS OTA wipes Magisk (non-A/B) → re-sideload Magisk zip in recovery.

## Nuclear option — full unbrick / back to stock

Unlock survives flashing, and LGUP always works in Download Mode:

1. Download Mode → LGUP → PARTITION DL → `H93031a_00_OPEN_EU_OP_1105.kdz` →
   Select All → Start.
2. Factory-reset dance → stock Pie, fully working, still unlocked.

**Always keep the H930 Pie KDZ.** It is the single file that rescues anything.
