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
    "history-substring-search"
    "dirhistory"
    "docker"
    "docker-compose"
    "npm"
    "nvm"
    "node"
    "pip"
    "thefuck"
    "python"
    "rust"
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
    "git-auto-fetch"
    "git-flow"
    "git-prompt"
    "gitfast"
    "github"
    "gitignore"
    "golang"
    "pass"
    "poetry"
    "rsync"
    "ruby"
    "screen"
    "ufw"
    "vscode"
    "yarn"
      ];
    };

    shellAliases = {
	win32yank = "/mnt/c/Users/jeffmuter/AppData/Local/Microsoft/WinGet/Packages/equalsraf.win32yank_Microsoft.Winget.Source_8wekyb3d8bbwe/win32yank.exe";
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

  environment.sessionVariables = {
    GOPATH = [ "$HOME/go" ];
  };
}
