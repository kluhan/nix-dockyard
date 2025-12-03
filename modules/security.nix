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
    ciphers = [ "chacha20-poly1305@openssh.com" ];

    settings = {
      KexAlgorithms = [ "curve25519-sha256" ];
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
