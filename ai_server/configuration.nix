{ config, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.cudaSupport = true;

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    open = false;
    nvidiaSettings = true;
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
    ];
  };

  services = {
    openssh = {
      enable = true;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  environment.systemPackages = with pkgs; [
    (python311.withPackages(ps: with ps; [
      pip
      numpy
      pandas
      scipy
      scikit-learn
      pytorchWithCuda
      torchvision-bin
      tensorflow
      jupyter
      matplotlib
    ]))
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cupti
    cudaPackages.cuda_nvcc
    cudaPackages.cudnn
    cudaPackages.nccl
    cudatoolkit
    git
    vim
    openssh
    tmux
    htop
    nvtop
  ];

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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  users.users.ai-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" "video" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFg9hLkSMYG9Siy8oyNg6m1I94ZtNBy1kcYhfiW1xgR daveistanto@Daves-Toaster.local"
    ];
  };

  system.stateVersion = "24.11";
}