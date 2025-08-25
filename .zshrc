export EDITOR=vim

export PATH="$HOME/.local/bin:$HOME/.config/emacs/bin:$HOME/.cargo/bin:$PATH"
export VCPKG_ROOT="$HOME/vcpkg/"

nv() {
  if [ $# -eq 0 ]; then
    nohup neovide > /dev/null 2>&1 &
  else
    nohup neovide "$1" > /dev/null 2>&1 &
  fi
}

alias lzg='lazygit'

alias dotconf='neovide ~/.dotfiles &'
alias zshconf='neovide ~/.zshrc &'

eval "$(starship init zsh)"

alias wezterm='flatpak run org.wezfurlong.wezterm'

eval "$(zoxide init zsh)"
