eval "$(starship init bash)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export PATH=$PATH:/opt/google-cloud-cli/bin

alias lzg="lazygit"
alias lzd="lazydocker"
alias ls="exa --icons"
alias ll="exa -l --icons"

eval "$(zoxide init bash)"

setkb() {
  setxkbmap -layout us -variant intl
}

sysupdates() {
  clear
  echo -e "Checking updates...\n"

  official_updates=$(checkupdates | wc -l)
  echo "$official_updates Official update(s)."

  aur_updates=$(yay -Qua | wc -l)
  echo "$aur_updates AUR update(s)."

  if [ "$official_updates" -gt 0 ] || [ "$aur_updates" -gt 0 ]; then
    echo
    read -r -p "Continue with the yay update? <enter>" 
    yay --noconfirm
  fi

  echo -e "\nAll done!"
}

# --------------------
#   Machine Metrics
# --------------------
export NODE_ENV=dev
source $HOME/Code/dev-tools/mm_profile

mm-conn() {
  openvpn3 session-start --config ~/profile-173-2.ovpn

  sleep 1
  echo
  read -r -p "Web approved? <enter>" 
  sleep 3

  openvpn3 sessions-list
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
  printf "op signin Ok? <enter> " 
  read -p "" 
  printf "\n"

  mm-aws

  cd ~/Code/converge/Dashboard
  npm run auth

  cd ..
  mm-disc
  mm-conn

  echo
  read -r -p "Stop/Start docker? <enter>" 
  echo

  mm-dk-stop
  mm-dk-start

  echo -e "\nDone!\n"
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

