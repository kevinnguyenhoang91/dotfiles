# Passwordless LUKS Boot on Mac mini (2018) & Omarchy (keyfile on `/boot`)

Verified on **Omarchy `4.5.0-3`** on the **Mac mini (2018)** (`Macmini8,1`, Intel + T2).
The root filesystem is LUKS2 on `/dev/nvme0n1p2`; `/boot` is an unencrypted
FAT32 partition on `/dev/nvme0n1p1`.

## What this does

Omarchy uses the LUKS passphrase at boot as the single authentication gate, so
encrypted installs already autologin through SDDM (`/etc/sddm.conf.d/autologin.conf`).
This guide removes the *typing* of that passphrase by adding a random keyfile to
a **new LUKS keyslot** and storing a copy on the unencrypted `/boot` partition.

Your original passphrase remains as a fallback keyslot.

> [!WARNING]
> Anyone who can read `/boot` (physical access, a stolen disk, or a compromised
> running system) can now decrypt the root filesystem. This removes the
> encryption-at-rest passphrase gate — do not use it on a machine whose disk
> can be stolen. Keep the LUKS header backup offline, and consider deleting
> `/etc/sddm.conf.d/autologin.conf` so SDDM still asks for a login password.

## 0. Confirm the stock boot path

This recipe targets Omarchy's default x86 initramfs: the busybox `encrypt` hook
plus a `cryptdevice=...` kernel parameter (not `sd-encrypt` / `rd.luks.name`).

```bash
lsblk -o NAME,FSTYPE,UUID,PARTUUID,MOUNTPOINTS /dev/nvme0n1
grep -E '^HOOKS=' /etc/mkinitcpio.conf
sudo limine-entry-tool --get-cmdline default | tail -n 1
sudo cryptsetup luksDump /dev/nvme0n1p2 | head -5
```

## 1. Back up the LUKS header

```bash
sudo cryptsetup luksHeaderBackup /dev/nvme0n1p2 \
  --header-backup-file /root/luks-header-backup-$(date +%F).img
sudo chmod 600 /root/luks-header-backup-*.img
```

Copy that file to safe offline storage. It is your undo path if a header
operation goes wrong (it does **not** protect against forgetting a passphrase).

## 2. Generate the keyfile and add a LUKS keyslot

```bash
sudo dd if=/dev/urandom of=/root/.omarchy-luks.key bs=4096 count=1 status=none
sudo chmod 600 /root/.omarchy-luks.key
sudo cryptsetup luksAddKey /dev/nvme0n1p2 /root/.omarchy-luks.key
```

Enter your existing LUKS passphrase when prompted. Verify the new slot:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2 | grep -E 'Keyslots:|luks2'
```

On re-runs you can skip the prompt by testing the key first:

```bash
sudo cryptsetup open --test-passphrase \
  --key-file /root/.omarchy-luks.key /dev/nvme0n1p2
```

## 3. Put the keyfile on unencrypted `/boot`

FAT32 does not support `chmod`, so use plain `cp` (not `install -m 600`):

```bash
sudo cp -f /root/.omarchy-luks.key /boot/omarchy-keyfile
sudo cmp -s /root/.omarchy-luks.key /boot/omarchy-keyfile
sudo sync
```

## 4. Add boot and initramfs drop-ins

`cryptkey=<device>:<fstype>:<path>` is read by the busybox `encrypt` hook. Use
the **filesystem UUID** of `/boot` (the short FAT serial, e.g. `DF1C-EA5F`),
not its PARTUUID and not the LUKS UUID.

```bash
BOOT_UUID=$(blkid -s UUID -o value /dev/nvme0n1p1)

sudo tee /etc/limine-entry-tool.d/zz-luks-keyfile.conf >/dev/null <<EOF
# Unlock LUKS root from a keyfile on the unencrypted /boot (vfat) partition.
KERNEL_CMDLINE[default]+=" cryptkey=UUID=${BOOT_UUID}:vfat:omarchy-keyfile"
EOF

sudo tee /etc/mkinitcpio.conf.d/zz-luks-keyfile.conf >/dev/null <<'EOF'
# Needed by the busybox encrypt hook to mount /boot at early boot.
MODULES+=(vfat)
EOF
```

Confirm the parameter is picked up:

```bash
sudo limine-entry-tool --get-cmdline default --no-mutex --no-hooks | tail -n 1
```

Expected to include: `cryptkey=UUID=DF1C-EA5F:vfat:omarchy-keyfile`.

## 5. Rebuild the UKI and reboot

`mkinitcpio -P` alone is **not** enough — the cmdline is embedded in the UKI,
so regenerate the Limine entries too:

```bash
sudo limine-mkinitcpio
sudo reboot
```

The Plymouth passphrase prompt should be skipped and the desktop should load.
If the keyfile is missing or invalid, the hook falls back to the passphrase
prompt, so a failed attempt is recoverable.

## Verification

After reboot:

```bash
tr ' ' '\n' </proc/cmdline | grep cryptkey
sudo cryptsetup open --test-passphrase \
  --key-file /root/.omarchy-luks.key /dev/nvme0n1p2 && echo "keyfile OK"
```

## Rollback

```bash
sudo rm /etc/limine-entry-tool.d/zz-luks-keyfile.conf \
       /etc/mkinitcpio.conf.d/zz-luks-keyfile.conf \
       /boot/omarchy-keyfile
sudo limine-mkinitcpio
```

Optionally wipe the keyslot once you have confirmed the passphrase still works:

```bash
sudo cryptsetup luksDump /dev/nvme0n1p2 | grep -A20 '^Keyslots:'
sudo cryptsetup luksKillSlot /dev/nvme0n1p2 <slot>
```

## Troubleshooting

- **`FAILED ... grep -E '^Key Slot'`** — LUKS2 prints a `Keyslots:` section
  instead of the old `Key Slot N:` lines. This was only a display line; use
  `grep -E 'Keyslots:|luks2'` instead.
- **Still asks for a passphrase** — check that `/boot/omarchy-keyfile` exists,
  that `cryptkey=...` is in `/proc/cmdline`, that `vfat` is in the initramfs,
  and that the key is enrolled (`cryptsetup open --test-passphrase ...`).
- **Black screen / boot failure** — boot an older Limine or snapshot entry,
  then remove the drop-ins and rebuild as in *Rollback*.
