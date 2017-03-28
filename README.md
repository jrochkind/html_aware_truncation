# HtmlAwareTruncation
[![Gem Version](https://badge.fury.io/rb/html_aware_truncation.svg)](https://badge.fury.io/rb/html_aware_truncation)
[![Build Status](https://travis-ci.org/jrochkind/html_aware_truncation.svg?branch=master)](https://travis-ci.org/jrochkind/html_aware_truncation)


Yet another ruby html-aware truncation routine. Truncate HTML to max text characters,
resulting in still legal HTML without any unclosed tags etc.

I was unable to find an existing solution that met my needs:
* Uses [nokogiri](https://github.com/sparklemotion/nokogiri) (cause it's really good at handling somewhat invalid HTML input, and you probably already have it as a dependency)
* Does not monkey-patch nokogiri or String or anything else.
* Follows Rails [truncate helper](http://api.rubyonrails.org/classes/ActionView/Helpers/TextHelper.html#method-i-truncate)
  semantics, including a custom :separator that can be a string or regex, usually for word boundaries.


## Usage

```ruby
require 'html_aware_truncation'
string = "<p>Lots of html <b>with bolded stuff</b></p>"
HtmlAwareTruncation.truncate_html(string, length: 10)
# => "<p>Lots of h…</p>"
HtmlAwareTruncation.truncate_html(string, length: 10, separator: /\b/)
# => "<p>Lots of …</p>"
HtmlAwareTruncation.truncate_html(string, length: 10, separator: /\b/, omission: '--')
# => "<p>Lots of --</p>"
```

If you already have a Nokogiri node, or want to do the Nokogiri
parsing and serialization yourself, you can pass a single Nokogiri node
to `truncate_nokogiri_node`. Often a `Nokogiri::HTML::DocumentFragment` makes sense:

```ruby
node = Nokogiri::HTML::DocumentFragment.parse(some_html_str)
HtmlAwareTruncation.truncate_nokogiri_node(some_html_str, length: 10)
# => Returns a Nokogiri node, may mutate original passed in, not entirely sure.
```

For convenience, you can `include` the `HtmlAwareTruncation` module, to
get it's methods as mixins.

```ruby
require 'html_aware_truncation'
class Something
  include HtmlAwareTruncation

  def something
    truncate_html(whatever)
  end
end
```

## Known problems

This isn't perfect, but it's good enough for me to use in several production
apps. In edge cases, it may sometimes:

* May in some cases be an extra character (or a few) above the specified `length` limit (off by one error maybe?)
* put the omission mark in a node of it's own, which is kind of silly: `"<p>Stuff <b>…</b></p>"`
* leave one or more empty nodes at the end: `"<p>Stuff and...<b></b></p>"`
* Put the omission mark in a tag/node that really ought not to have text content: `"<ul><li>stuff</li>…</ul>"
  (This one bothers me the most, it's the only case I know this gem produces slightly illegal HTML, but generally happens rarely)

Some specs marked `pending` demonstrate some "bad behavior", but there may be others un-tested.

In general though, this has not caused me real problems in production, it works out.
I still find this preferable to other alternative gems I know about, so I packaged it up in
case you do too. Patches welcome.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jrochkind/html_aware_truncation.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Alternatives

I adapted some code or tests from some of these. I mostly adapted from
an example in [a blog post now only in the wayback machine](https://web-beta.archive.org/web/20160116165808/http://blog.madebydna.com/all/code/2010/06/04/ruby-helper-to-cleanly-truncate-html.html).
Alternative examples can also be useful to look at to see how/if they solve the known problems with this gem, for ideas.

* https://github.com/nono/HTML-Truncator
* https://github.com/hgmnz/truncate_html
* https://github.com/ianwhite/truncate_html


