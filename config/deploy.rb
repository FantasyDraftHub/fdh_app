# config valid only for current version of Capistrano
$LOAD_PATH << File.expand_path('../lib', __FILE__)
lock '3.4.0'

set :application, 'ui'
set :deploy_to, '/var/www/ui'
set :repo_url, 'git@github.com:TradingCardScanner/fdh_app.git'
set :scm, :rsync
set :branch, 'master'
set :rsync_copy, "rsync --archive"
set :rsync_options, %w(--recursive --delete --delete-excluded --exclude .git*)

task :precompile do
  run_locally do
    Dir.chdir fetch(:rsync_stage) do
      execute :npm, :install, '--quiet', '--production'
      execute :bower, :install, '--force'
      execute :gulp, :build, "--env #{ENV.fetch('BUILD_ENV')}"
      execute :mkdir, '-p', 'dist'
      execute :cp, '-r', "build-#{ENV.fetch('BUILD_ENV')}/*", 'dist/'
    end
  end
end
after 'rsync:stage', :precompile

namespace :deploy do
  task :current do
    on release_roles :all do
      within fetch(:deploy_to) do
        sha = capture :cat, 'current/REVISION'
        puts "Current Ref: #{sha}"
      end
    end
  end
end