namespace :apache do
  [:stop, :start, :restart, :reload].each do |action|
    desc "#{action.to_s.capitalize} Apache"
    task action, :roles => :web do
      invoke_command "sudo /sbin/service httpd #{action.to_s}", :via => run_method
    end
  end
end