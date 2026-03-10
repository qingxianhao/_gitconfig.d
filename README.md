## .gitconfig.d

my .gitconfig files

### Unix-like

```bash
ln -sv $PWD ~/.gitconfig.d
```

### windows (requires NTFS)

```cmd
mklink /d %CD% %USERPROFILE%\.gitconfig.d
```
