# Super lazy develper tools

Path: [bin](../bin/)

As a lazy developer,

I expect that the project bin folder is in my path. To accomplish this, I use [direnv](https://direnv.net/docs/hook.html)

## Enable direnv
To enable `direnv` run `bin/add_direnv`. This installs `direnv`, adds it to the `~/.bashrc` and
sources `~/.bashrc` to turn it on. It also runs `direnv allow` to add the path

As a developer: `bundle exec rails server` is too long: `rs`

As a dev: `bundle exec rails c` is too long: `rc`

As a dev Alias of rescue
```bash
RAILS_ENV=test bundle exec rescue rspec
RAILS_ENV=test bundle exec rescue rspec -t browser 
```

As a linux nerd, I miss `ls -al` alias of `ll`
