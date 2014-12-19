require 'docker'

module DockerHook
  class DockerAPI
    def initialize(config)
      @config = config
      Docker.url = conf[:docker][:url]
    end

    def build(dockerfile_as_string, owner, image_name, tag)
      i = Docker::Image.build(dockerfile_as_string)
      i.tag(repo: %Q[#{conf[:docker][:repo]}/#{owner}/#{image_name}:#{tag}])
      i.push
    end

    def conf
      @config
    end
  end
end
