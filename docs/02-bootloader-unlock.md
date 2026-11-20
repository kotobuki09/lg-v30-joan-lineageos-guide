# 02 — Bootloader Unlock (US998 Frankenstein + WTF exploit)

The unlock exploit only works against **early-Oreo joan firmware** and was built
on `US99820a`. Since surviving H930 early-Oreo mirrors are all mislabeled (see
doc 01), the proven route is:

```
LGUP → US99810d Nougat → LGUP → US99820a Oreo → fastboot unlock → LGUP → H930 Pie
```

> **If you somehow find a real H930 early-Oreo KDZ** (header-verified 20a–20d,
> ≤ ~April 2018, OPEN_EU), you can flash that instead of the US998 Oreo step and
> skip Nougat. Verify the header first — don't trust the filename.

## Step 1 — Flash US99810d (Nougat)

1. Phone into **Download Mode** (hold Vol+ → plug USB). Screen: *Firmware Update*.
2. Windows should show it as an LG COM port. If LGUP says *can't find handset*,
   unplug/replug USB.
3. Open LGUP → the phone appears in the device list.
4. Process = **PARTITION DL** → File Path → select `US99810d_01_0411.kdz`.
5. Partition list pops up → **Select All** → confirm → **Start** (~5–10 min).

When LGUP says *Completed*, the phone will likely **bootloop or sit on a
dead-Android / error screen. That is expected.** Do not try to boot it.

> ℹ️ From here until step 4 the phone identifies as **US998** (fastboot serial
> shows `LGUS998…`, model strings change). Fully expected — the H930 Pie flash
> restores EU identity at the end.

## Step 2 — Flash US99820a (Oreo — the exploit firmware)

1. Back into Download Mode. From the bootloop: **unplug USB → hold Power ~10 s
   until black → hold Vol+ → plug USB** (see cheat-sheet for the
   reboot-into-download-mode variant).
2. LGUP → PARTITION DL → `US99820a_04_0330.kdz` → Select All → Start.

## Step 3 — Run the exploit (fastboot)

1. Into **Fastboot Mode**: power off → hold **Vol−** → plug USB → *FASTBOOT MODE*.
2. Driver check — run `fastboot devices`. Problems and fixes:

   - **`???? fastboot` + commands fail** → Windows bound the wrong driver
     (often a Qualcomm v1.0.1.7). The V30 fastboot is flaky over USB3 too.
     Fix: Device Manager → Android Bootloader Interface → update driver →
     *Let me pick* → **Android Bootloader Interface** (Google). If the device
     disappears after a driver change, unplug → plug into a **different port**
     (prefer a USB2/black port) → re-enter fastboot.
   - Nothing detected → check `lg` LG driver installed, try other USB port/cable.

3. Flash the unlock blob:

   ```bash
   fastboot flash unlock new_unlock.bin
   ```

   Output ends with `Erasing userdata and cache...` — **a "Wrong unlock key
   size" style complaint means SUCCESS** (the exploit abuses the error path).

4. Verify:

   ```bash
   fastboot getvar unlocked
   # unlocked: yes   ✅
   ```

   `unlocked: yes` = done. This persists through all later KDZ flashes.

## Step 4 — Return to H930 Pie

LineageOS needs an **Android 9 firmware base** — and H930 Pie restores your
region/modem config after the US998 excursion.

1. Download Mode again (bootloop → Vol+ hold through restart).
2. LGUP → PARTITION DL → `H93031a_00_OPEN_EU_OP_1105.kdz` → Select All → Start.
3. Factory-reset dance → let it boot Android once → quick sanity check
   (Setup wizard reachable is enough — full SIM test comes after LOS).

> The unlock survives reflashing — confirmed: `unlocked: yes` remains after the
> H930 Pie flash.

## Common problems here

| Symptom | Cause | Fix |
|---|---|---|
| Bootloop / dead-Android after Nougat flash | Expected — incomplete firmware set | Just get back into Download Mode, continue |
| Can't reach Download Mode from bootloop | Power+Vol− is *reboot*, not off | Unplug → hold Power 10 s till black → Vol+ → plug USB. Or: USB in, hold Vol+ through a Power-forced restart |
| `fastboot` commands hang/fail | Wrong driver bound (Qualcomm) or USB3 | Rebind Android Bootloader Interface; switch to USB2 port |
| "Wrong unlock key size" | — | **That IS success** — verify with `fastboot getvar unlocked` |
| Unlock seems to do nothing | Firmware too new (patched) | Header-verify the KDZ you flashed — almost certainly a mislabeled mirror |

---

Next → [03 — LineageOS + Root](03-lineageos-install.md)
