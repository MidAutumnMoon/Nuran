{ programs.fish = {

    interactiveShellInit = /* fish */ ''
        # Tell Windows Terminal to open new tabs with the same CWD
        function __windows_terminal --on-variable PWD
            set -q WT_SESSION
            and printf "\e]9;9;%s\e\\" ( wslpath -w "$PWD" )
        end
    '';

    # Stock "open" doesn't uses wsl-open, which makes it useless
    # on WSL.
    functions."open" = /* fish */ ''
        command wsl-open $argv
    '';

}; }
