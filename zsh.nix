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
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
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
      
      # Dotfiles sync functions
      dot-push() {
        echo "Syncing dotfiles from $(hostname)..."
        cd ~/.dotfiles || return 1
        stow -R * 2>/dev/null
        git add .
        git commit -m "sync: $(hostname) $(date '+%H:%M')" 2>/dev/null || echo "No changes to commit"
        git push origin master
        echo "Dotfiles pushed"
      }
      
      dot-pull() {
        echo "Pulling dotfiles to $(hostname)..."
        cd ~/.dotfiles || return 1
        git pull
        stow -R * --adopt 2>/dev/null
        git add . 2>/dev/null
        git commit -m "adopt: $(hostname) $(date '+%H:%M')" 2>/dev/null || true
        git push origin master 2>/dev/null || true
        echo "Dotfiles synced"
      }
      
      dot-sync() {
        dot-pull && dot-push
      }

      # Dotfiles status functions
      dot-status() {
          local dotfiles_dir="$HOME/.dotfiles"
          
          # Check if dotfiles directory exists
          if [[ ! -d "$dotfiles_dir" ]]; then
              echo "dotfiles: directory not found at $dotfiles_dir"
              return 1
          fi
          
          # Change to dotfiles directory
          cd "$dotfiles_dir" || return 1
          
          # Check if it's a git repository
          if [[ ! -d ".git" ]]; then
              echo "dotfiles: not a git repository"
              return 1
          fi
          
          echo "dotfiles: checking status..."
          
          # Fetch latest changes from remote (quietly)
          git fetch origin master 2>/dev/null || {
              echo "dotfiles: could not fetch from remote"
              return 1
          }
          
          # Get current branch
          local current_branch=$(git branch --show-current)
          
          # Check for uncommitted changes
          local has_uncommitted=""
          if ! git diff-index --quiet HEAD --; then
              has_uncommitted="yes"
          fi
          
          # Check for untracked files
          local has_untracked=""
          if [[ -n $(git ls-files --others --exclude-standard) ]]; then
              has_untracked="yes"
          fi
          
          # Compare local with remote
          local local_commit=$(git rev-parse HEAD)
          local remote_commit=$(git rev-parse origin/master 2>/dev/null)
          
          if [[ -z "$remote_commit" ]]; then
              echo "dotfiles: could not get remote commit info"
              return 1
          fi
          
          # Determine status
          local ahead_count=$(git rev-list --count HEAD ^origin/master 2>/dev/null || echo "0")
          local behind_count=$(git rev-list --count origin/master ^HEAD 2>/dev/null || echo "0")
          
          echo "dotfiles: branch $current_branch"
          
          if [[ "$local_commit" == "$remote_commit" ]]; then
              echo "dotfiles: up to date"
          elif [[ "$behind_count" -gt 0 && "$ahead_count" -eq 0 ]]; then
              echo "dotfiles: behind by $behind_count commits (run 'dl')"
          elif [[ "$ahead_count" -gt 0 && "$behind_count" -eq 0 ]]; then
              echo "dotfiles: ahead by $ahead_count commits (run 'dp')"
          elif [[ "$ahead_count" -gt 0 && "$behind_count" -gt 0 ]]; then
              echo "dotfiles: diverged - $ahead_count ahead, $behind_count behind"
          fi
          
          # Show local changes if any
          if [[ -n "$has_uncommitted" ]]; then
              echo "dotfiles: uncommitted changes"
          fi
          
          if [[ -n "$has_untracked" ]]; then
              echo "dotfiles: untracked files"
          fi
          
          echo ""
      }

      # Quick status check (minimal output for shell startup)
      dot-status-quick() {
          local dotfiles_dir="$HOME/.dotfiles"
          
          # Quick exit if no dotfiles or not git repo
          [[ ! -d "$dotfiles_dir/.git" ]] && return 0
          
          cd "$dotfiles_dir" || return 0
          
          # Quick fetch (with timeout)
          timeout 3 git fetch origin master 2>/dev/null || return 0
          
          local behind_count=$(git rev-list --count origin/master ^HEAD 2>/dev/null || echo "0")
          local uncommitted=$(git diff-index --quiet HEAD -- || echo "dirty")
          
          if [[ "$behind_count" -gt 0 ]]; then
              echo "dotfiles: $behind_count commits behind (dl)"
          elif [[ "$uncommitted" == "dirty" ]]; then
              echo "dotfiles: uncommitted changes (dp)"
          fi
      }
      
      # Short aliases
      alias dp='dot-push'
      alias dl='dot-pull'
      alias ds='dot-sync'
      alias dst='dot-status'
      
      # Run quick status check on shell startup (only for interactive shells)
      if [[ $- == *i* ]]; then
          dot-status-quick
      fi
    '';
  };
  environment.variables = {
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
  };
  environment.sessionVariables = {
    GOPATH = [ "$HOME/go" ];
  };
}
