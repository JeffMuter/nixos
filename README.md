this is my configuration for nixos.

NEW MACHINE?

    see NEW-MACHINE.md - one command (run twice), one GitHub login, one passphrase.


COMMANDS:
    sudo nixos-rebuild switch : rebuild the OS for this machine's hostname (flake.nix), pinned by flake.lock.


HOW IT WORKS:

flake.nix defines one entry per machine (named after its hostname):

    1. emerald      - NixOS natively (desktop)

    2. emerald-work - Windows (in WSL)

configuration.nix :
    this is a configuration file for nix, and tells nix what packages and software to use across ALL environments.

native-hyperland.nix
    this is an extension of the configuration.nix file, used by the native host.

wsl.nix
    same as before. This extends WSL, and has configuration details that only apply in a WSL environment.

zsh.nix
    we use zsh because of the hilarious amount of great plugins in that ecosystem to make
    being a developer a lot easier in general. one thing in particular we have is a massive amount of plugins that
    I have hand-picked for what I like, and works for me. Yes, I spent days reading documentation on each of them.
    This ends up being the most convenient/consistent place (for me) to configure zsh. 
    Zsh also has a few commands I've added over time, such as, when new shells open, we check the status of nixos
    & dotfiles repos in the ~ directory, as keeping machines in sync is important.

hardware-configuration.nix
    generated hardware file for our currently only natively-running devices, my home PC
