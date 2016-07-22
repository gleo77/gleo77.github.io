### enable rbenv in current shell (for some reason sourcing .bashrc doesn't work here)
export PATH=$HOME/.rbenv/bin:$HOME/.rbenv/plugins/ruby-build/bin:$PATH
eval "$(~/.rbenv/bin/rbenv init -)"

### start server
cd /vagrant
jekyll serve -q -H 0.0.0.0 --detach
