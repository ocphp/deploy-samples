### This file contains stage-specific settings ###

# Set the deployment directory on the target hosts.
set :deploy_to, "/var/www/"
set :shared_dir, "shared"

# The hostnames to deploy to.
role :web, "[[host name]]"
role :app, "[[host name]]"
 
# Specify one of the web servers to use for database backups or updates.
# This server should also be running Drupal.
role :db, "[[host name]]", :primary => true
 
# The username on the target system, if different from your local username
set :ssh_options, {
	:forward_agent => true,
	:user => '[[user]]',
	:keys => [File.join(ENV["HOME"], '.ssh', '[[ssh key]]')]
}
default_run_options[:pty] = true
set :use_sudo, false

# The path to drush
set :drush, "cd #{current_path} ; /usr/bin/php /home/ec2-user/drush/drush.php"