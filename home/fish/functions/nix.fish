{}: ''

function nix -d 'overloaded nix cli'

    # check whether the workspace uses flake
    if command nix flake metadata &> /dev/null
        # if the workspace uses flake,
        # and git status is dirty
        if [ -n "$( git status --porcelain 2> /dev/null )" ]
            # intent-to-add all
            git add --all --intent-to-add
        end
    end

    command nix $argv

end

''
