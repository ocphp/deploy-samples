#http://nathanhoad.net/deploy-from-a-git-tag-with-capistrano

set :branch do
  default_tag = `git tag`.split("\n").last
	default_tag = 'master' if default_tag.nil?

  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the tag first): [#{default_tag}] "
  tag = default_tag if tag.empty?
  tag
end