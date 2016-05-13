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
  end
end
