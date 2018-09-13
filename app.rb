require 'open-uri'
require 'parallel'
require 'rss'
require 'sinatra'

require './lib'

# allow // in paths
set :protection, except: :path_traversal

get '/x/*' do
  # use lookahead regex to split /x/url1/url2 into [url1, url2], dropping the x
  _, *urls = request.fullpath.split(%r{/(?=https?://)})
  return 404 unless urls.length > 0
  feeds = Parallel.map(urls, in_threads: urls.length) do |url|
    open(url) do |rss|
      RSS::Parser.parse(rss)
    end
  end

  # sort items from all feeds by date descending
  merged_items = merge_sorted_arrays(feeds.map(&:items)) { |x, y| (x.date <=> y.date) == 1 }

  # we can't directly set feed.items so we modify the existing array instead
  main_feed = feeds.first
  main_feed.items.reject! { |_| true }
  main_feed.items.push(*merged_items)
  main_feed.to_s
end
