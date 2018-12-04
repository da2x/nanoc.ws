# frozen_string_literal: true

require 'nokogiri'

module NanocSite
  module ReleaseNotes
    TITLE_REGEX = /^(\d+\.\d+(\.\d+){0,2}) \((\d{4}-\d{2}-\d{2})\)$/.freeze

    class Cached
      include Singleton
      DDMemoize.activate(self)

      memoized def latest_release_info(item)
        # Get release notes page
        content = item.compiled_content
        doc = Nokogiri::HTML(content)

        # Find and parse usable h2
        h2 = doc.css('h2').find { |elem| elem.inner_html.strip =~ TITLE_REGEX }
        h2 =~ TITLE_REGEX

        # Done
        { version: Regexp.last_match(1), date: Date.parse(Regexp.last_match(3)) }
      end
    end

    # Returns a hash with `:version`, containing the latest released version,
    # and `:date`, containing the latest released version’s release date.
    def latest_release_info
      item = items['/release-notes.*']
      Cached.instance.latest_release_info(item)
    end
  end
end
