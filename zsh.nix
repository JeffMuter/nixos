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
	"zsh-syntax-highlighting"
	"zsh-autosuggestions"
      ];
    };
    
    # History settings
    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    
    # Enable additional features
    autosuggestions = {
      enable = true;
      strategy = ["history" "completion"];
    };
    syntaxHighlighting.enable = true;
  };

  # If you really need to set maxBufferSize, you can do it through environment variables
  environment.variables = {
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
  };
}
