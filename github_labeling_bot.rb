require 'octokit'

class GithubLabelingBot

  attr_accessor :config
  attr_accessor :client

  def initialize(configuration)
    @config = configuration
    @client = Octokit::Client.new(@config[:credentials])
    @repository = @client.repo("#{@config[:owner]}/#{@config[:repository]}")
  end

  # TODO: Use pagination to get all open
  def pull_requests
    @repository.rels[:pulls].get.data
  end

  # TODO: Use pagination to get all open
  def commits(pull_request)
    pull_request.rels[:commits].get.data
  end

  def run
    pull_requests.each do |pull_request|
      puts commits(pull_request).inspect
    end
  end

end
