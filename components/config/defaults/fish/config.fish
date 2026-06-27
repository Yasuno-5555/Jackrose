if status is-interactive
    # Disable default greeting
    set fish_greeting

    # Show welcome dialog on first shell launch
    if not test -f ~/.config/cidre-welcome-done
        if type -q cidre-welcome
            cidre-welcome
            touch ~/.config/cidre-welcome-done
        end
    end

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
