#
# Copied from https://github.com/jhillyerd/plugin-git
#

abbr -a g 'git'

abbr -a ga   "git add"
abbr -a gaa  "git add --all"
abbr -a gau  "git add --update"
abbr -a gapa "git add --patch"
abbr -a gan  "git add --intent-to-add"

abbr -a gap "git apply"

abbr -a gbl "git blame -w"

abbr -a gb   "git branch -vv"
abbr -a gba  "git branch -av"
abbr -a gban "git branch -av --no-merged"
abbr -a gbd  "git branch -d"
abbr -a gbD  "git branch -D"

abbr -a gbs "git bisect"
abbr -a gbsb "git bisect bad"
abbr -a gbsg "git bisect good"
abbr -a gbsr "git bisect reset"
abbr -a gbss "git bisect start"

abbr -a gc    "git commit -v"
abbr -a gc!   "git commit -v --amend"
abbr -a gcn!  "git commit -v --no-edit --amend"
abbr -a gca   "git commit -v -a"
abbr -a gca!  "git commit -v -a --amend"
abbr -a gcan! "git commit -v -a --no-edit --amend"
abbr -a gcm   "git commit -m"
abbr -a gcam  "git commit -a -m"
abbr -a gcfx  "git commit --fixup"

abbr -a gcl  "git clone"
abbr -a gcl1 "git clone --depth 1"

abbr -a gcount "git shortlog -sn"

abbr -a gclean   "git clean -di"
abbr -a gclean!  "git clean -dfx"
abbr -a gclean!! "git reset --hard && git clean -dfx";

abbr -a gcp  "git cherry-pick"
abbr -a gcpa "git cherry-pick --abort"
abbr -a gcpc "git cherry-pick --continue"

abbr -a gd   "git diff"
abbr -a gda  "git diff --cached"
abbr -a gds  "git diff --stat"
abbr -a gdsa "git diff --stat --cached"
abbr -a gdw  "git diff --word-diff"
abbr -a gdwa "git diff --word-diff --cached"

abbr -a gignore   "git update-index --assume-unchanged"
abbr -a gunignore "git update-index --no-assume-unchanged"

abbr -a gf  "git fetch"
abbr -a gfa "git fetch --all --prune"

abbr -a gl  "git pull"
abbr -a glr "git pull --rebase"

abbr -a glg   "git log --stat --max-count=10"
abbr -a glgg  "git log --graph --max-count=10"
abbr -a glgga "git log --graph --decorate --all"
abbr -a glo   "git log --oneline --decorate --color"
abbr -a glog  "git log --oneline --decorate --color --graph"
abbr -a gloo  "git log --pretty=format:'%C(yellow)%h %Cred%ad %Cblue%an%Cgreen%d %Creset%s' --date=short"

abbr -a gm  "git merge"
abbr -a gmt "git mergetool --no-prompt"

abbr -a gp   "git push"
abbr -a gp!  "git push --force-with-lease"
abbr -a gpv  "git push --no-verify"
abbr -a gpv! "git push --no-verify --force-with-lease"
abbr -a gpa  "parallel git push --all -- (git remote)"
abbr -a gpa! "parallel git push --all --force -- (git remote)"

abbr -a gr   "git remote -vv"
abbr -a gra  "git remote add"
abbr -a grup "git remote update"

abbr -a grb  "git rebase"
abbr -a grba "git rebase --abort"
abbr -a grbc "git rebase --continue"
abbr -a grbi "git rebase --interactive"

abbr -a grev "git revert"

abbr -a grst "git reset"
abbr -a grsth "git reset --hard"
abbr -a grstp "git reset --patch"

abbr -a grm  "git rm"
abbr -a grmc "git rm --cached"

abbr -a grs  "git restore"
abbr -a grss "git restore --source"

abbr -a gs "git show"

abbr -a gss "git status -s"
abbr -a gS "git status -s"

abbr -a gsta "git stash"
#abbr -g gstd "git stash drop"
abbr -a gstp "git stash pop"
abbr -a gsts "git stash show --text"

abbr -a gts "git tag -s"
abbr -a gtv "git tag | sort -V"

abbr -a gsw  "git switch"
abbr -a gswc "git switch --create"

abbr -a gco "git checkout"
abbr -a gcb "git checkout -b"
