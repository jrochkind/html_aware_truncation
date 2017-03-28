require "spec_helper"

RSpec.describe HtmlAwareTruncation do
  include HtmlAwareTruncation

  it "has a version number" do
    expect(HtmlAwareTruncation::VERSION).not_to be nil
  end

  describe "#truncate_html" do
    let(:short_text) { "<p>Foo! <b>Bar</b> Baz</p>" }
    let(:long_text)  { "<p>Foo " +  ("<b>Bar Baz</b> " * 100) + "Quux</p>" }
    let(:list_text)  { "<p>Foo:</p><ul>" +  ("<li>Bar Baz</li>\n" * 100) + "</ul>" }

    let(:max_length) { 10 }

    it "should not modify short text" do
      expect(truncate_html(short_text, length: short_text.length + 10)).to eq(short_text)
    end

    it "should truncate long text to the given number of chars" do
      expect(truncate_html(long_text, length: max_length).gsub(/<[^>]*>/ ,'').length).to eq(max_length)
    end

    pending "truncates on tag boundary properly" do
      pending "error, leaves an extra char"
      html_output = truncate_html("<p>1234567890<b>123456</b>7890</p>", :length => 10)
      expect(html_output).to eq("<p>123456789…</p>")
    end

    it "truncates on tag boundary at least close" do
      html_output = truncate_html("<p>1234567890<b>123456</b>7890</p>", :length => 10)
      expect(html_output.gsub(/<[^>]*>/ ,'').length).to be <= 10 + 1
    end

    it "allows custom string seperator" do
      result = truncate_html(long_text, length: max_length, separator: ' ')
      expect(result.gsub(/<[^>]*>/ ,'').length).to be <= max_length
      expect(result).to eq("<p>Foo <b>Bar…</b></p>")
    end

    it "allows custom regex separator" do
      result = truncate_html(long_text, length: max_length, separator: /\s/)
      expect(result.gsub(/<[^>]*>/ ,'').length).to be <= max_length
      expect(result).to eq("<p>Foo <b>Bar…</b></p>")
    end

    pending "should not contains empty DOM nodes" do
      pending "isn't this smart yet"
      # produces "<p>Foo<b>;</b></p>"
      expect(truncate_html(long_text, length: 5, omission: ';')).not_to match(/<b>;<\/b>/)
    end

    pending "should truncate long text with an ellipsis inside the last reasonable DOM node" do
      pending "not this smart yet, slightly illegal HTML"
      # "<p>Foo:</p><ul>\n<li>Bar Baz</li>\n…</ul>"
      expect(truncate_html(list_text, length: 12, omission: "…")).to match(/…<\/li>\s*<\/ul>$/)
    end
  end
end
