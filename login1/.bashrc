# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
        . /etc/bashrc
fi

# User specific aliases and functions
export TERM=screen

# Use keychain to manager ssh-agent
eval `keychain --quiet --eval id_dsa id_dsa.taobao id_dsa.console`

# For screen prompt
echo -n -e "\033k`uname -n`\033\\"
