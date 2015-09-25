# Curl is required to install docker.
package 'curl'

# Docker is installed from Docker executable, as Ubuntu packages are too old.
execute 'install-docker' do
  command 'curl -sSL https://get.docker.com/ | sh'
  not_if { File::exist?('/usr/bin/docker') }
end

# Creates base directory where applications will be deployed.
directory applications_path

# Sets up each application.
server_setup_applications.each do |application|

  # Each application has a specific user which will be the owner of its files.
  user application do
    shell '/bin/false'
    home File::join(applications_path, application)
  end

  # Creates directory structure for the application.
  %w(app).each do |dir|
    directory File::join(applications_path, application, dir) do
      owner application
      group 'www-data'
      mode 0750
      recursive true
    end
  end

  %w(log run).each do |dir|
    directory File::join(applications_path, application, dir) do
      owner application
      group 'www-data'
      mode 0770
      recursive true
    end
  end

  # Creates container for the application if it does not exist.
  # Note that if the container exists but is stopped this will do nothing.
  execute "create-fpm-container-for-#{application}" do
    command start_container_for(application, 'php')
    not_if { container_is_running_or_exists_for?(application) }
  end

end

