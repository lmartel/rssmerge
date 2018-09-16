# rssmerge
A simple RSS feed merging tool. I use this for podcasts.

# Usage

There's no UI. Just slap each feed's full url, including the `http(s)`, onto the end of [http://rssmerge.herokuapp.com/x/](http://rssmerge.herokuapp.com/x/) separated by a single `/`.

For example: `http://rssmerge.herokuapp.com/x/http://example.com/feed1.rss/http://example.org/feed2.rss`. Then just paste that url into your favorite rss reader, podcast app, etc.

This tool works for [syntactically valid RSS feeds](https://validator.w3.org/feed/) and for many invalid ones, too. If you find a (reasonable!) feed that crashes it feel free to let me know.
