# home-manager/utilities/zsh.nix
# Zsh shell configuration
# Note: If you have a running zsh session you're gonna have to do source ~/.zshrc for the changes to load.
{
  config,
  pkgs,
  ...
}:
{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    # History settings
    history = {
      size = 10000;
      save = 10000;
      path = "${config.home.homeDirectory}/.zsh_history";
      ignoreDups = true;
      share = true;
    };

    # Oh-My-Zsh
    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "docker"
        "sudo"
        "fzf"
        "direnv"
      ];
    };

    # Powerlevel10k theme
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    # Shell aliases
    shellAliases = {
      # General
      ll = "eza -la --icons";
      ls = "eza --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git
      gs = "git status";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";
      gd = "git diff";
      gco = "git checkout";

      # NixOS
      # Use repo flake path under the user's home directory
      nfu = "nix flake update --flake ${config.home.homeDirectory}/GitRepos/nixos-dotfiles";
      nsr = "sudo nixos-rebuild switch --flake ${config.home.homeDirectory}/GitRepos/nixos-dotfiles#railgun";
      nrt = "sudo nixos-rebuild test --flake ${config.home.homeDirectory}/GitRepos/nixos-dotfiles#railgun";
      hms = "home-manager switch --flake ${config.home.homeDirectory}/GitRepos/nixos-dotfiles#railgun-linux-desktop --cores 0 -j auto";

      # System — do a full stack re-system + home-manager update + rebuild
      update = "cd ${config.home.homeDirectory}/GitRepos/nixos-dotfiles && nfu && nsr && hms";
      cleanup = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
    };

    # Init content
    initContent = ''
      # Source Powerlevel10k config
      # This way after you setup Powerlevel10k, you can just run `p10k configure` 
      # and it will generate the config file for you without needing to modify this again.
      source ~/.p10k.zsh
      # Source the Powerlevel10k configuration file
      if [[ -f "$HOME/.p10k.zsh" ]]; then
        source "$HOME/.p10k.zsh"
      fi


      # FZF configuration
      export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
      export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

      # PATH additions
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  home.packages = with pkgs; [
    zsh-completions
    zsh-syntax-highlighting
    zsh-history-substring-search
    zsh-powerlevel10k
  ];
}
