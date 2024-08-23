# Installs Docker Desktop
echo "=== Installing Docker Desktop ==="

which -s docker
if [[ $? != 0 ]] ; then
  brew install --cask orbstack
fi