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
      zk-pri = "zk-prioritize";
      tmux-snap = "bash ~/.bashScripts/tmux-snap";
    };

    shellInit = ''
      claude() { env -u ANTHROPIC_API_KEY /home/emerald/.npm-global/bin/claude "$@"; }
    '';

    histSize = 10000;
    histFile = "$HOME/.zsh_history";
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    interactiveShellInit = ''

    eval "$(pay-respects zsh)"

    # Source secrets (API keys, etc.) - this file is NOT tracked in git
    if [[ -f "$HOME/.config/secrets/env" ]]; then
      source "$HOME/.config/secrets/env"
    fi

    # Attach to the systemd-managed tmux server (started/restored by continuum
    # via tmux.service). Right after boot the unit may still be starting, so
    # retry briefly before falling back to creating our own session - this
    # avoids racing tmux.service into a duplicate/split-brain session.
    if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
      tmux attach-session -t default 2>/dev/null \
        || { sleep 0.3; tmux attach-session -t default 2>/dev/null; } \
        || { sleep 0.6; tmux attach-session -t default 2>/dev/null; } \
        || tmux new-session -s default
    fi

    # Add Windows paths if not present
    if [[ ! "$PATH" =~ "/mnt/c/Windows" ]]; then
      export PATH="$PATH:/mnt/c/Windows/System32:/mnt/c/Windows"
    fi

    # Add bashScripts, local bins (zk-daily etc.), and npm-global bins to PATH
    export PATH="$HOME/.bashScripts:$PATH"
    export PATH="$HOME/.local/bin:$PATH"
    export PATH="$HOME/.npm-global/bin:$PATH"

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
        if git push origin master; then
          echo "Dotfiles pushed"
        else
          echo "ERROR: dotfiles push failed — run 'dst' to check status"
          cd ~
          return 1
        fi
        cd ~
      }

      dot-pull() {
        echo "Pulling dotfiles to $(hostname)..."
        cd ~/.dotfiles || return 1
        if ! git pull; then
          echo "ERROR: dotfiles pull failed — branches may have diverged, resolve manually"
          cd ~
          return 1
        fi
        stow -R * --adopt 2>/dev/null
        git add . 2>/dev/null
        git commit -m "adopt: $(hostname) $(date '+%H:%M')" 2>/dev/null || true
        if ! git push origin master 2>/dev/null; then
          echo "WARNING: push after adopt failed — run 'dp' to retry"
        fi
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
        
        git fetch origin 2>/dev/null || {
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
        if git push origin master; then
          echo "NixOS config pushed"
        else
          echo "ERROR: nixos push failed — run 'nst' to check status"
          cd ~
          return 1
        fi
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

      # tmux session management aliases
      alias tw='tmux-work'
      alias tp='tmux-project'

      _shell_greeting() {
        [[ -r "$HOME/.config/shell-theme/colors.sh" ]] && source "$HOME/.config/shell-theme/colors.sh"
        local hour=$(date +%H)
        local greeting="good morning"
        [[ $hour -ge 12 ]] && greeting="good afternoon"
        [[ $hour -ge 17 ]] && greeting="good evening"
        local cl=$'\e[1;38;5;147m'; [[ -n "$_TH_ACCENT" ]] && cl=$_TH_ACCENT
        local cd=$'\e[38;5;242m';   [[ -n "$_TH_MUTED" ]]  && cd=$_TH_MUTED
        local R=$'\e[0m'
        printf "\n  $cl%-26s$R  $cd%s$R\n" "$greeting, emerald" "$(date '+%a %b %d  %H:%M')"
      }

      _rse_display() {
        local cache="$HOME/.cache/rse-repos"
        [[ ! -f "$cache" ]] && rse-git && return

        [[ -r "$HOME/.config/shell-theme/colors.sh" ]] && source "$HOME/.config/shell-theme/colors.sh"
        local cb=$'\e[38;5;45m';    [[ -n "$_TH_BORDER" ]] && cb=$_TH_BORDER
        local cl=$'\e[1;38;5;147m'; [[ -n "$_TH_ACCENT" ]] && cl=$_TH_ACCENT
        local cn=$'\e[38;5;242m';   [[ -n "$_TH_MUTED" ]]  && cn=$_TH_MUTED
        local cw=$'\e[38;5;253m';   [[ -n "$_TH_TEXT" ]]   && cw=$_TH_TEXT
        local cg=$'\e[38;5;82m';    [[ -n "$_TH_OK" ]]     && cg=$_TH_OK
        local cy=$'\e[38;5;220m';   [[ -n "$_TH_WARN" ]]   && cy=$_TH_WARN
        local cr=$'\e[38;5;203m';   [[ -n "$_TH_DIRTY" ]]  && cr=$_TH_DIRTY
        local R=$'\e[0m'
        local tmpdir="/tmp/.rse-$$"
        mkdir -p "$tmpdir"

        printf "\n $cb╭─$cl repos $cb─────────────────────────────────────╮$R\n"

        setopt LOCAL_OPTIONS NO_MONITOR
        while IFS=" " read -r i repo; do
          {
            local rname=$(basename "$repo")
            local sb=$(git -C "$repo" status -sb 2>/dev/null)
            local dirty=""
            { echo "$sb" | tail -n +2 | grep -q "^[^?]" || echo "$sb" | grep -q "^??"; } && dirty="*"
            local rahead=$(echo "$sb" | head -1 | grep -o 'ahead [0-9]*' | grep -o '[0-9]*')
            local rbehind=$(echo "$sb" | head -1 | grep -o 'behind [0-9]*' | grep -o '[0-9]*')
            local flags=""
            [[ -n "$rahead" && $rahead -gt 0 ]] && flags="$flags↑$rahead "
            [[ -n "$rbehind" && $rbehind -gt 0 ]] && flags="$flags↓$rbehind "
            [[ -n "$dirty" ]] && flags="$flags*"
            flags=''${flags% }
            local rcolor=$cg rsymbol="✓"
            if [[ -n "$flags" ]]; then
              [[ "$flags" == *"*"* ]] && rcolor=$cr || rcolor=$cy
              rsymbol=$flags
            fi
            printf " $cb│$R $cn%2d$R  $cw%-24s$R  $rcolor%-14s$R$cb│$R\n" \
              "$i" "$rname" "$rsymbol"
          } > "$tmpdir/$(printf '%05d' $i)" &
        done < "$cache"
        wait
        cat "$tmpdir"/* 2>/dev/null
        rm -rf "$tmpdir"

        printf " $cb╰─────────────────────────────────────────────╯$R\n"
        printf "   r <n>  $cb%s$R fetch  $cb%s$R pull  $cb%s$R sync\n\n" f l s
      }

      rse-git() {
        local cache="$HOME/.cache/rse-repos"
        local repos=()

        [[ -d "$HOME/nixos/.git" ]] && repos+=("$HOME/nixos")
        [[ -d "$HOME/.dotfiles/.git" ]] && repos+=("$HOME/.dotfiles")
        for d in "$HOME/repos"/*(/N); do
          [[ -d "$d/.git" ]] && repos+=("$d")
        done

        mkdir -p "$HOME/.cache"
        : > "$cache"
        local i=1
        for repo in $repos; do
          echo "$i $repo" >> "$cache"
          (( i++ ))
        done

        _rse_display
      }

      r() {
        local cache="$HOME/.cache/rse-repos"
        [[ ! -f "$cache" ]] && echo "r: run rse-git first" && return 1

        if [[ "$1" == "f" && -z "$2" ]]; then
          while IFS=" " read -r num repopath; do
            printf "  fetching %-22s" "$(basename $repopath)..."
            git -C "$repopath" fetch origin 2>/dev/null && echo "✓" || echo "✗"
          done < "$cache"
          _rse_display
          return
        fi

        if [[ "$1" == "s" && -z "$2" ]]; then
          while IFS=" " read -r num repopath; do
            local rname=$(basename "$repopath")
            printf "  syncing %-23s" "$rname..."
            local porcelain=$(git -C "$repopath" status --porcelain 2>/dev/null)
            if [[ -n "$porcelain" ]]; then
              git -C "$repopath" add .
              local msg=$(git -C "$repopath" diff --cached | claude -p "One-line git commit message, no quotes:" 2>/dev/null)
              [[ -z "$msg" ]] && msg="sync: $(hostname) $(date '+%H:%M')"
              git -C "$repopath" commit -q -m "$msg"
            fi
            git -C "$repopath" rebase --abort 2>/dev/null; git -C "$repopath" merge --abort 2>/dev/null; true
            git -C "$repopath" pull -q || { echo "✗ (pull failed)"; continue; }
            local syncahead=$(git -C "$repopath" rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")
            (( syncahead > 0 )) && git -C "$repopath" push -q
            echo "✓"
          done < "$cache"
          _rse_display
          return
        fi

        local num="$1" cmd="$2"
        local repopath=$(awk -v n="$num" '$1==n {print $2}' "$cache")
        [[ -z "$repopath" ]] && echo "r: no repo $num — run rse-git to refresh" && return 1
        local reponame=$(basename "$repopath")

        case "$cmd" in
          f)
            printf "fetching %s... " "$reponame"
            git -C "$repopath" fetch origin 2>/dev/null && echo "✓" || echo "✗"
            rse-git
            ;;
          l)
            echo "pulling $reponame..."
            git -C "$repopath" pull
            rse-git
            ;;
          s)
            echo "syncing $reponame..."
            local porcelain=$(git -C "$repopath" status --porcelain 2>/dev/null)
            if [[ -n "$porcelain" ]]; then
              git -C "$repopath" add .
              local msg=$(git -C "$repopath" diff --cached | claude -p "One-line git commit message, no quotes:" 2>/dev/null)
              [[ -z "$msg" ]] && msg="sync: $(hostname) $(date '+%H:%M')"
              git -C "$repopath" commit -m "$msg"
            fi
            git -C "$repopath" rebase --abort 2>/dev/null; git -C "$repopath" merge --abort 2>/dev/null; true
            git -C "$repopath" pull || return 1
            local syncahead=$(git -C "$repopath" rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")
            (( syncahead > 0 )) && git -C "$repopath" push
            rse-git
            ;;
          *)
            echo "r: use f, l, or s"
            ;;
        esac
      }

      # Run status checks on shell startup (only for interactive shells inside tmux)
      if [[ $- == *i* ]] && [[ -n "$TMUX" ]]; then
        clear
        _shell_greeting
        _rse_display
      fi
    '';
  };
  environment.variables = {
    ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE = "20";
    COLORTERM = "truecolor";
  };
  environment.sessionVariables = {
    GOPATH = [ "$HOME/go" ];
    ZK_NOTEBOOK_DIR = "$HOME/repos/notes";
  };
}
