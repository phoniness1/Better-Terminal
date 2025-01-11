#!/bin/bash

# Variables
user=${SUDO_USER:-root}
starshipConf=("/tmp/starship.toml" "/tmp/starship1.toml" "/tmp/starship2.toml")
homeDir=$(eval echo "~$user")
configDir="$homeDir/.config/"
zshConf="/tmp/.zshrc"
firaCode="/tmp/FiraCode"
fontsDir="$homeDir/.fonts/"
zshAutoSuggest="/tmp/zsh-autosuggestions.zsh"
zshSyntaxHigh="/tmp/zsh-syntax-highlighting.zsh"
zshSynDir="/usr/share/zsh-syntax-highlighting"
zshAutoDir="/usr/share/zsh-autosuggestions"
insPkg=("zsh" "wget" "tar" "util-linux" "util-linux-user")

# Check for root and that /tmp directory exists
preCheck () {
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please use sudo."; exit 1
fi
    echo "Current username is $user"
if [ ! -d /tmp ]; then
    echo "/tmp doesn't exist. Creating /tmp directory."
    mkdir /tmp
fi
    echo "/tmp directory does exist."
}

# Install zsh
depExtract() {
    tar -xvf confFiles.tar.gz -C /tmp/
}

zshInstall () {
if command -v apt-get &>/dev/null; then
    pkgMan="apt-get"
elif command -v dnf &>/dev/null; then
    pkgMan="dnf"
else
    echo "Unsupported package manager. Install ${insPkg[*]} manually."; exit 1
fi
for pkg in "${insPkg[@]}"; do
    "$pkgMan" install "$pkg" -y
done
depExtract
if [ ! -f /usr/bin/zsh ];then
    chsh -s "$(which zsh)" "$user"
else
    chsh -s /usr/bin/zsh "$user"
fi
if [ -f "$homeDir"/.zshrc ]; then
    mv "$homeDir"/.zshrc "$homeDir"/.zshrc.old; cp -r "$zshConf" "$homeDir"/.zshrc
else
    cp -r "$zshConf" "$homeDir"/.zshrc
fi
chown "$user":"$user" "$homeDir"/.zshrc
}

# Add plugins
pluginCp () {
    cp -r "$zshSyntaxHigh" "$zshSynDir"; cp -r "$zshAutoSuggest" "$zshAutoDir"
}

zshPlugins () {
    if [[ ! -d "$zshSynDir" || ! -d "$zshAutoDir" ]]; then
        mkdir -p "$zshSynDir" "$zshAutoDir"
        pluginCp
    else rm -rf "$zshAutoDir"/zsh* "$zshSynDir"/zsh* 
        pluginCp
    fi
}

# Add FiraCode fonts
firaCp () {
    cp -r "$firaCode" "$fontsDir"
}

firaCodeFonts () {
    if [ ! -d "$fontsDir" ]; then
        mkdir -p "$fontsDir"; firaCp
    else firaCp
    fi
}

# Install Starship and add theme
starshipCp () {
    cp -r "${starshipConf[@]}" "$configDir"
}

starshipInstall () {
    wget https://starship.rs/install.sh; sh install.sh -y 1> /dev/null
        if [ ! -d "$configDir" ]; then
            mkdir -p "$configDir"; starshipCp
        else starshipCp
            chown "$user":"$user" -R "$configDir"
        fi
    rm -rf ./install.sh
}

# Clean /tmp directory
tmpClean () {
    rm -rf /tmp/zsh-* /tmp/FiraCode /tmp/.zshrc /tmp/starship*
}

# Function calls
preCheck
zshInstall
zshPlugins
firaCodeFonts
starshipInstall
tmpClean

echo "Please change your terminal font to FiraCode. Logout and back in to apply all changes."
