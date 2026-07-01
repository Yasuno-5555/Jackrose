set -gx TERMINAL ghostty
set -gx EDITOR vi
set -gx VISUAL $EDITOR
set -gx STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
fish_add_path -g "$HOME/.local/bin"

if status is-interactive
    set fish_greeting

    if not test -f "$HOME/.config/jackrose/welcome/seen"
        if type -q jackrose-welcome
            jackrose-welcome
            mkdir -p "$HOME/.config/jackrose/welcome"
            touch "$HOME/.config/jackrose/welcome/seen"
        end
    end

    if type -q starship
        starship init fish | source
    else
        function fish_prompt
            set -l last_status $status
            set_color cba6f7
            prompt_pwd
            set_color normal
            if test $last_status -ne 0
                set_color f38ba8
                printf ' %s' $last_status
                set_color normal
            end
            printf ' ❯ '
        end
    end

    if type -q zoxide
        zoxide init fish | source
    end

    if type -q fzf
        fzf --fish | source 2>/dev/null
    end

    abbr -q ll; or abbr -a ll 'ls -lh'
    abbr -q la; or abbr -a la 'ls -lha'
    if type -q bat
        abbr -q cat; or abbr -a cat 'bat'
    end
end
