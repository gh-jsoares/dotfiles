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

## Installing some tools
The configs I use belong to tools (obviously). This section will aid with installing the correct tools, assuming you already installed `awesome` and the `xorg` toolsets.

### The editor (nvim)
The editor I'm using is Neovim v5.0 (the nightly build). Currently this build isn't the default build, so in order to install it we need to run the following command:
```bash
yay neovim-nightly-bin
```
If you open nvim and run `:checkhealth` you are probably missing some important stuff. For that we will need to install python3, pip3, node (yarn), ruby and the corresponding modules.
Let's start.

#### Python module
To install both python3, pip3 and pynvim we can run the following command:
```bash
sudo pacman -S python python-pip python-pynvim
```

#### Node module
I use a [node version manager (nvm)](https://github.com/nvm-sh/nvm) to manage my node installation. Their instructions are quite easy to follow. We just need to run the following set of commands:
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
```
After installing it, we need to reload our .zshrc config by running `source $HOME/.zshrc`. Then we can finally install the latest stable build by executing the following command:
```bash
nvm install --lts
```

After we have node installed, I also like to install yarn. We will also install the nvim module:
```bash
npm i -g yarn neovim
```

#### Ruby module
To install the ruby module we can just pull from the AUR. We will use the following command:
```bash
yay ruby-neovim
```
#### Sanity check
After installing all the modules, let's check nvim. Open nvim and run the `:checkhealth` command. The output should be a bit nicer.

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
