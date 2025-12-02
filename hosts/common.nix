{ config, pkgs, ... }:

{
  # Shared user configuration
  users.users.klaus = {
    isNormalUser = true;
    description = "Klaus";
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA....DEIN_KEY"
    ];
  };

  # Hardened SSH defaults for all hosts
  services.openssh = {
    enable = true;
    permitRootLogin = "no";
    passwordAuthentication = false;
  };
}
