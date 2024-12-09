{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

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

  programs.nvidia-smi.enable = true;

  # Services
  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  # Network Configuration
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  # Python and Development Environment
  environment.systemPackages = with pkgs; [
    # Python and ML libraries
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
    cudaPackages.cudnn
    cudaPackages.nccl
    cudatoolkit
    # Development tools
    git
    vim
    openssh
    tmux
    htop
    nvtop
  ];

  # System Optimization for ML Workloads
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "soft";
      item = "nofile";
      value = "unlimited";
    }
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "unlimited";
    }
  ];

  # Automatic Garbage Collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # User Configuration
  users.users.ai-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFg9hLkSMYG9Siy8oyNg6m1I94ZtNBy1kcYhfiW1xgR daveistanto@Daves-Toaster.local"
    ];
  };

  system.stateVersion = "24.11";
}