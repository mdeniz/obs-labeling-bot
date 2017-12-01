require 'octokit'

class GithubLabelingBot

  attr_accessor :config
  attr_accessor :client

  def initialize(configuration)
    @config = configuration
    @client = Octokit::Client.new(config[:credentials])
  end

  def run
    puts @client.user.inspect
  end

end
