if status is-interactive
    # Disable default greeting
    set fish_greeting

    # Initialize starship, zoxide, fzf if they exist
    if type -q starship
        starship init fish | source
    end
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q fzf
        fzf --fish | source 2>/dev/null
    end
end
