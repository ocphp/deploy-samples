# Runs +command+ as root invoking the command with su -c
# and handling the root password prompt.
#
#   surun "/etc/init.d/apache reload"
#   # Executes
#   # su - -c '/etc/init.d/apache reload'
#

def surun(command)
  password = fetch(:root_password, Capistrano::CLI.password_prompt("root password: "))
  run("su - -c '#{command}'") do |channel, stream, output|
    channel.send_data("#{password}n") if output
  end
end

# These tasks are specific to drupal deployments.
# Loosely based on the following resources
#
# RESOURCES
# http://www.metaltoad.com/blog/capistrano-drupal-deployments-made-easy-part-1 (PART 1)
# http://www.metaltoad.com/blog/deployment-capistrano-part-2-drush-integration-multistage-and-multisite (PART 2)

namespace :deploy do

    desc "Prepares one or more servers for deployment."
    task :setup, :except => { :no_release => true } do
	dirs = [deploy_to, releases_path, shared_path]
	domains.each do |domain|
	  dirs += [shared_path + "/#{domain}/files"]
	end
	dirs += %w(system).map { |d| File.join(shared_path, d) }
	run "mkdir -p #{dirs.join(' ')}" 
    end

    desc "Create settings.php in shared/config" 
    task :after_setup do
	configuration = <<-EOF
	<?php
	$db_url = 'mysql://username:password@localhost/databasename';
	$db_prefix = '';
	EOF
    
	domains.each do |domain|
	    put configuration, "#{deploy_to}/#{shared_dir}/#{domain}/settings.php"
	end
    end

    desc "[internal] Touches up the released code."
    task :finalize_update, :except => { :no_release => true } do
	run "chmod -R g+w #{release_path}"

	domains.each do |domain|
	    # link settings file
	    run "ln -nfs #{deploy_to}/#{shared_dir}/default/settings.php #{release_path}/sites/default/settings.php"
	    
	    # remove any link or directory that was exported from SCM, and link to remote Drupal filesystem
	    run "rm -rf #{release_path}/sites/#{domain}/files"
	    run "ln -nfs #{deploy_to}/#{shared_dir}/default/files #{release_path}/sites/default/files"
        end
    end

    desc "Flush the Drupal cache system."
    task :cacheclear, :roles => :db, :only => { :primary => true } do
	domains.each do |domain|
	    run "cd #{deploy_to}/current && #{drush} --uri=#{domain} cc all"
	end
    end

    after "deploy", "deploy:cacheclear"
    after "deploy", "deploy:cleanup"
end