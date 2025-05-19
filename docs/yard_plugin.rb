require "yard"
# https://github.com/troessner/reek/blob/87b0e75091552c59fcf20105016ba6ce97a57b06/docs/yard_plugin.rb
module LocalLinkHelper
  # Rewrites links to (assumed local) markdown files so they're processed as
  # {file: } directives.
  def resolve_links(text)
    text.gsub!(%r{<a href="([^"]*.md)">([^<]*)</a>}, '{file:\1 \2}')
    super
  end
end

YARD::Templates::Template.extra_includes << LocalLinkHelper
