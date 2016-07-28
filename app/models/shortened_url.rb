require "securerandom"

class ShortenedUrl < ActiveRecord::Base
  include SecureRandom

  validates :long_url, :short_url, :user_id, presence: true
  validates :short_url, :long_url, uniqueness: true
  validates_length_of :long_url, maximum: 1024
  validate :five_per_minute
  validate :premium_members_only

  belongs_to :submitter,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  has_many :visits,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Visit

  has_many :visitors,
    through: :visits,
    source: :visitor

  has_many :taggings,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :Tagging

  has_many :tag_topics,
    through: :taggings,
    source: :tag_topic

  def self.random_code
    short_url = SecureRandom.urlsafe_base64
    while ShortenedUrl.exists?(short_url: short_url)
      short_url = SecureRandom.urlsafe_base64
    end
    short_url
  end

  def self.create_for_user_and_long_url!(user, long_url)
    user_id = user.id
    if ShortenedUrl.exists?(long_url: long_url)
      short_url = ShortenedUrl.find_by(long_url: long_url).short_url
      raise "Long URL already defined short URL is: #{short_url}"
    else
      short_url = ShortenedUrl.random_code
    end

    ShortenedUrl.create!(long_url: long_url,
                         short_url: short_url,
                         user_id: user_id)
  end

  def self.prune
    unvisited_visits = Visit.where("updated_at <= ?", 45.minutes.ago).select { |visit| visit == visit }
    unvisited_visits.each do |visit|
      ShortenedUrl.find(visit.shortened_url_id).destroy
    end
  end

  def five_per_minute
    author_id = self.user_id
    recent_urls = ShortenedUrl.where("created_at >= ?", 1.minute.ago)
    url_count = recent_urls.select { |url| url.user_id == author_id }.count
    if url_count > 5
      self.errors[:url] << "overload"
    end
  end

  def premium_members_only
    user = User.find(self.user_id)
    url_count = ShortenedUrl.all.select { |url| url.user_id == user.id }.count
    unless user.premium
      if url_count > 5
        self.errors[:user] << "is cheap, cannot create more urls"
      end
    end
  end

  def num_clicks
    visit_arr = Visit.all.select { |value| value.shortened_url_id == self.id }
    visit_arr.inject(0) do |accum, visit|
      accum + visit.times_visited
    end
  end

  def num_uniques
    Visit.all.select { |value| value.shortened_url_id == self.id }.count
  end

  def num_recent_uniques
    all_visits = Visit.where("updated_at >= ?", 2.hours.ago)
    all_visits.select { |value| value.shortened_url_id == self.id }.count
  end



end
