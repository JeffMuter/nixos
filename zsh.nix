{ config, pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    ohMyZsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
         "git"
    "z"
    "fzf"
    "colored-man-pages"
    "command-not-found"
    "zsh-interactive-cd"
    "sudo"
    "history"
    "dirhistory"
    "docker"
    "docker-compose"
    "npm"
    "nvm"
    "node"
    "pip"
    "python"
    "rust"
    "cargo"
    "redis-cli"
    "kubectl"
    "helm"
    "terraform"
    "aws"
    "gcloud"
    "azure"
    "systemd"
    "tmux"
    "vim-interaction"
    "web-search"
    "extract"
    "jsontools"
    "urltools"
    "encode64"
    "copypath"
    "copyfile"
    "copybuffer"
    "direnv"
    "gh"
    "git-flow"
    "gitfast"
    "github"
    "gitignore"
    "pass"
    "poetry"
    "ripgrep"
    "rsync"
    "ruby"
    "screen"
    "thefuck"
    "ufw"
    "vscode"
    "yarn"
      ];
    };
    
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    
    # Add these lines to prevent the new user setup wizard
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;   
    
    # Use interactiveShellInit instead of initExtraBeforeCompInit
    interactiveShellInit = ''
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000
      setopt appendhistory
      setopt SHARE_HISTORY
      setopt HIST_EXPIRE_DUPS_FIRST
      setopt HIST_IGNORE_DUPS
      setopt HIST_FIND_NO_DUPS
      setopt HIST_REDUCE_BLANKS
    '';
  };

  environment.variables = {
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
  };
}
