class RemoveNullFromShortUrl3 < ActiveRecord::Migration
  def change
    change_table :shortened_urls do |t|
      t.change :short_url, :string, null: false
    end

  end
end
