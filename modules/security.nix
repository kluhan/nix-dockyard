{ config, pkgs, ... }:

{
  # Firewall
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 80 443 ];
  };

  services.fail2ban.enable = true;


  # Hardened SSH defaults for all hosts
  services.openssh = {
    enable = true;
    KexAlgorithms = [ "curve25519-sha256" ];
    ciphers = [ "chacha20-poly1305@openssh.com" ];
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
  };
}