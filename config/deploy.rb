require "bundler/capistrano"

load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
# load "config/recipes/nodejs"
load "config/recipes/rbenv"
load "config/recipes/check"

server "kpst01", :web, :app, :db, primary: true

set :user, "deployer"
set :application, "full_circle"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :use_sudo, false

set :scm, :git
set :git_shallow_clone, 1
set :scm_verbose, true
set :deploy_via, :remote_cache
set :repository, "ssh://deployer@kpst01/home/#{user}/#{application}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

# set :repository, "."
# set :repository, "git@github.com:tankwanghow/#{application}.git"
# set :deploy_via, :copy
# set :copy_cache, true