class RemoveNullFromShortUrl2 < ActiveRecord::Migration
  def change
    change_table :shortened_urls do |t|
      t.change :short_url, :string, null: true
    end
  end
end
