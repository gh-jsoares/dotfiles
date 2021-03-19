# roxie's dotfiles
This repository holds the configuration files for my current development environment.
It's still in its early stages so it may be quite buggy.

## Installation guide
This repository manages dotfiles using a bare repo, inspired in this [article](https://www.atlassian.com/git/tutorials/dotfiles).
Before we can clone this, we need to do some magic first.

Start by creating an alias to interact with the repository on the system by running the following command:
```bash
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
```
You only need to run this once because the `.zshrc` that is pulled already contains this alias.

Next we can just clone the repo inside the folder specified above `.cfg`.
```bash
git clone --bare git@github.com:gh-jsoares/dotfiles.git $HOME/.cfg
```

After cloning the repository files, we can finally checkout the branch we intend on using. The way we interact with the repository is by using the alias created above.
```bash
config checkout
```

The last step is to make sure the repository doesn't track any files we don't specify. We can enforce this on the local repository only by executing the following command:
```bash
config config --local status.showUntrackedFiles no
```

Now we can easily manage the contents of the repository by using the following commands:
```bash
config status # show the status of the repository
config add <files> # add files to the repository
config rm <files> # remove files from the repository
config commit -m "<message>" # perform a commit
config push # push changes to remote repository
```

## Some information
The system is hosted inside a VirtualBox machine.

+ **OS**: Arch Linux
+ **WM**: AwesomeWM
+ **Terminal**: termite
+ **Editor**: nvim
+ **Shell**: zsh
+ **Compositor**: picom
+ **Bars**: None yet
+ **Menu**: None yet
+ **Media**: None yet
+ **File Manager**: None yet
+ **Browser**: chromium
+ **Font**: FiraMono (for now)
+ **Memory**: 8GB + 16GB swap (Guest)
+ **CPU**: Intel i7-9750H @ 2.60GHz (Host)
+ **GPU**: NVIDIA GeForce GTX 1650 with Max-Q Design (Host)
+ **Laptop**: MSI GF63 Thin 9SC
+ **Screen Framerate**: 120Hz
+ **Screen Resolution**: 1920x1080
+ **Keyboard**: Ducky One 2 SF 65% MX Red
