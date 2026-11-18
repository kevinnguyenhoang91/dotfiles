# Enable Bluetooth Keyboard at Boot (LUKS Prompt) on Mac mini (2018) & Omarchy

On the **Mac mini (2018)** (Intel + Apple T2), the Broadcom Bluetooth chip (`BCM4364B0`) communicates over the **Serial/UART bus** (`hci_uart`) rather than USB (`btusb`). By default, these serial and Bluetooth drivers are loaded only after the root filesystem is decrypted.

Follow these steps to include the required drivers, firmware, and Bluetooth pairing data in the `initramfs` on **Omarchy**.

---

## 1. Install `yay`

Install `yay` directly using `pacman`:

```bash
sudo pacman -S yay
```

---

## 2. Install `mkinitcpio-bluetooth`

Install the hook package from the AUR so `mkinitcpio` can bundle Bluetooth services and paired device keys into the boot image:

```bash
yay -S mkinitcpio-bluetooth
```

---

## 3. Pair and Trust Your Bluetooth Keyboard

Ensure your keyboard is paired and marked as **trusted** in your desktop session so it can reconnect automatically without user prompts during boot:

1. Open a terminal and launch `bluetoothctl`:
   ```bash
   bluetoothctl
   ```
2. List your paired devices to find your keyboard's MAC address:
   ```text
   devices
   ```
3. Trust the keyboard (replace `AA:BB:CC:DD:EE:FF` with your keyboard's MAC address):
   ```text
   trust AA:BB:CC:DD:EE:FF
   ```
4. Exit `bluetoothctl`:
   ```text
   exit
   ```

---

## 4. Enable Auto-Power on Boot

Edit the Bluetooth daemon configuration so the controller powers on automatically when initialized:

```bash
sudo nvim /etc/bluetooth/main.conf
```

Uncomment (remove the `#` from) the following line:

```ini
AutoEnable=true
```

---

## 5. Configure Early Kernel Modules & Firmware

Omarchy uses drop-in configuration files inside `/etc/mkinitcpio.conf.d/` so user changes are not overwritten by system updates.

Create a dedicated configuration file for Bluetooth LUKS support:

```bash
sudo nvim /etc/mkinitcpio.conf.d/bluetooth-luks.conf
```

Add the following lines to append the Intel LPSS serial controller, UART HCI driver, HID generic layer, and Broadcom firmware early:

```text
MODULES+=(uhid hci_uart btbcm intel_lpss intel_lpss_pci 8250_dw hid_generic)
FILES+=(/lib/firmware/brcm/*)
```

---

## 6. Add the `bluetooth` Hook to Omarchy

Open Omarchy's hook configuration file:

```bash
sudo nvim /etc/mkinitcpio.conf.d/00-omarchy-hooks.conf
```

Add `bluetooth` right after `keyboard` in the `HOOKS` array:

```text
HOOKS=(base systemd plymouth autodetect microcode modconf kms keyboard bluetooth sd-vconsole block filesystems fsck)
```

---

## 7. Regenerate the Initramfs

Rebuild the boot images using `mkinitcpio`:

```bash
sudo mkinitcpio -P
```

---

## Usage Tip at Boot

* When the LUKS password screen appears, **press any key** (such as `Space` or your keyboard's active channel key) to wake the keyboard from sleep.
* Wait **2–3 seconds** for it to reconnect before typing your encryption passphrase.
