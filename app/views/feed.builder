xml.instruct! :xml, :version => '1.0'
xml.rss :version => "2.0" do
  xml.channel do
    xml.title t(:radio_boot)
    xml.description t(:about)
    xml.link "http://www.radioboot.com/"

    @episodes.each do |episode|
      xml.item do
        xml.title episode.title
        xml.link "http://www.radioboot.com/episodes/#{episode.id}"
        #xml.description episode.
        xml.pubDate Time.parse(episode.published_at.to_s).rfc822()
        xml.guid "http://www.radioboot.com/episodes/#{episode.id}"
      end
    end
  end
end
