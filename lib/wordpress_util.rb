require "wordpress_util/version"

class WordpressUtil
  class << self
  	##
	# Replaces double line-breaks with paragraph elements.
	#
	# A group of regex replaces used to identify text formatted with newlines and
	# replace double line-breaks with HTML paragraph tags. The remaining line-breaks
	# after conversion become <<br />> tags, unless $br is set to '0' or 'false'.
	#
	# ==== Parameters
	# * string pee The text which has to be formatted.
	# * bool br Optional. If set, this will convert all remaining line-breaks after paragraphing. Default true.
    def wpautop(pee, br = true)
      pre_tags = {}

      return "" if pee.strip == ""

      # just to make things a little easier, pad the end
      pee = "#{pee}\n"

      # Pre tags shouldn"t be touched by autop.
      # Replace pre tags with placeholders and bring them back after autop.
      if pee.index("<pre")
        pee_parts = pee.split("</pre>")
        last_pee = pee_parts.pop
        pee = ""
        i = 0

        pee_parts.each do |pee_part|
          start = pee_part.index("<pre")

          # malformed html?
          unless start
            pee += pee_part
            next
          end

          name = "<pre wp-pre-tag-#{i}></pre>"
          pre_tags[name] = pee_part[start..-1] + "</pre>"

          pee += pee_part[0..start-1] + name
          i += 1
        end

        pee += last_pee
      end

      # Change multiple <br>s into two line breaks, which will turn into paragraphs.
      pee = pee.gsub(/<br\s*\/?>\s*<br\s*\/?>/, "\n\n")

      allblocks = "(?:table|thead|tfoot|caption|col|colgroup|tbody|tr|td|th|div|dl|dd|dt|ul|ol|li|pre|form|map|area|blockquote|address|math|style|p|h[1-6]|hr|fieldset|legend|section|article|aside|hgroup|header|footer|nav|figure|figcaption|details|menu|summary)"

      # Add a single line break above block-level opening tags.
      pee = pee.gsub(Regexp.new("(<" + allblocks + "[\\s/>])"), "\n\\1")

      # Add a double line break below block-level closing tags.
      pee = pee.gsub(Regexp.new("(</" + allblocks + ">)"), "\\1\n\n")

      # Standardize newline characters to "\n".
      pee = pee.gsub(/\r\n|\r/, "\n")

      # Find newlines in all elements and add placeholders.
      pee = wp_replace_in_html_tags(pee, { "\n" => " <!-- wpnl --> " });

      # Collapse line breaks before and after <option> elements so they don"t get autop"d.
      if pee.index("<option")
        pee = pee.gsub(/\s*<option/, "<option")
        pee = pee.gsub(/<\/option>\s*/, "</option>")
      end

      # Collapse line breaks inside <object> elements, before <param> and <embed> elements
      # so they don't get autop'd.
      if pee.index("</object>")
        pee = pee.gsub(/(<object[^>]*>)\s*/, "\\1")
        pee = pee.gsub(/\s*<\/object>/, '</object>')
        pee = pee.gsub(/\s*(<\/?(?:param|embed)[^>]*>)\s*/, "\\1")
      end

      # Collapse line breaks inside <audio> and <video> elements,
      # before and after <source> and <track> elements.
      if pee.index("<source") || pee.index("<track")
        pee = pee.gsub(/([<\[](?:audio|video)[^>\]]*[>\]])\s*/, "\\1")
        pee = pee.gsub(/\s*([<\[]\/(?:audio|video)[>\]])/, "\\1")
        pee = pee.gsub(/\s*(<(?:source|track)[^>]*>)\s*/, "\\1")
      end

      # Remove more than two contiguous line breaks.
      pee = pee.gsub(/\n\n+/, "\n\n")

      # Split up the contents into an array of strings, separated by double line breaks.
      pees = pee.split(/\n\s*\n/)

      # Reset pee prior to rebuilding.
      pee = ""

      # Rebuild the content as a string, wrapping every bit with a <p>.
      pees.each do |tinkle|
        pee += "<p>" + tinkle.strip + "</p>\n"
      end

      # Under certain strange conditions it could create a P of entirely whitespace.
      pee = pee.gsub(/<p>\s*<\/p>/, "")

      # Add a closing <p> inside <div>, <address>, or <form> tag if missing.
      pee = pee.gsub(/<p>([^<]+)<\/(div|address|form)>/, "<p>\\1</p></\\2>")

      # If an opening or closing block element tag is wrapped in a <p>, unwrap it.
      pee = pee.gsub(Regexp.new("<p>\\s*(</?" + allblocks + "[^>]*>)\\s*</p>"), "\\1")

      # In some cases <li> may get wrapped in <p>, fix them.
      pee = pee.gsub(/<p>(<li.+?)<\/p>/, "\\1")

      # If a <blockquote> is wrapped with a <p>, move it inside the <blockquote>.
      pee = pee.gsub(/<p><blockquote([^>]*)>/i, "<blockquote\\1><p>")
      pee = pee.gsub("</blockquote></p>", "</p></blockquote>")

      # If an opening or closing block element tag is preceded by an opening <p> tag, remove it.
      pee = pee.gsub(Regexp.new("<p>\\s*(</?" + allblocks + "[^>]*>)"), "\\1")

      # If an opening or closing block element tag is followed by a closing <p> tag, remove it.
      pee = pee.gsub(Regexp.new("(</?" + allblocks + "[^>]*>)\\s*</p>"), "\\1")

      # Optionally insert line breaks.
      if br
        pee = pee.gsub(Regexp.new("<(script|style).*?<\/\\1>")) do |s|
          s.gsub("\n", "<WPPreserveNewline \/>")
        end

        # Normalize <br>
        pee = pee.gsub(/<br>|<br\/>/, "<br />")

        # Replace any new line characters that aren"t preceded by a <br /> with a <br />.
        pee = pee.gsub(/(?<!<br \/>)\s*\n/, "<br />\n")

        pee = pee.gsub("<WPPreserveNewline />", "\n")
      end

      # If a <br /> tag is after an opening or closing block tag, remove it.
      pee = pee.gsub(Regexp.new("(</?"+allblocks+"[^>]*>)\s*<br />"), "\\1")

      # If a <br /> tag is before a subset of opening or closing block tags, remove it.
      pee = pee.gsub(/<br \/>(\s*<\/?(?:p|li|div|dl|dd|dt|th|pre|td|ul|ol)[^>]*>)/, "\\1")
      pee = pee.gsub(/\n<\/p>$/, "</p>")

      # Replace placeholder <pre> tags with their original content.
      if pre_tags.any?
        pre_tags.each { |key, value| pee = pee.gsub(key, value) }
      end

      # Restore newlines in all elements.
      if pee.index("<!-- wpnl -->")
        [" <!-- wpnl --> ", "<!-- wpnl -->"].each { |search| pee = pee.gsub(search, "\n") }
      end

      return pee
    end

    private
    def wp_replace_in_html_tags(haystack, replace_pairs)
      # Find all elements
      textarr = wp_html_split(haystack)
      changed = false

      # Replace the pairs
      replace_pairs.each do |needle, replace|
        textarr.each_with_index do |element, index|
          if index.odd? && textarr[index].index(needle)
            textarr[index] = textarr[index].gsub(needle, replace)
            changed = true
          end
        end
      end

      return textarr.join if changed
      haystack
    end

    def wp_html_split(input)
      input.split(Regexp.new(get_html_split_regex))
    end

    def get_html_split_regex
      comments = "!(?:-(?!->)[^\\-]*+)*+(?:-->)?"
      cdata = "!\\[CDATA\\[[^\\]]*+(?:\\](?!\\]>)[^\\]]*+)*+(?:\\]\\]>)?"
      regex = "(<(?=(!--|!\\[CDATA\\[))?(?(2)(?=(!-))?(?(3)" + comments + "|" + cdata + ")|[^>]*>?))"
      return regex
    end
  end
end
