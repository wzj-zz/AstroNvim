## 🛠️ Installation

### windows

- **Backup**
```powershell
Rename-Item -Path $env:LOCALAPPDATA\nvim -NewName $env:LOCALAPPDATA\nvim.bak
Rename-Item -Path $env:LOCALAPPDATA\nvim-data -NewName $env:LOCALAPPDATA\nvim-data.bak
```
- **Install**
```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim" -Recurse -Force
git clone https://github.com/wzj-zz/AstroNvim.git $env:LOCALAPPDATA\nvim
```
- **Remove backup**
```powershell
Remove-Item -Path "$env:LOCALAPPDATA\nvim.bak" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\nvim-data.bak" -Recurse -Force
```

### linux

- **Backup**
```shell
mv ~/.config/nvim ~/.config/nvim.bak
mv ~/.local/share/nvim ~/.local/share/nvim.bak
mv ~/.local/state/nvim ~/.local/state/nvim.bak
mv ~/.cache/nvim ~/.cache/nvim.bak
```

- **Install**
```shell
rm -r ~/.config/nvim
git clone https://github.com/wzj-zz/AstroNvim.git ~/.config/nvim
```

- **Remove backup**
```shell
rm -r ~/.config/nvim.bak
rm -r ~/.local/share/nvim.bak
rm -r ~/.local/state/nvim.bak
rm -r ~/.cache/nvim.bak
```

