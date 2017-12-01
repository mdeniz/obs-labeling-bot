require 'octokit'

class GithubLabelingBot

  attr_accessor :config
  attr_accessor :client

  def initialize(configuration)
    @config = configuration
    @client = Octokit::Client.new(@config[:credentials])
    @repository = @client.repo(repository_name)
  end

  def repository_name
    "#{@config[:owner]}/#{@config[:repository]}"
  end

  # TODO: Use pagination to get all open
  def pull_requests
    @repository.rels[:pulls].get.data
  end

  # TODO: Use pagination to get all open
  def commits(pull_request)
    pull_request.rels[:commits].get.data
  end

  # TODO: Use pagination to get all open
  def files(pull_request)
    @client.pull_request_files(repository_name, pull_request.number)
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
      #print "#{tag} "
      labels << @config[:labels_by_commit][tag]
    end
    labels.uniq
  end

  def tag_by_file(file)
    label = nil
    @config[:labels_for_files].keys.find do |dir|
      match = file.match(/^#{dir}/)
      label = @config[:labels_for_files][match.to_s]
    end
    label
  end

  def labels_by_files(files)
    labels = []
    files.map(&:filename).each do |filename|
      #print "#{filename} "
      labels << tag_by_file(filename)
    end
    labels.uniq
  end

  def run
    pull_requests.each do |pull_request|
      print "PR ##{pull_request.number} #{pull_request.title} "
      commits = commits(pull_request)
      files = files(pull_request)
      labels = labels_by_commits(commits)
      labels += labels_by_files(files)
      labels = labels.flatten.compact.uniq.sort
      puts labels.inspect
    end
  end

end
