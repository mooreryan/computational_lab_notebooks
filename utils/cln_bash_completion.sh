function _jsautocom_62715 {
  export COMP_CWORD
  COMP_WORDS[0]=cln.exe
  if type readarray > /dev/null
  then readarray -t COMPREPLY < <("${COMP_WORDS[@]}")
  else IFS="
" read -d "" -A COMPREPLY < <("${COMP_WORDS[@]}")
  fi
}
complete -F _jsautocom_62715 cln.exe
