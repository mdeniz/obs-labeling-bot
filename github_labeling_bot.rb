require 'octokit'

class GithubLabelingBot

  attr_accessor :config
  attr_accessor :client

  def initialize(configuration)
    @config = configuration
    @client = Octokit::Client.new(@config[:credentials])
    @repository = @client.repo("#{@config[:owner]}/#{@config[:repository]}")
  end

  def pull_requests
    @repository.rels[:pulls]
  end

  def run
    puts pull_requests.get(state: 'all').data.inspect
  end

end
