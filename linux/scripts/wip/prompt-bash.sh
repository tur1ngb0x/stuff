
#### PROMPT COLORS ####
_CR_RESET=$'\e[0m'

_CB_BLACK=$'\e[40m';          _CB_BLACK_B=$'\e[100m'
_CB_GREY=$'\e[48;5;240m';     _CB_GREY_B=$'\e[48;5;250m'
_CB_WHITE=$'\e[47m';          _CB_WHITE_B=$'\e[107m'

_CF_BLACK=$'\e[30m';          _CF_BLACK_B=$'\e[90m'
_CF_GREY=$'\e[38;5;240m';     _CF_GREY_B=$'\e[38;5;250m'
_CF_WHITE=$'\e[37m';          _CF_WHITE_B=$'\e[97m'

# Primary
_CF_RED=$'\e[31m';            _CF_RED_B=$'\e[91m'
_CF_GREEN=$'\e[32m';          _CF_GREEN_B=$'\e[92m'
_CF_BLUE=$'\e[34m';           _CF_BLUE_B=$'\e[94m'

_CB_RED=$'\e[41m';            _CB_RED_B=$'\e[101m'
_CB_GREEN=$'\e[42m';          _CB_GREEN_B=$'\e[102m'
_CB_BLUE=$'\e[44m';           _CB_BLUE_B=$'\e[104m'

# Secondary
_CF_YELLOW=$'\e[33m';         _CF_YELLOW_B=$'\e[93m'
_CF_MAGENTA=$'\e[35m';        _CF_MAGENTA_B=$'\e[95m'
_CF_CYAN=$'\e[36m';           _CF_CYAN_B=$'\e[96m'

_CB_YELLOW=$'\e[43m';         _CB_YELLOW_B=$'\e[103m'
_CB_MAGENTA=$'\e[45m';        _CB_MAGENTA_B=$'\e[105m'
_CB_CYAN=$'\e[46m';           _CB_CYAN_B=$'\e[106m'

# Tertiary
_CF_ORANGE=$'\e[38;5;208m';        _CF_ORANGE_B=$'\e[38;5;214m'
_CF_CHARTREUSE=$'\e[38;5;118m';    _CF_CHARTREUSE_B=$'\e[38;5;154m'
_CF_SPRINGGREEN=$'\e[38;5;48m';    _CF_SPRINGGREEN_B=$'\e[38;5;84m'
_CF_AZURE=$'\e[38;5;39m';          _CF_AZURE_B=$'\e[38;5;75m'
_CF_VIOLET=$'\e[38;5;141m';        _CF_VIOLET_B=$'\e[38;5;177m'
_CF_ROSE=$'\e[38;5;205m';          _CF_ROSE_B=$'\e[38;5;211m'

_CB_ORANGE=$'\e[48;5;208m';        _CB_ORANGE_B=$'\e[48;5;214m'
_CB_CHARTREUSE=$'\e[48;5;118m';    _CB_CHARTREUSE_B=$'\e[48;5;154m'
_CB_SPRINGGREEN=$'\e[48;5;48m';    _CB_SPRINGGREEN_B=$'\e[48;5;84m'
_CB_AZURE=$'\e[48;5;39m';          _CB_AZURE_B=$'\e[48;5;75m'
_CB_VIOLET=$'\e[48;5;141m';        _CB_VIOLET_B=$'\e[48;5;177m'
_CB_ROSE=$'\e[48;5;205m';          _CB_ROSE_B=$'\e[48;5;211m'

#### PROMPT HELPERS ####
# _ps1_min()      { PS1='\[\e]0;\u@\h:\w\a\]\u@\h:\w\n\$ '; export PS1; }
# _ps1_sep()      { builtin printf -- '-%.0s\n' "$(/usr/bin/seq 1 "${COLUMNS:-80}")"; }
# _ps1_exit()     { (( EXIT != 0 )) && builtin printf "${_CF_BLACK}${_CB_RED} exit:%s ${_CR_RESET}\n" "${EXIT}"; }
_ps1_userhost() { builtin printf "${_CF_BLACK}${_CB_GREEN_B} %s@%s ${_CR_RESET}\n" "${USER}" "${HOSTNAME}"; }
_ps1_dir()      { builtin printf "${_CF_BLACK}${_CB_CYAN_B} %s ${_CR_RESET}\n" "$(pwd)"; }
_ps1_distrobox(){ [[ -n "${DISTROBOX_ENTER_PATH}" ]] && builtin printf "${_CF_BLACK}${_CB_BLUE_B} dbx   :%s ${_CR_RESET}\n" "$(source /etc/os-release; printf '%s\n' "${ID}")"; }
_ps1_venv()     { [[ -n "${VIRTUAL_ENV}" ]] && builtin printf "${_CF_BLACK}${_CB_MAGENTA_B} venv:%s ${_CR_RESET}\n" "$(/usr/bin/basename "${VIRTUAL_ENV}")"; }
_ps1_git()      { /usr/bin/git rev-parse --git-dir &>/dev/null && builtin printf "${_CF_BLACK}${_CB_YELLOW_B} git:%s ${_CR_RESET}\n" "$(/usr/bin/git rev-parse --abbrev-ref HEAD 2>/dev/null)"; }

#### PROMPT VARIABLES ####
PROMPT_COMMAND='EXIT=$?; builtin history -a'
PS1=""
PS1+='\[\e]0;\u@\h:\w\a\]'
PS1+='$(_ps1_userhost)'
PS1+='$(_ps1_dir)'
PS1+='$(_ps1_distrobox)'
PS1+='$(_ps1_venv)'
PS1+='$(_ps1_git)'
PS1+='\n\$ '


PS2="${_CF_GREY}cont> ${_CR_RESET}"
PS3="${_CF_GREY}pick> ${_CR_RESET}"
PS4='+ \[${_CF_YELLOW}\]${BASH_SOURCE[0]:-BASH_SOURCE}\[${_CR_RESET}\]:\[${_CF_CYAN}\]${LINENO:-LINENO}\[${_CR_RESET}\]:\[${_CF_GREEN}\]${FUNCNAME[0]:-FUNCNAME}\[${_CR_RESET}\]: '

export PROMPT_COMMAND PS1 PS2 PS3 PS4
