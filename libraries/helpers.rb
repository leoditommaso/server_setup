def applications_path
  node['server_setup']['base_path']
end

def server_setup_applications
  node['server_setup']['applications']
end

def start_container_for(application, kind)
  start_command_for_application(application)[kind]
end

def container_is_running_or_exists_for?(application)
  ((%x[ docker inspect --format='{{.State.Running}}' #{application} ]).chomp == 'true') ||
    ((%x[ docker inspect --format='{{.State.Running}}' #{application} ]).chomp == 'false')
end

private

def start_command_for_application(application)
  # This is a hash which returns the command to create the container, depending kind of application.
  {
    'php' => "docker run -d -v #{File::join(applications_path, application, 'log')}:/var/log/phpfpm -v #{File::join(applications_path, application, 'run')}:/var/run/phpfpm -v #{File::join(applications_path, application, 'app')}:/opt/applications --name #{application} leoditommaso/php-fpm"
  }
end
