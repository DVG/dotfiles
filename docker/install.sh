which docker > /dev/null

which -s docker
if [[ $? != 0 ]] ; then
  brew install --cask docker
fi