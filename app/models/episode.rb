require 'mongoid'


class Episode
  include Mongoid::Document

  field :title, type: String
  field :episode_number, type: String
  field :mp3_url, type: String
  field :ogg_url, type: String
  field :tags, type: Array
  field :published_at, type: DateTime, default: ->{ Date.today }
  field :downloads, type: Integer, default: 0
  field :details, type: Hash, default: {}

  index({ title: 1 }, { unique: true, background: true })
  index({ episode_number: 1 }, { background: true })

  validates_presence_of :title
  validates_uniqueness_of :title

  validates_presence_of :episode_number
  validates_presence_of :mp3_url
  validates_presence_of :ogg_url

  before_save do |document|
    # Create the data index from ogg file
  end
end
