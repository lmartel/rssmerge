require 'feedjira'
require 'parallel'
require 'rss'
require 'sinatra'

require './lib'

# allow // in paths
set :protection, except: :path_traversal

# unofficial name: official name
ATTR_SYNONYMS = {
    url: [:link]
}

def copy_attrs_safely(from, to)
  getters = from.public_methods(false).reject {|met| met.to_s.end_with?("=") }
  getters.each do |getter|
    names_to_try = [getter] + (ATTR_SYNONYMS[getter] || [])
    names_to_try.each do |name|
      setter = "#{name}=".to_sym
      if to.respond_to?(setter)
        value = from.send(getter)
        to.send(setter, value)
      end
    end
  end
end

get '/x/*' do
  # use lookahead regex to split /x/url1/url2 into [url1, url2], dropping the x
  _, *urls = request.fullpath.split(%r{/(?=https?://)})
  return 404 unless urls.length > 0
  feeds = Parallel.map(urls, in_threads: urls.length) do |url|
    Feedjira::Feed.fetch_and_parse(url)
  end

  # sort items from all feeds by date descending
  merged_items = merge_sorted_arrays(feeds.map(&:entries)) { |x, y| (x.published <=> y.published) == 1 }

  primary = feeds.first
  merged = RSS::Maker.make("rss2.0") do |maker|
    copy_attrs_safely(primary, maker)
    copy_attrs_safely(primary, maker.channel)
    maker.version = "1.0" # ensure xml version is 1.0 rather than copying the rss version

    merged_items.each do |item|
      maker.items.new_item do |new_item|
        copy_attrs_safely(item, new_item)
      end
    end
  end
  merged.to_s
end
