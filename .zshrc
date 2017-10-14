#当默认shell为zsh时没有这一行会影响（emacs|spacemacs)编辑远程文件,具体参考下面这个链接
#https://www.evernote.com/shard/s375/sh/938828f8-9ef7-4b64-8b0f-ddb8982dcf8e/d869a85b866ce6c1e8a1d7061455dc04
#emacs tramp wiki https://www.emacswiki.org/emacs/TrampMode
[[ $TERM == "dumb" ]] && unsetopt zle && PS1='$ ' && return

#以下主要是 percol 的配置
function exists { which $1 &> /dev/null }

if exists percol; then
    function percol_select_history() {
        local tac
        exists gtac && tac="gtac" || { exists tac && tac="tac" || { tac="tail -r" } }
        BUFFER=$(fc -l -n 1 | eval $tac | percol --query "$LBUFFER")
        CURSOR=$#BUFFER         # move cursor
        zle -R -c               # refresh
    }

    zle -N percol_select_history
    bindkey '^R' percol_select_history
fi




function ppgrep() {
    if [[ $1 == "" ]]; then
        PERCOL=percol
    else
        PERCOL="percol --query $1"
    fi
    ps aux | eval $PERCOL | awk '{ print $2 }'
}

function ppkill() {
    if [[ $1 =~ "^-" ]]; then
        QUERY=""            # options only
    else
        QUERY=$1            # with a query
        [[ $# > 0 ]] && shift
    fi
    ppgrep $QUERY | xargs kill -s 9 $*
}



function pattach() {
    if [[ $1 == "" ]]; then
        PERCOL=percol
    else
        PERCOL="percol --query $1"
    fi

    sessions=$(tmux ls)
    [ $? -ne 0 ] && return

    session=$(echo $sessions | eval $PERCOL | cut -d : -f 1)
    if [[ -n "$session" ]]; then
        tmux att -t $session
    fi
}

function pngrep() {
    if [[ $1 == "" ]]; then
        PERCOL=percol
    else
        PERCOL="percol --query $1"
    fi
    sudo netstat -ntlp | eval $PERCOL | awk '{ print $7 }' | awk -F '/' '{print $1}'
}

function pnkill() {
    if [[ $1 =~ "^-" ]]; then
        QUERY=""            # options only
    else
        QUERY=$1            # with a query
        [[ $# > 0 ]] && shift
    fi
    pngrep $QUERY | xargs sudo kill -s 9 $*
}
