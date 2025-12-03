{ config, pkgs, ... }:

{
  # Shared user configuration
  users.users.kluhan = {
    isNormalUser = true;
    description = "kluhan user";
    initialPassword "admin"
    extraGroups = [ "wheel" "networkmanager" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAA....DEIN_KEY"
    ];
  };
}
