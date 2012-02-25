module Heroku
  class Addons < Thor
    include Thor::Actions

    desc 'install', 'Install new addons'
    def install(env)
      all.map do |key, value|
        run "heroku addons:add %s:%s -r %s" % [key, value, env]
      end
    end

    private

    def all
      YAML.load(File.open('config/heroku/addons.yml'))
    end
  end

  class Config < Thor
    include Thor::Actions

    desc 'setup', 'Bootstrap a new app with config vars'
    def setup(env)
      config_vars = all[env].map do |key, value|
        "%s=%s" % [key, value]
      end.join(' ')
      run "heroku config:add %s -r %s" % [config_vars, env]
    end

    private

    def all
      YAML.load(File.open('config/heroku/environment.yml'))
    end
  end
end
