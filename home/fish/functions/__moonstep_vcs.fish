# TODO: implement merge/rebase indicator

function __moonstep_vcs

    # Colocated repos have both .jj/ and .git/; jj is the source of
    # truth there, so probe jj first.
    if command jj root --ignore-working-copy 2>/dev/null >/dev/null
        __moonstep_jujutsu
    else if command git rev-parse --absolute-git-dir 2>/dev/null >/dev/null
        __moonstep_git
    end

end

#
# Git implementation
#

function __moonstep_git

    __moonstep_git_branch

    # `read -l`, never `-lz`: NUL-delimited reads of a function pipe
    # gain a spurious trailing newline, pushing the status to a new line.
    __moonstep_git_status | read -l status_output
    test -n "$status_output"
    and printf ' %s' $status_output

end

function __moonstep_git_branch
    # -f strips git's trailing newline; -fz would add one back.
    command git branch --show-current 2>/dev/null \
        | read -f branch
    printf '%s' (set_color bryellow)"$branch"
end

# Renders the git status indicators (stash/conflict/staged/dirty/
# untracked/behind/ahead) joined by spaces.
# Adapted from tide.fish's _tide_item_git.fish.
#
# Porcelain v1: column 1 is the index, column 2 the working tree, and
# "." means a space — hence `^[ADMR]` matches staged and `^.[ADMR]`
# dirty.
function __moonstep_git_status
    set -f reset (set_color reset)
    set -f git_cmd git --no-optional-locks

    set -f git_status (
        command $git_cmd status --porcelain=v1 2>/dev/null
    )

    # `--left-right` emits "<behind>\t<ahead>"
    set -f behind_ahead (
        git rev-list --count \
            --left-right "@{upstream}...HEAD" \
            2>/dev/null \
            | string split --no-empty \t)

    set -f rendered

    # stash
    set -l n (command $git_cmd stash list 2>/dev/null | count)
    test "$n" -gt 0
    and set --append rendered (set_color brmagenta)"Stash $n$reset"

    # conflict
    set -l n (string match -r '^(DD|AU|UD|UA|DU|AA|UU)' $git_status | count)
    test "$n" -gt 0
    and set --append rendered (set_color brred)"!!$n$reset"

    # staged
    set -l n (string match -r '^[ADMR]' $git_status | count)
    test "$n" -gt 0
    and set --append rendered (set_color brgreen)"+$n$reset"

    # dirty
    set -l n (string match -r '^.[ADMR]' $git_status | count)
    test "$n" -gt 0
    and set --append rendered (set_color bryellow)"~$n$reset"

    # untracked
    set -l n (string match -r '^\?\?' $git_status | count)
    test "$n" -gt 0
    and set --append rendered (set_color brblue)"?$n$reset"

    # behind / ahead
    if test (count $behind_ahead) -ge 1
        set -l n $behind_ahead[1]
        test "$n" -gt 0
        and set --append rendered (set_color cyan)"Behind $n$reset"
    end
    if test (count $behind_ahead) -ge 2
        set -l n $behind_ahead[2]
        test "$n" -gt 0
        and set --append rendered (set_color cyan)"Ahead $n$reset"
    end

    printf '%s' (string join ' ' $rendered)

end

#
# Jujutsu implementation
#
# All prompt data comes from one `jj log` subprocess: a revset selects
# @, trunk(), and the commits between them; a template tags each line
# with its role (AT/TRUNK/AHEAD/BEHIND) and emits tab-separated fields.
#
# Field layout (tab-separated, role-prefixed):
#   AT      change_id  bookmarks  conflict  divergent  empty  immutable  modified  added  deleted  conflicted_files
#   TRUNK   bookmark_names  is_root
#   AHEAD   (no fields — counted by line)
#   BEHIND  (no fields — counted by line)
#
# jj only sees working-tree changes by snapshotting them into @, so
# the query runs without --ignore-working-copy: one snapshot per
# prompt cycle keeps the file stats current. Output is --color=never;
# moonstep colors are applied fish-side.

function __moonstep_jujutsu

    # change ID / bookmarks — output flows directly to stdout
    __moonstep_jj_id

    # various status indicators
    __moonstep_jj_status | read -l status_output
    test -n "$status_output"
    and printf ' %s' $status_output

end

# Emits @'s bookmarks (or change ID if unbookmarked) plus ahead/
# behind counts vs trunk(). Runs the query and caches its output in
# the global $__moonstep_jj_raw for __moonstep_jj_status — a global,
# not a -f local, because sibling functions can't see each other's
# locals.
function __moonstep_jj_id
    # -lz: capture the multi-line output as one string
    __moonstep_jj_query | read -lz raw
    set -g __moonstep_jj_raw $raw

    set -f reset (set_color reset)

    set -f change_id
    set -f bookmarks
    set -f ahead 0
    set -f behind 0
    set -f trunk_ok 0

    for line in (string split --no-empty \n -- $__moonstep_jj_raw)
        set -f parts (string split \t -- $line)
        switch $parts[1]
            case AT
                set change_id $parts[2]
                set bookmarks $parts[3]
            case TRUNK
                # is_root=1 → trunk() fell back to root(): no upstream
                # resolved, and ahead/behind would count all of history.
                test $parts[3] = 0; and set trunk_ok 1
            case AHEAD
                set ahead (math $ahead + 1)
            case BEHIND
                set behind (math $behind + 1)
        end
    end

    # A bookmark subsumes the change ID when @ carries one.
    if test -n "$bookmarks"
        printf '%s' (set_color bryellow)"$bookmarks"
    else
        printf '%s' (set_color bryellow)"$change_id"
    end

    # only meaningful when trunk() resolved (see the TRUNK case)
    test "$trunk_ok" = 1; and test "$ahead" -gt 0
    and printf ' %s' (set_color cyan)"Ahead $ahead$reset"
    test "$trunk_ok" = 1; and test "$behind" -gt 0
    and printf ' %s' (set_color cyan)"Behind $behind$reset"

end

# Renders @'s status indicators (conflict/divergent/empty/immutable/
# modified/added/deleted) joined by spaces. Consumes the
# $__moonstep_jj_raw cache; runs the query itself only when the cache
# is empty.
function __moonstep_jj_status
    set -f reset (set_color reset)

    if not set -q __moonstep_jj_raw[1]
        __moonstep_jj_query | read -lz raw
        set __moonstep_jj_raw $raw
    end

    set -f conflict 0
    set -f divergent 0
    set -f empty 0
    set -f immutable 0
    set -f modified 0
    set -f added 0
    set -f deleted 0
    set -f conflicted_files 0

    for line in (string split --no-empty \n -- $__moonstep_jj_raw)
        set -f parts (string split \t -- $line)
        if test "$parts[1]" = AT
            test "$parts[4]" = 1; and set conflict 1
            test "$parts[5]" = 1; and set divergent 1
            test "$parts[6]" = 1; and set empty 1
            test "$parts[7]" = 1; and set immutable 1
            set modified $parts[8]
            set added $parts[9]
            set deleted $parts[10]
            set conflicted_files $parts[11]
            break
        end
    end

    set -f rendered

    test "$conflict" -eq 1
    and set --append rendered (set_color brred)"!!$reset"
    test "$conflict" -eq 1; and test "$conflicted_files" -gt 0
    and set --append rendered (set_color brred)"C$conflicted_files$reset"

    # divergent (same change ID, multiple commits)
    test "$divergent" -eq 1
    and set --append rendered (set_color brred)"?$reset"

    # empty (no file changes in @)
    test "$empty" -eq 1
    and set --append rendered (set_color brblack)"(empty)$reset"

    # immutable (on a commit that can't be rewritten)
    test "$immutable" -eq 1
    and set --append rendered (set_color brblue)"◆$reset"

    test "$modified" -gt 0
    and set --append rendered (set_color bryellow)"~$modified$reset"

    test "$added" -gt 0
    and set --append rendered (set_color brgreen)"+$added$reset"

    test "$deleted" -gt 0
    and set --append rendered (set_color brred)"-$deleted$reset"

    printf '%s' (string join ' ' $rendered)

end

# The single `jj log` subprocess behind the jj prompt; revset and
# template follow the field layout in the section header above.
function __moonstep_jj_query
    # `concat` (not `separate`) preserves empty fields — `separate`
    # collapses empty middle arguments, losing tab boundaries and
    # shifting all subsequent field indices.
    command jj log --no-graph --no-pager \
        --color=never \
        -r '@ | trunk() | trunk()..@ | (::trunk() & ~::@)' \
        -T '
            if(self.contained_in("@"),
                concat("AT",
                    "\t", change_id.shortest(),
                    "\t", local_bookmarks.join(","),
                    "\t", if(conflict, "1", "0"),
                    "\t", if(divergent, "1", "0"),
                    "\t", if(empty, "1", "0"),
                    "\t", if(immutable, "1", "0"),
                    "\t", self.diff().files().filter(|f| f.status_char() == "M").len(),
                    "\t", self.diff().files().filter(|f| f.status_char() == "A").len(),
                    "\t", self.diff().files().filter(|f| f.status_char() == "D").len(),
                    "\t", self.conflicted_files().len()
                ),
                if(self.contained_in("trunk()"),
                    concat("TRUNK",
                        "\t", self.bookmarks().map(|b| b.name()).join(","),
                        "\t", if(self.root(), "1", "0")
                    ),
                    if(self.contained_in("::trunk() & ~::@"),
                        "BEHIND",
                        "AHEAD"
                    )
                )
            ) ++ "\n"
        ' 2>/dev/null
end
