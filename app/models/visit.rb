class Visit < ActiveRecord::Base
  validates :shortened_url_id, :user_id, :times_visited, presence: true

  def self.record_visit!(user, shortened_url)
    if Visit.exists?(shortened_url_id: shortened_url.id, user_id: user.id)
      visit = Visit.find_by(shortened_url_id: shortened_url.id, user_id: user.id)
      visit.times_visited += 1
      visit.save
    else
      Visit.create!(user_id: user.id,
                    shortened_url_id: shortened_url.id,
                    times_visited: 1)
    end
  end

  belongs_to :visitor,
    primary_key: :id,
    foreign_key: :user_id,
    class_name: :User

  belongs_to :shortened_url,
    primary_key: :id,
    foreign_key: :shortened_url_id,
    class_name: :ShortenedUrl

end
