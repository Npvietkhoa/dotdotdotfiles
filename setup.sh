#!bin/bash

# Set zsh as default shell
chsh -s /usr/bin/zsh root

# Install Fira Font
echo "Installing Fira Font"
fonts_dir="${HOME}/.local/share/fonts"
if [ ! -d "${fonts_dir}" ]; then
    echo "mkdir -p $fonts_dir"
    mkdir -p "${fonts_dir}"
else
    echo "Found fonts dir $fonts_dir"
fi

for type in Bold Light Medium Regular Retina; do
    file_path="${HOME}/.local/share/fonts/FiraCode-${type}.ttf"
    file_url="https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true"
    if [ ! -e "${file_path}" ]; then
        echo "wget -O $file_path $file_url"
        wget -O "${file_path}" "${file_url}"
    else
	echo "Found existing file $file_path"
    fi;
done

echo "fc-cache -f"
fc-cache -f

# Apply Dracula font to zsh
git clone https://github.com/dracula/zsh.git
mv zsh/dracula.zsh-theme oh-my-zsh/themes/
mv zsh/lib oh-my-zsh/themes/lib
rm -rf zsh

sed -i "s|ZSH_THEME=.*|ZSH_THEME=\"dracula\"|" ~/.zshrc