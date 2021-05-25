# Install iTerm 2 from Homebrew Cask
# along with favorite color schemes

brew install --cask iterm2

git clone git@github.com:mbadolato/iTerm2-Color-Schemes.git $HOME/iterm2-colors
cd $HOME/iterm2-colors
tools/import-scheme.sh 'Tomorrow Night.itermcolors'
rm -rf $HOME/iterm2-colors