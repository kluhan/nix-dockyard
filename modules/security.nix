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

    settings = {
      ciphers = [ "chacha20-poly1305@openssh.com" ];
      KexAlgorithms = [ "curve25519-sha256" ];
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
