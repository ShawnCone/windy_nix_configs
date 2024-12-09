{ config, pkgs, ... }:

{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Enable SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Create ai-user with SSH access
  users.users.ai-user = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFFg9hLkSMYG9Siy8oyNg6m1I94ZtNBy1kcYhfiW1xgR daveistanto@Daves-Toaster.local"
    ];
    hashedPassword = null;
  };

  # NVIDIA Configuration
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.beta;
    modesetting.enable = true;
    powerManagement.enable = true;
  };

  # Install Python 3.11, CUDA and NVIDIA tools
  environment.systemPackages = with pkgs; [
    python311
    cudaPackages.cuda_nvcc
    cudaPackages.cuda_cudart
    nvidia-docker
    linuxPackages.nvidia_x11
  ];

  system.stateVersion = "23.11";
}