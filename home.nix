{ config, pkgs, ... }:

{
  home.username = "kluhan";
  home.homeDirectory = "/home/kluhan";

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    neofetch
    nnn 
    btop  
  ];

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings.user = {
      name = "kluhan";
      email = "klaus.luhan@gmail.comm";
    };
  };

  # starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    # custom settings
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    # TODO add your custom bashrc here
    bashrcExtra = ''
    #  export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';

    # set some aliases, feel free to add more or remove some
    # shellAliases = {
    #   k = "kubectl";
    # };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
