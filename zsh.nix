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

    # Source secrets (API keys, etc.) - this file is NOT tracked in git
    if [[ -f "$HOME/.config/secrets/env" ]]; then
      source "$HOME/.config/secrets/env"
    fi

    # Auto-start tmux (only in interactive shells, not already in tmux)
    if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
      tmux attach-session -t default || tmux new-session -s default
    fi

    # Add Windows paths if not present
    if [[ ! "$PATH" =~ "/mnt/c/Windows" ]]; then
      export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"
    fi

    # Add bashScripts to PATH
    export PATH="$HOME/.bashScripts:$PATH"

    HISTFILE=~/.zsh_history
    HISTSIZE=10000
    SAVEHIST=10000
    setopt appendhistory
    setopt SHARE_HISTORY
    setopt HIST_EXPIRE_DUPS_FIRST
    setopt HIST_IGNORE_DUPS
    setopt HIST_FIND_NO_DUPS
    setopt HIST_REDUCE_BLANKS

    hyprctl() {
      if [[ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]] || ! [[ -S "$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket.sock" ]]; then
        export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ 2>/dev/null | head -n 1)
      fi
      command hyprctl "$@"
    }

    tmux-work() {
      local session_name="work"
    
      if [[ -z "$TMUX" ]]; then
        echo "Starting tmux work session..."
      fi
    
      if tmux has-session -t "$session_name" 2>/dev/null; then
        echo "Attaching to existing work session..."
        if [[ -n "$TMUX" ]]; then
          tmux switch-client -t "$session_name"
        else
          tmux attach-session -t "$session_name"
        fi
        return 0
      fi
    
      echo "Creating new work session..."
    
      # Determine if we're currently in tmux
      local in_tmux=""
      if [[ -n "$TMUX" ]]; then
        in_tmux="yes"
      fi
    
      # Create session with first window
      tmux new-session -d -s "$session_name"
      
      # Navigate to the directory for window 0
      tmux send-keys -t "$session_name:0" "cd $HOME/repos/cloudinaryFileSync/src" C-m
      
      # Rename window 0
      tmux rename-window -t "$session_name:0" "claude"
      
      # Enter nix-shell
      tmux send-keys -t "$session_name:0" "nix-shell" C-m
      
      # Wait a bit for nix-shell to load
      sleep 1
      
      # Run claude inside the nix-shell
      tmux send-keys -t "$session_name:0" "claude" C-m
    
      # Create second window
      tmux new-window -t "$session_name"
      
      # Navigate to directory for window 1
      tmux send-keys -t "$session_name:1" "cd $HOME/repos/cloudinaryFileSync/src/cloudinary-sync-files/templates" C-m
      
      # Rename window 1
      tmux rename-window -t "$session_name:1" "code"
    
      # Create third window
      tmux new-window -t "$session_name"
      
      # Navigate to directory for window 2
      tmux send-keys -t "$session_name:2" "cd $HOME/repos/cloudinaryFileSync/src/watcher" C-m
      
      # Rename window 2
      tmux rename-window -t "$session_name:2" "watcher"
    
      # Go back to window 0
      tmux select-window -t "$session_name:0"
    
    # If we were in tmux, add a small delay before switching
      if [[ -n "$in_tmux" ]]; then
        sleep 0.2
        tmux switch-client -t "$session_name"
      else
        tmux attach-session -t "$session_name"
      fi
    
      # Attach to the session
      if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session_name"
      else
        tmux attach-session -t "$session_name"
      fi
    }

    tmux-project() {
      local selected=$(find ~/repos -mindepth 1 -maxdepth 1 -type d | fzf)
      
      if [[ -z $selected ]]; then
        return 0
      fi
      
      local session_name=$(basename "$selected" | tr . _)
      
      if ! tmux has-session -t "$session_name" 2>/dev/null; then
        # Create new session
        tmux new-session -d -s "$session_name" -c "$selected"

        tmux rename-window -t "$session_name:0" "claude"
        tmux send-keys -t "$session_name:0" "cd $selected && nix-shell" C-m
        sleep 1
        tmux send-keys -t "$session_name:0" "claude" C-m
        
        tmux new-window -t "$session_name" -c "$selected"
        tmux rename-window -t "$session_name:1" "code"
        tmux send-keys -t "$session_name:1" "nvim ."
        
        tmux new-window -t "$session_name" -c "$selected"
        tmux rename-window -t "$session_name:2" "terminal"
        
        tmux new-window -t "$session_name" -c "$selected"
        tmux rename-window -t "$session_name:3" "db"
        tmux send-keys -t "$session_name:1" "nvim ."
        tmux send-keys -t "$session_name:1" ":DBUI"
        
        tmux select-window -t "$session_name:0"
      fi
      
      if [[ -n "$TMUX" ]]; then
        tmux switch-client -t "$session_name"
      else
        tmux attach-session -t "$session_name"
      fi
    }
      
      # Dotfiles sync functions
      dot-push() {
        echo "Syncing dotfiles from $(hostname)..."
        cd ~/.dotfiles || return 1
        stow -R * 2>/dev/null
        git add .
        git commit -m "sync: $(hostname) $(date '+%H:%M')" 2>/dev/null || echo "No changes to commit"
        git push origin master
        echo "Dotfiles pushed"
        cd ~
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
        cd ~
      }
      
      dot-sync() {
        dot-pull && dot-push
      }

      # Dotfiles status functions
      dot-status() {
        local dotfiles_dir="$HOME/.dotfiles"
        
        if [[ ! -d "$dotfiles_dir" ]]; then
          echo "dotfiles: directory not found at $dotfiles_dir"
          return 1
        fi
        
        cd "$dotfiles_dir" || return 1
        
        if [[ ! -d ".git" ]]; then
          echo "dotfiles: not a git repository"
          return 1
        fi
        
        echo "dotfiles: checking status..."
        
        git fetch origin master 2>/dev/null || {
          echo "dotfiles: could not fetch from remote"
          return 1
        }
        
        local has_uncommitted=""
        if ! git diff-index --quiet HEAD --; then
          has_uncommitted="yes"
        fi
        
        local has_untracked=""
        if [[ -n $(git ls-files --others --exclude-standard) ]]; then
          has_untracked="yes"
        fi
        
        local local_commit=$(git rev-parse HEAD)
        local remote_commit=$(git rev-parse origin/master 2>/dev/null)
        
        if [[ -z "$remote_commit" ]]; then
          echo "dotfiles: could not get remote commit info"
          return 1
        fi
        
        local ahead_count=$(git rev-list --count HEAD ^origin/master 2>/dev/null || echo "0")
        local behind_count=$(git rev-list --count origin/master ^HEAD 2>/dev/null || echo "0")
        
        if [[ "$local_commit" == "$remote_commit" ]]; then
          echo "dotfiles: up to date"
        elif (( behind_count > 0 && ahead_count == 0 )); then
          echo "dotfiles: behind by $behind_count commits (run 'dl')"
        elif (( ahead_count > 0 && behind_count == 0 )); then
          echo "dotfiles: ahead by $ahead_count commits (run 'dp')"
        elif (( ahead_count > 0 && behind_count > 0 )); then
          echo "dotfiles: diverged - $ahead_count ahead, $behind_count behind"
        fi
       
        if [[ -n "$has_uncommitted" ]]; then
          echo "dotfiles: uncommitted changes"
        fi
        
        if [[ -n "$has_untracked" ]]; then
          echo "dotfiles: untracked files"
        fi
        
        echo ""
        cd ~
      }


      nix-push() {
        echo "Syncing NixOS config from $(hostname)..."
        cd ~/nixos || return 1
        git add .
        git commit -m "sync: $(hostname) $(date '+%H:%M')" 2>/dev/null || echo "No changes to commit"
        git push origin master
        echo "NixOS config pushed"
        cd ~
      }

      nix-pull() {
        echo "Pulling NixOS config to $(hostname)..."
        cd ~/nixos || return 1
        git pull
        git add . 2>/dev/null
        git commit -m "adopt: $(hostname) $(date '+%H:%M')" 2>/dev/null || true
        git push origin master 2>/dev/null || true
        echo "NixOS config synced"
        cd ~
      }

      nix-sync() {
        nix-pull && nix-push
      }

      # NixOS status function
      nix-status() {
        local nixos_dir="$HOME/nixos"
        
        if [[ ! -d "$nixos_dir" ]]; then
          echo "nixos: directory not found at $nixos_dir"
          return 1
        fi
        
        cd "$nixos_dir" || return 1
        
        if [[ ! -d ".git" ]]; then
          echo "nixos: not a git repository"
          return 1
        fi
        
        echo "nixos: checking status..."
        
        git fetch origin master 2>/dev/null || {
          echo "nixos: could not fetch from remote"
          return 1
        }
        
        local has_uncommitted=""
        if ! git diff-index --quiet HEAD --; then
          has_uncommitted="yes"
        fi
        
        local has_untracked=""
        if [[ -n $(git ls-files --others --exclude-standard) ]]; then
          has_untracked="yes"
        fi
        
        local local_commit=$(git rev-parse HEAD)
        local remote_commit=$(git rev-parse origin/master 2>/dev/null)
        
        if [[ -z "$remote_commit" ]]; then
          echo "nixos: could not get remote commit info"
          return 1
        fi
        
        local ahead_count=$(git rev-list --count HEAD ^origin/master 2>/dev/null || echo "0")
        local behind_count=$(git rev-list --count origin/master ^HEAD 2>/dev/null || echo "0")
        
        if [[ "$local_commit" == "$remote_commit" ]]; then
          echo "nixos: up to date"
        elif (( behind_count > 0 && ahead_count == 0 )); then
          echo "nixos: behind by $behind_count commits (run 'nl')"
        elif (( ahead_count > 0 && behind_count == 0 )); then
          echo "nixos: ahead by $ahead_count commits (run 'np')"
        elif (( ahead_count > 0 && behind_count > 0 )); then
          echo "nixos: diverged - $ahead_count ahead, $behind_count behind"
        fi
        
        if [[ -n "$has_uncommitted" ]]; then
          echo "nixos: uncommitted changes"
        fi
        
        if [[ -n "$has_untracked" ]]; then
          echo "nixos: untracked files"
        fi
        
        echo ""
        cd ~
      }

      # Short aliases
      alias np='nix-push'
      alias nl='nix-pull'
      alias ns='nix-sync'
      alias nst='nix-status'

      # dotfile aliases
      alias dp='dot-push'
      alias dl='dot-pull'
      alias ds='dot-sync'
      alias dst='dot-status'

      # tmux session management aliases
      alias tw='tmux-work' 
      alias tp='tmux-project'


      
      # Run status checks on shell startup (only for interactive shells inside tmux)
      if [[ $- == *i* ]] && [[ -n "$TMUX" ]] && [[ "$(tmux display-message -p '#S')" == "default" ]]; then
        clear
        nix-status
        dot-status
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
