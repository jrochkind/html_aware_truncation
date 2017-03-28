require "html_aware_truncation/version"
require 'nokogiri'

module HtmlAwareTruncation
  define_singleton_method(:default_length) { @default_length }
  define_singleton_method(:default_length=) { |val| @default_length = val }
  self.default_length = 200
  define_singleton_method(:default_omission) { @default_omission }
  define_singleton_method(:default_omission=) { |val| @default_omission = val }
  self.default_omission = '…'

  def truncate_html(str,
                    length: HtmlAwareTruncation.default_length,
                    omission: HtmlAwareTruncation.default_omission,
                    separator: nil)

    HtmlAwareTruncation.truncate_nokogiri_node(
      Nokogiri::HTML::DocumentFragment.parse(str),
      length: length,
      omission: omission,
      separator: separator
    ).to_html
  end
  module_function :truncate_html

  # HTML-aware truncation of a `Nokogiri::HTML::DocumentFragment`, perhaps
  # one you created with `Nokogiri::HTML::DocumentFragment.parse(str)`
  # Returns a TODO. (may mutate input?)
  #
  # See also truncate_string, which will take and return a string, parsing
  # for you for convenience.
  def truncate_nokogiri_node(node,
                                 length: HtmlAwareTruncation.default_length,
                                 omission: HtmlAwareTruncation.default_omission,
                                 separator: nil)
    if node.kind_of?(::Nokogiri::XML::Text)
      if node.content.length > length
        allowable_endpoint = [0, length - omission.length].max
        if separator
          allowable_endpoint = (node.content.rindex(separator, allowable_endpoint) || allowable_endpoint)
        end

        ::Nokogiri::XML::Text.new(node.content.slice(0, allowable_endpoint) + omission, node.parent)
      else
        node.dup
      end
    else # DocumentFragment or Element
      return node if node.inner_text.length <= length

      truncated_node = node.dup
      truncated_node.children.remove
      remaining_length = length

      node.children.each do |child|
        if remaining_length == 0
          truncated_node.add_child ::Nokogiri::XML::Text.new(omission, truncated_node)
          break
        elsif remaining_length < 0
          break
        end
        truncated_node.add_child HtmlAwareTruncation.truncate_nokogiri_node(child, length: remaining_length, omission: omission, separator: separator)
        # can end up less than 0 if the child was truncated to fit, that's
        # fine:
        remaining_length = remaining_length - child.inner_text.length

      end
      truncated_node
    end
  end
  module_function :truncate_nokogiri_node

end
