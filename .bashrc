# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions

export PERL_LOCAL_LIB_ROOT="/home/yunkai/perl5";
export PERL_MB_OPT="--install_base /home/yunkai/perl5";
export PERL_MM_OPT="INSTALL_BASE=/home/yunkai/perl5";
export PERL5LIB="/home/yunkai/perl5/lib/perl5/x86_64-linux-thread-multi:/home/yunkai/perl5/lib/perl5";
export PATH="/home/yunkai/perl5/bin:$PATH";

# Use keychain to manager ssh-agent
eval `keychain --quiet --eval id_rsa id_dsa.taobao`

#alias ssh='tsocks ssh'
