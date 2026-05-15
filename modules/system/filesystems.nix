{ ... }: {
  flake.nixosModules.ForzaFilesystems = { pkgs, lib, ... }: {
    boot.supportedFilesystems = [ "btrfs" ];

    # Root pool: btrfs across both NVMe (native RAID0 for data, RAID1 for metadata).
    # Create during install with, e.g.:
    #   mkfs.btrfs -L nixos -d raid0 -m raid1 /dev/nvme0n1p3 /dev/nvme1n1p1
    # Then create subvolumes @, @home, @nix.
    fileSystems."/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=@" "compress=zstd" "noatime" "ssd" ];
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=@home" "compress=zstd" "noatime" "ssd" ];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "btrfs";
      options = [ "subvol=@nix" "compress=zstd" "noatime" "ssd" ];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    # Auto mount
    fileSystems."/run/media/gooblin/lw" = {
      device = "/dev/disk/by-label/lw";
      fsType = "ext4";
      options = [ "defaults" "nofail" ];
    };

    # Single swap-партиция на nvme0n1 (36 GiB) — sized for hibernate из 32 GB RAM
    # (RAM + ~4 GiB margin). Striped swap по двум дискам несовместим с hibernate.
    swapDevices = [
      { device = "/dev/disk/by-label/swap"; }
    ];

    # Hibernate-resume: ядру передаётся `resume=…` в cmdline.
    boot.resumeDevice = "/dev/disk/by-label/swap";
  };
}
