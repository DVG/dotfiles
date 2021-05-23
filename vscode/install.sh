# Installs VS Code
echo "=== Installing VS Code ==="

if [ -d "/Applications/Visual Studio Code.app" ] ;then
  echo "VS Code already installed"
else
  brew install --cask visual-studio-code
fi