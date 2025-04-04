## 🛠️ Installation

### windows

```powershell
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName $env:LOCALAPPDATA\nvim.bak
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName $env:LOCALAPPDATA\nvim-data.bak
```

```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim" -Recurse -Force
git clone https://github.com/wzj-zz/AstroNvim.git $env:LOCALAPPDATA\nvim
```

### linux

```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

```shell
rm -r ~/.config/nvim
git clone https://github.com/wzj-zz/AstroNvim.git ~/.config/nvim
```
