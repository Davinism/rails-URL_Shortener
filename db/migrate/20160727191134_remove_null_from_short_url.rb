class RemoveNullFromShortUrl < ActiveRecord::Migration
  def change
    change_table :shortened_urls do |t|
      t.change :short_url, :string
    end
  end
end
