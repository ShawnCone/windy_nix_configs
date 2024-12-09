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
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
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

  # NVIDIA and CUDA Configuration
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  # OpenGL Configuration
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  # Enable CUDA support
  nixpkgs.config.cudaSupport = true;

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
  };
  
  # Network Configuration
  networking = {
    # NetworkManager
    networkmanager.enable = true;
    # Firewall
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Python Environment
  environment.systemPackages = with pkgs; [
    # Python and scientific computing libraries
    (python311.withPackages(ps: with ps; [
      pip
      numpy
      pandas
      scipy
      scikit-learn
      pytorch-cuda
      torchvision
      tensorflow-cuda
      jupyter
      matplotlib
    ]))
    # CUDA tools and libraries
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cupti
    cudaPackages.cuda_nvcc
    cudatoolkit
    # Tools
    git
    vim
    vscode
    openssh
  ];

  # User Configuration
  users.users.ai-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFg9hLkSMYG9Siy8oyNg6m1I94ZtNBy1kcYhfiW1xgR daveistanto@Daves-Toaster.local"
    ];
  };

  # System Version
  system.stateVersion = "24.11";
}