# **kevinnguyenhoang91's** Dotfiles

## Installation

Clone this project at `$HOME`:

```sh
git clone https://github.com/kevinnguyenhoang91/dotfiles.git "$HOME/dotfiles"
cd dotfiles
```

Install `stow` with your package manager or download it from the [GNU website](https://www.gnu.org/software/stow/).

Create a backup of your existing dotfiles, remove them in `$HOME` and install the new ones using [stow](https://www.gnu.org/software/stow/):

```sh
make stow
```

To remove dotfiles:

```sh
make unstow
```

## Post-installation

## Acknowledgement

- [huyvohcmc’s dotfiles](https://github.com/huyvohcmc/dotfiles)

## License

This repository is available under the [MIT license](LICENSE). Feel free to fork and modify the dotfiles as you please.
