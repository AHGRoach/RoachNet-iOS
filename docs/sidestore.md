# SideStore and AltStore install

Use this when you want the RoachNet companion app on an iPhone or iPad without a paid Apple developer account.

## What you need

1. A working SideStore or AltStore setup on the device.
2. The shared RoachNet AltSource or the unsigned RoachNet IPA from a GitHub release.
3. A Mac running RoachNet with the companion lane enabled.

## Install with SideStore

1. In Safari on the device, open:
   `https://raw.githubusercontent.com/RoachWares/RoachNet-SideStore/main/apps.json`
2. Copy or add that source URL inside SideStore.
3. Install `RoachNetiOS` from the source list.
4. If you want the direct file instead, download `RoachNetiOS-v0.1.5-unsigned.ipa` to Files.
5. In SideStore, go to `My Apps`, tap the add button, and pick the IPA from Files.
6. Let SideStore sign and install it with your Apple ID.

## Install with AltStore

1. Keep AltServer running on your Mac and make sure the phone is trusted by Finder.
2. In AltStore, add the RoachNet source:
   `https://raw.githubusercontent.com/RoachWares/RoachNet-SideStore/main/apps.json`
3. Install `RoachNetiOS` from the source list.
4. If you want the direct file instead, download `RoachNetiOS-v0.1.5-unsigned.ipa` to Files.
5. In AltStore, open `My Apps`, tap the add button, and pick the IPA from Files.
6. Refresh before the signing window expires.

## First launch

1. Open `RoachNet`.
2. Paste the companion URL from your Mac.
3. Paste the companion token from your Mac.
4. Tap `Save`.
5. Refresh once if the runtime is still warming up.

## Pairing tips

- Use the `http://RoachNet:38111` desktop alias when it is available locally, or pair over RoachTail for the secure device lane.
- Keep the phone and Mac on the same network unless you have your own secure tunnel in front of the companion port.
- Do not expose the companion token publicly.
- If installs from the Apps catalog fail, verify the paired Mac runtime is healthy first. The phone keeps a small queue so useful packs do not vanish just because the Mac was asleep.
- Voice prompts use Apple's on-device speech lane when the selected language pack is available.
- The iOS app is just the companion surface. The real models, vault, and installs still live on the paired RoachNet desktop.

## Notes

- Free Apple accounts still inherit Apple’s normal sideload limits.
- Reinstalling the same IPA through SideStore or AltStore should preserve app data in normal cases.
- SideStore documentation: https://docs.sidestore.io/
- AltStore documentation: https://altstore.io/
- RoachNet shared source: https://raw.githubusercontent.com/RoachWares/RoachNet-SideStore/main/apps.json
- RoachNet source repo: https://github.com/RoachWares/RoachNet-SideStore
