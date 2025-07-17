this is my configuration for nixos.

NEW MACHINE?

    get nixos either on wsl, or native.
    
    name the user 'emerald', this is important.
    
    install git
    
    cd ~
    
    setup ssh authentication for github
    
    git clone nixos repo via ssh

    git clone .dotfiles repo via ssh

    sudo nixos-rebuild switch


COMMANDS:
    sudo nixos-rebuild switch : rebuild the OS, if we fail, revert. If success, switch to updated env.


HOW IT WORKS:

currently configured to run on 2 environments:

    1. NixOS (natively)

    2. Windows(in WSL)

configuration.nix :
    this is a configuration file for nix, and tells nix what packages and software to use across ALL environments.

native.nix
    this is an extension of the configuration.nix file, but only runs when on a NixOS linux environment natively.

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
    generated hardware file for our currently only natively-running devices, my home PC, and personal laptop
