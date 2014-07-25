require 'mongoid'


class Episode
  include Mongoid::Document

  field :title, type: String
  field :episode_number, type: String
  field :mp3_url, type: String
  field :ogg_url, type: String
  field :tags, type: Array
  field :published_at, type: Datetime

  field :downloads, type: Integer, default: 0

  index({ title: 1, episode_number: 1 }, { unique: true, background: true })
end
