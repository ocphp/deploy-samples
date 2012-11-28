set :application, "OCPHP"
set :repository,  "git@github.com:ocphp/drupal-7-demo.git"

# List the Drupal multi-site folders.  Use "default" if no multi-sites are installed.
set :domains, ["default"]

# Use git for deployment
set :scm, :git
set :deploy_via, :remote_cache

# Multistage support - see config/deploy/[STAGE].rb for specific configs
# set :default_stage, "development"
# set :stages, %w(staging development)