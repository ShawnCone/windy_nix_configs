{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # File System Configuration
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT"; # Root partition
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT"; # EFI partition
      fsType = "vfat";
    };
  };

  # Swap File
  swapDevices = [
    { device = "/mnt/.swapfile"; }
  ];

  # Bootloader Configuration
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # NVIDIA Configuration
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    cuda.enable = true;
  };
  hardware.opengl = {
    enable = true;
    driSupport32Bit = true; # For CUDA support with 32-bit libraries
  };

  # Services
  services = {
    # SSH Server
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # VSCode Server
    vscode-server.enable = true;

    # Network Management
    networkmanager.enable = true;

    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]; # SSH port
    };
  };

  # Python Environment
  environment.systemPackages = with pkgs; [
    (python311.withPackages(ps: with ps; [
      pip
      numpy
      pandas
      scipy
      scikit-learn
      pytorch
      torchvision
      tensorflow
      jupyter
      matplotlib
    ]))
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cupti
    cudaPackages.cuda_nvcc
    git
    vim
    vscode
    openssh
  ];

  # User Configuration
  users.users.ai-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    initialPassword = "changeme"; # Consider using hashed passwords or disabling entirely
    openssh.authorizedKeys.keys = [
      # Replace this with your public SSH key
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFg9hLkSMYG9Siy8oyNg6m1I94ZtNBy1kcYhfiW1xgR daveistanto@Daves-Toaster.local"
    ];
  };

  # System Version (Ensure compatibility)
  system.stateVersion = "24.11"; # Update this as you upgrade NixOS
}
