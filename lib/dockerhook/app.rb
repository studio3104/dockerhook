require 'sinatra/base'
require 'slim'
require 'json'
require 'tmpdir'
require 'dockerhook/dockerapi'
require 'dockerhook/config'

module DockerHook
  class App < Sinatra::Base
    configure do
      Slim::Engine.default_options[:pretty] = true
      set :root, File.dirname(__FILE__) + '/../..'
    end

    configure :development do
      require 'rack-mini-profiler'
      use Rack::MiniProfiler
      require 'sinatra/reloader'
      register Sinatra::Reloader
      set :show_exception, false
      set :show_exception, :after_handler
    end

    helpers do
      def config
        @@config ||= Config.new(%Q[#{settings.root}/config/config.toml])
      end

      def docker
        @@docker ||= DockerAPI.new(config)
      end

      def dockerfile_as_string(repo)
        dockerfile = ''
        Dir.mktmpdir do |dir|
          `cd #{dir} && git clone #{repo['url']}`
          dockerfile = File.read(%Q[#{dir}/#{repo['name']}/Dockerfile])
        end
        dockerfile
      end
    end

    get '/' do
      slim :index
    end

    post '/' do
      payload = JSON.parse(params['payload'])
      repo = payload['repository']
      docker.build(dockerfile_as_string(repo), repo['owner']['name'], repo['name'], payload['head_commit']['id'])
    end
  end
end
