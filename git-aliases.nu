### MODULE FUNCTIONS
# git repository check
def is_git_repo [] {
    let git_check = git rev-parse --is-inside-work-tree | complete | get exit_code
    if $git_check != 0 {
        print "Not a git repository"
    }
    $git_check == 0
}
# get develop branch, fallback to develop
def git_develop_branch [] {
    if (is_git_repo) == false {
        return
    }
    let branches = ["dev", "devel", "develop", "development"]
    for $branch in $branches {
        if (git show-ref -q --verify refs/heads/$branch | complete | get exit_code) == 0 {
            return $branch
        }
    }
    return develop
}
# Check if main exists and use instead of master, fallback to master
def git_main_branch [] {
    if (is_git_repo) == false {
        return
    }
    let $refs = ["heads", "remotes/origin", "remotes/upstream"]
    let $branches = ["main", "trunk", "mainline", "default", "stable", "master"]
    for $ref in $refs {
        for $branch in $branches {
            let $full_ref = $"refs/($ref)/($branch)"
            if (git show-ref -q --verify $full_ref | complete | get exit_code) == 0 {
                return $branch
            }
        }
    }
    return master
}
def git_current_branch [] {
    $env.GIT_OPTIONAL_LOCKS = 0
    mut ref = (git symbolic-ref --quiet HEAD | complete)
    if $ref.exit_code == 128 {
        return
    } else if $ref.exit_code != 0 {
        $ref = (git rev-parse --short HEAD | complete)
    }
    $ref.stdout | str replace -r '^refs/heads/' '' | str trim
}
# Pretty log messages
def _git_log_prettily [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args != "" {
        git log --pretty=$args
    }
}

### ALIASES
export alias g = git
export alias ga = git add
export alias gaa = git add --all
export alias gam = git am
export alias gama = git am --abort
export alias gamc = git am --continue
export alias gams = git am --skip
export alias gamscp = git am --show-current-patch
export alias gap = git apply
export alias gapa = git add --patch
export alias gapt = git apply --3way
export alias gau = git add --update
export alias gav = git add --verbose
export alias gb = git branch
export alias gbD = git branch --delete --force
export alias gba = git branch --all
export alias gbd = git branch --delete
export alias gbl = git blame -w
export alias gbm = git branch --move
export alias gbnm = git branch --no-merged
export alias gbr = git branch --remote
export alias gbs = git bisect
export alias gbsb = git bisect bad
export alias gbsg = git bisect good
export alias gbsn = git bisect new
export alias gbso = git bisect old
export alias gbsr = git bisect reset
export alias gbss = git bisect start
export alias gc = git commit --verbose
export alias gc! = git commit --verbose --amend
export alias gcB = git checkout -B
export alias gca = git commit --verbose --all
export alias gca! = git commit --verbose --all --amend
export alias gcam = git commit --all --message
export alias gcan! = git commit --verbose --all --no-edit --amend
export alias gcann! = git commit --verbose --all --date=now --no-edit --amend
export alias gcans! = git commit --verbose --all --signoff --no-edit --amend
export alias gcas = git commit --all --signoff
export alias gcasm = git commit --all --signoff --message
export alias gcb = git checkout -b
export alias gcd = git checkout (git_develop_branch)
export alias gcf = git config --list
export alias gcl = git clone --recurse-submodules
export alias gclean = git clean --interactive -d
export alias gclf = git clone --recursive --shallow-submodules --filter=blob:none --also-filter-submodules
export alias gcm = git checkout (git_main_branch)
export alias gcmsg = git commit --message
export alias gcn! = git commit --verbose --no-edit --amend
export alias gco = git checkout
export alias gcor = git checkout --recurse-submodules
export alias gcount = git shortlog --summary --numbered
export alias gcp = git cherry-pick
export alias gcpa = git cherry-pick --abort
export alias gcpc = git cherry-pick --continue
export alias gcs = git commit --gpg-sign
export alias gcsm = git commit --signoff --message
export alias gcss = git commit --gpg-sign --signoff
export alias gcssm = git commit --gpg-sign --signoff --message
export alias gd = git diff
export alias gdca = git diff --cached
export alias gdct = git describe --tags (git rev-list --tags --max-count=1)
export alias gdcw = git diff --cached --word-diff
export alias gds = git diff --staged
export alias gdt = git diff-tree --no-commit-id --name-only -r
export alias gdup = git diff @{upstream}
export alias gdw = git diff --word-diff
export alias gf = git fetch
export alias gfa = git fetch --all --tags --prune --jobs=10
export alias gfg = git ls-files | grep
export alias gfo = git fetch origin
export alias gga = git gui citool --amend
export alias ggc = git gui citool
export alias ggpull = git pull origin (git_current_branch)
export alias ggpush = git push origin (git_current_branch)
export alias ggsup = git branch --set-upstream-to=origin/(git_current_branch)
export alias ghh = git help
export alias gignore = git update-index --assume-unchanged
export alias gignored = git ls-files -v | grep "^[[:lower:]]"
export alias gk = gitk --all --branches &!
export alias gke = gitk --all (git log --walk-reflogs --pretty=%h) &!
export alias gl = git pull
export alias glg = git log --stat
export alias glgg = git log --graph
export alias glgga = git log --graph --decorate --all
export alias glgm = git log --graph --max-count=10
export alias glgp = git log --stat --patch
export alias glo = git log --oneline --decorate
export alias glod = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset'
export alias glods = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short
export alias glog = git log --oneline --decorate --graph
export alias gloga = git log --oneline --decorate --graph --all
export alias glol = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'
export alias glola = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all
export alias glols = git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --stat
export alias glp = _git_log_prettily
export alias gluc = git pull upstream (git_current_branch)
export alias glum = git pull upstream (git_main_branch)
export alias gm = git merge
export alias gma = git merge --abort
export alias gmc = git merge --continue
export alias gmff = git merge --ff-only
export alias gmom = git merge origin/(git_main_branch)
export alias gms = git merge --squash
export alias gmtl = git mergetool --no-prompt
export alias gmtlvim = git mergetool --no-prompt --tool=vimdiff
export alias gmum = git merge upstream/(git_main_branch)
export alias gp = git push
export alias gpd = git push --dry-run
export alias gpf = git push --force-with-lease --force-if-includes
export alias gpf! = git push --force
export alias gpod = git push origin --delete
export alias gpr = git pull --rebase
export alias gpra = git pull --rebase --autostash
export alias gprav = git pull --rebase --autostash -v
export alias gprom = git pull --rebase origin (git_main_branch)
export alias gpromi = git pull --rebase=interactive origin (git_main_branch)
export alias gprum = git pull --rebase upstream (git_main_branch)
export alias gprumi = git pull --rebase=interactive upstream (git_main_branch)
export alias gprv = git pull --rebase -v
export alias gpsup = git push --set-upstream origin (git_current_branch)
export alias gpsupf = git push --set-upstream origin (git_current_branch) --force-with-lease --force-if-includes
export alias gpu = git push upstream
export alias gpv = git push --verbose
export alias gr = git remote
export alias gra = git remote add
export alias grb = git rebase
export alias grba = git rebase --abort
export alias grbc = git rebase --continue
export alias grbd = git rebase (git_develop_branch)
export alias grbi = git rebase --interactive
export alias grbm = git rebase (git_main_branch)
export alias grbo = git rebase --onto
export alias grbom = git rebase origin/(git_main_branch)
export alias grbs = git rebase --skip
export alias grbum = git rebase upstream/(git_main_branch)
export alias grev = git revert
export alias greva = git revert --abort
export alias grevc = git revert --continue
export alias grf = git reflog
export alias grh = git reset
export alias grhh = git reset --hard
export alias grhk = git reset --keep
export alias grhs = git reset --soft
export alias grm = git rm
export alias grmc = git rm --cached
export alias grmv = git remote rename
export alias groh = git reset origin/(git_current_branch) --hard
export alias grrm = git remote remove
export alias grs = git restore
export alias grset = git remote set-url
export alias grss = git restore --source
export alias grst = git restore --staged
export alias grt = cd (git rev-parse --show-toplevel)
export alias gru = git reset --
export alias grup = git remote update
export alias grv = git remote --verbose
export alias gsb = git status --short --branch
export alias gsd = git svn dcommit
export alias gsh = git show
export alias gsi = git submodule init
export alias gsmi = git submodule init
export alias gsps = git show --pretty=short --show-signature
export alias gsr = git svn rebase
export alias gss = git status --short
export alias gst = git status
export alias gstaa = git stash apply
export alias gstall = git stash --all
export alias gstc = git stash clear
export alias gstd = git stash drop
export alias gstl = git stash list
export alias gstp = git stash pop
export alias gsts = git stash show --patch
export alias gsu = git submodule update
export alias gsw = git switch
export alias gswc = git switch --create
export alias gswd = git switch (git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||' | str trim)
export alias gswi = git switch (git branch --all | fzf --no-preview --height=50 --border | str trim)  # switch branch
export alias gswm = git switch (git_main_branch)
export alias gta = git tag --annotate
export alias gtl = git tag --sort=-v:refname -n --list "${1}*"
export alias gts = git tag --sign
export alias gtv = git tag | sort -V
export alias gunignore = git update-index --no-assume-unchanged
export alias gwch = git whatchanged -p --abbrev-commit --pretty=medium
export alias gwt = git worktree
export alias gwta = git worktree add
export alias gwtls = git worktree list
export alias gwtmv = git worktree move
export alias gwtrm = git worktree remove

### FUNCTIONS
export def gpoat [] { git push origin --all; git push origin --tags }
export def gpristine [] { git reset --hard; git clean --force -dfx }
export def gsta [] { git stash push; git stash save }
export def gstu [] { git stash push; git stash save --include-untracked }
export def gwipe [] { git reset --hard; git clean --force -df }
# Merge default (origin) branch into current branch
export def gmd [] { 
    if (is_git_repo) == false {
        return
    }
    let default_branch = (git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
    git fetch origin $default_branch
    git merge origin/($default_branch)
}
# Rename a branch locally and in origin remote
export def grbr [old_branch: string, new_branch: string] {
    if (is_git_repo) == false {
        return
    }
    git branch -m $old_branch $new_branch
    if (git push origin :$old_branch | complete | get exit_code) == 0 {
        git push --set-upstream origin $new_branch
    }
}
# Show the differences between the working directory and the index
export def gdv [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git diff -w | bat
    } else {
        git diff -w $args | bat
    }
}
# Show the differences between the working directory and the last commit 
export def gdnolock [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git diff ":(exclude)package-lock.json" ":(exclude)*.lock"
    } else {
        git diff $args ":(exclude)package-lock.json" ":(exclude)*.lock"
    }
}
# Push branch(es) to origin
export def ggp [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git push origin (git_current_branch)
    } else {
        git push origin $args
    }
}
# Push force branch to origin
export def ggpf [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git push --force origin (git_current_branch)
    } else {
        git diff $args ":(exclude)package-lock.json" ":(exclude)*.lock"
        git push --force origin $args
    }
}
# Push force if nobody did change branch to origin
export def ggpfl [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git push --force-with-lease origin (git_current_branch)
    } else {
        git push --force-with-lease origin $args
    }
}
# Pull branch from origin
export def ggl [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git pull origin (git_current_branch)
    } else {
        git pull origin $args
    }
}
# Pull with rebase branch from origin
export def ggu [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        git pull --rebase origin (git_current_branch)
    } else {
        git pull --rebase origin $args
    }
}
# Pull and push rebase branch from/to origin
export def ggpnp [args: string = ""] {
    if (is_git_repo) == false {
        return
    }
    if $args == "" {
        ggl
        ggp
    } else {
        ggl $args
        ggp $args
    }
}
# Get branches that do not exists on remote
export def gbg [] {
    if (is_git_repo) == false {
        return
    }
    git branch -vv --format='%(refname:short)|%(objectname:short)|%(upstream:track)|%(contents:subject)'
    | lines
    | where { |it| $it =~ "gone]" }
    | split column "|"
    | select column1 column2 column4
    | rename branch_name commit_hash commit_message
}
# Remove branches that do not exists on remote (force)
export def gbgD [] {
    gbg | get branch_name | each { |branch| git branch -D $branch }
}
# Remove branches that do not exists on remote
export def gbgd [] {
    gbg | get branch_name | each { |branch| git branch -d $branch }
}

