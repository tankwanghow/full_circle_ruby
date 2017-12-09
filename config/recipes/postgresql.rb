set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { application }
set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
set_default(:postgresql_database) { "#{application}_production" }

namespace :postgresql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} add-apt-repository -y ppa:pitti/postgresql"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install postgresql libpq-dev postgresql-contrib"
  end
  after "deploy:install", "postgresql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}' superuser;"}
    run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"

  desc "Backup Database for this application."
  before "postgresql:dump", "postgresql:vacuum_full"
  task :dump, roles: :db do
    run "pg_dump -U #{postgresql_user} -h #{postgresql_host} #{postgresql_database} --format=tar -f #{application}_backup.tar"
  end

  desc "Copy Production pg_dump to current dir."
  task :copy_dump, roles: :db do
    `scp #{user}@#{application_server}:#{application}_backup.tar ./#{application}_backup_#{DateTime.now.to_s(:db).gsub(/\-|\s|\:/, '')}.tar`
  end
  after "postgresql:dump", "postgresql:copy_dump"

  desc "Vacuum full Production Database"
  task :vacuum_full do
    run %Q{ psql -U full_circle -h localhost -d full_circle_production -c "vacuum full;" }
  end

  desc "Vacuum Production Database"
  task :vacuum do
    run %Q{ psql -U full_circle -h localhost -d full_circle_production -c "vacuum;" }
  end

  desc "Restore Production Database to Development Database"
  task :prod_to_dev do
    `rake db:drop; rake db:create;`
    `pg_restore -h localhost -U full_circle -d #{application}_development -v '#{application}_backup.tar'`
  end
  after "postgresql:copy_dump", "postgresql:prod_to_dev"

end

namespace :dossier do
  desc "Symlink the dossier.yml file into latest release database.yml"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/dossier.yml"
  end
  after "postgresql:symlink", "dossier:symlink"
end
