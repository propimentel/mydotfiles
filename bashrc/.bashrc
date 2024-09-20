eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

alias lzg="lazygit"
alias lzd="lazydocker"
alias ls="exa --icons"
alias ll="exa -l --icons"

# --------------------
#   Machine Metrics
# --------------------
export NODE_ENV=dev
source $HOME/Code/dev-tools/mm_profile

mm-conn() {
  openvpn3 session-start --config ~/profile-173-2.ovpn

  printf "\nWeb login requested, accept it then <enter>.\n" 
  read -p "" 
}

mm-disc() {
  sessions=$(openvpn3 sessions-list)
  session_paths=$(echo "$sessions" | awk '/Path: / {print $2}')

  for path in $session_paths; do
    printf "Disconnecting session at path: $path.\n"
    openvpn3 session-manage --disconnect --session-path "$path"
  done
}

mm-aws() {
  devmain
  ~/.aws/mfa
  aws sts get-caller-identity
}

mm-start() {
  clear
  eval $(op signin)
  export NPM_GITHUB_TOKEN=$(op item get "NPM Package" --fields label=notesPlain | sed -n 's/.*"\([^ ]*\).*/\1/p')
  printf "op signin Ok? <enter> " user_input
  read -p "" user_input
  printf "\n"

  mm-aws

  cd ~/Code/converge/Dashboard
  npm run auth

  cd ..
  mm-disc
  mm-conn

  printf "Stop/Start docker? <enter> "
  read -p ""
  printf "\n"
  mm-dk-stop
  mm-dk-start

  printf "\nDone!\n"
}

mm-dk-start() {
  cd ~/Code/converge
  docker-compose up -d
  cd
}

mm-dk-stop() {
  cd ~/Code/converge
  docker-compose down
  cd
}

