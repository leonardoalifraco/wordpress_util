require 'spec_helper'

describe WordpressUtil do
  describe "#wpautop" do
    it "should not change an empty string" do
      expect(WordpressUtil.wpautop("")).to eq("")
    end

    it "should treat block elements as blocks" do
      blocks = [
        "table", "thead", "tfoot", "caption", "col", "colgroup",
        "tbody", "tr", "td", "th", "div", "dl", "dd", "dt", "ul",
        "ol", "li", "pre", "form", "map", "area", "address",
        "math", "style", "p", "h1", "h2", "h3", "h4", "h5", "h6",
        "hr", "fieldset", "legend", "section", "article",
        "aside", "hgroup", "header", "footer", "nav", "figure",
        "details", "menu", "summary"
      ]

      contents = blocks.map { |x| "<#{x}>foo</#{x}>" }

      expected = contents.join("\n")
      content = contents.join("\n\n")

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should add a paragraph after multiple br" do
      content = "
line 1<br>
<br/>
line 2<br/>
<br />
"
      expected ="<p>line 1</p>
<p>line 2</p>"
      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should skip line breaks after br" do
      content = "
line 1<br>
line 2<br/>
line 3<br />
line 4
line 5
"

      expected = "<p>line 1<br />
line 2<br />
line 3<br />
line 4<br />
line 5</p>"

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should treat inline elements as inline" do
      inlines = [
        "a", "em", "strong", "small", "s",
        "cite", "q", "dfn", "abbr", "data", "time", "code", "var",
        "samp", "kbd", "sub", "sup", "i", "b", "u", "mark",
        "span", "del", "ins", "noscript", "select"
      ]

      content = inlines.map { |inline| "<#{inline}>foo</#{inline}>" }
      expected = inlines.map { |inline| "<p><#{inline}>foo</#{inline}></p>" }

      content = content.join("\n\n")
      expected = expected.join("\n")

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should skip input elements" do
      str = "Username: <input type=\"text\" id=\"username\" name=\"username\" /><br />Password: <input type=\"password\" id=\"password1\" name=\"password1\" />"
      expect(WordpressUtil.wpautop(str).strip).to eq "<p>#{str}</p>"
    end

    it "should source track elements" do
      content = "Paragraph one.\n\n"
      content += "<video class=\"wp-video-shortcode\" id=\"video-0-1\" width=\"640\" height=\"360\" preload=\"metadata\" controls=\"controls\">
        <source type=\"video/mp4\" src=\"http://domain.tld/wp-content/uploads/2013/12/xyz.mp4\" />
        <!-- WebM/VP8 for Firefox4, Opera, and Chrome -->
        <source type=\"video/webm\" src=\"myvideo.webm\" />
        <!-- Ogg/Vorbis for older Firefox and Opera versions -->
        <source type=\"video/ogg\" src=\"myvideo.ogv\" />
        <!-- Optional: Add subtitles for each language -->
        <track kind=\"subtitles\" src=\"subtitles.srt\" srclang=\"en\" />
        <!-- Optional: Add chapters -->
        <track kind=\"chapters\" src=\"chapters.srt\" srclang=\"en\" />
        <a href=\"http://domain.tld/wp-content/uploads/2013/12/xyz.mp4\">http://domain.tld/wp-content/uploads/2013/12/xyz.mp4</a>
      </video>"
      content += "\n\nParagraph two."

      expected = "<p>Paragraph one.</p>\n"
      expected += "<p><video class=\"wp-video-shortcode\" id=\"video-0-1\" width=\"640\" height=\"360\" preload=\"metadata\" controls=\"controls\">"
      expected += "<source type=\"video/mp4\" src=\"http://domain.tld/wp-content/uploads/2013/12/xyz.mp4\" />"
      expected += "<!-- WebM/VP8 for Firefox4, Opera, and Chrome -->"
      expected += "<source type=\"video/webm\" src=\"myvideo.webm\" />"
      expected += "<!-- Ogg/Vorbis for older Firefox and Opera versions -->"
      expected += "<source type=\"video/ogg\" src=\"myvideo.ogv\" />"
      expected += "<!-- Optional: Add subtitles for each language -->"
      expected += "<track kind=\"subtitles\" src=\"subtitles.srt\" srclang=\"en\" />"
      expected += "<!-- Optional: Add chapters -->"
      expected += "<track kind=\"chapters\" src=\"chapters.srt\" srclang=\"en\" />"
      expected += "<a href=\"http://domain.tld/wp-content/uploads/2013/12/xyz.mp4\">"
      expected += "http://domain.tld/wp-content/uploads/2013/12/xyz.mp4</a></video></p>\n"
      expected += "<p>Paragraph two.</p>"

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should not add line breaks between script tags" do
      content = "<script type=\"text/javascript\">\n"
      content += "alert(\"This is a test alert\");\n"
      content += "</script>"

      expected = "<p>" + content + "</p>"

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end

    it "should process ok with script tags on it" do
      content = "[header]72 Beverly Park - BEVERLY HILLS, CA, 90210[/header]\n"
      content += "<div id=\"cp_widget_2ae738fb-0bd7-4dde-a359-2b3beccfc25e\">...</div><script type=\"text/javascript\">\n"
      content += "var cpo = [];\n"
      content += "cpo[\"_object\"] =\"cp_widget_2ae738fb-0bd7-4dde-a359-2b3beccfc25e\"; cpo[\"_fid\"] = \"AwCAWcNQsG3w\";\n"
      content += "var _cpmp = _cpmp || []; _cpmp.push(cpo);\n"
      content += "(function() { var cp = document.createElement(\"script\"); cp.type = \"text/javascript\";\n"
      content += "cp.async = true; cp.src = \"//www.cincopa.com/media-platform/runtime/libasync.js\";\n"
      content += "var c = document.getElementsByTagName(\"script\")[0];\n"
      content += "c.parentNode.insertBefore(cp, c); })();\n"
      content += "</script>\n"
      content += "<noscript>Powered by Cincopa <a href='http://www.cincopa.com/video-hosting'>Video Hosting Platform</a> for Business solution.<span>Beverly Hills - $250 Mill Alt</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 869</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1087</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1073</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1132</span></noscript>\n"
      content += "<strong>Price:</strong> $45 Million\n"
      content += "<strong>Bedrooms:</strong> 11\n"
      content += "<strong>Bathrooms:</strong> 10 Full, 6 Partial"

      expected = "<p>[header]72 Beverly Park - BEVERLY HILLS, CA, 90210[/header]</p>\n"
      expected += "<div id=\"cp_widget_2ae738fb-0bd7-4dde-a359-2b3beccfc25e\">...</div>\n"
      expected += "<p><script type=\"text/javascript\">\n"
      expected += "var cpo = [];\n"
      expected += "cpo[\"_object\"] =\"cp_widget_2ae738fb-0bd7-4dde-a359-2b3beccfc25e\"; cpo[\"_fid\"] = \"AwCAWcNQsG3w\";\n"
      expected += "var _cpmp = _cpmp || []; _cpmp.push(cpo);\n"
      expected += "(function() { var cp = document.createElement(\"script\"); cp.type = \"text/javascript\";\n"
      expected += "cp.async = true; cp.src = \"//www.cincopa.com/media-platform/runtime/libasync.js\";\n"
      expected += "var c = document.getElementsByTagName(\"script\")[0];\n"
      expected += "c.parentNode.insertBefore(cp, c); })();\n"
      expected += "</script><br />\n"
      expected += "<noscript>Powered by Cincopa <a href='http://www.cincopa.com/video-hosting'>Video Hosting Platform</a> for Business solution.<span>Beverly Hills - $250 Mill Alt</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 869</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1087</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1073</span><span>originaldate</span><span> 1/1/0001 6:00:00 AM</span><span>width</span><span> 1700</span><span>height</span><span> 1132</span></noscript><br />\n"
      expected += "<strong>Price:</strong> $45 Million<br />\n"
      expected += "<strong>Bedrooms:</strong> 11<br />\n"
      expected += "<strong>Bathrooms:</strong> 10 Full, 6 Partial</p>"

      expect(WordpressUtil.wpautop(content).strip).to eq expected
    end
  end
end
