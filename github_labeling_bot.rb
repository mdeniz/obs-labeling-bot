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

  def tags_in_commits(commits)
    tags = []
    commits.each do |commit|
      matches = commit[:commit][:message].scan(/\[\w+\]/)
      matches.each do |tag|
        tags << tag.gsub(/[\[\]]/,'')
      end
    end
    tags.uniq
  end

  def labels_by_commits(commits)
    labels = []
    tags_in_commits(commits).each do |tag|
      print "#{tag} "
      labels << @config[:labels_by_commit][tag]
    end
    labels.uniq
  end

  def run
    pull_requests.each do |pull_request|
      commits = commits(pull_request)
      labels = labels_by_commits(commits)
      puts labels.inspect
    end
  end

end
