class Person < ActiveRecord::Base
  include ::Diaspora::Guid

  def alias_url;   "#{url}people/#{guid}" end
  def hcard_url;   "#{url}hcard/users/#{guid}" end
  def profile_url; "#{url}u/#{diaspora_handle.split('@')[0]}" end
  def atom_url;    "#{url}public/#{diaspora_handle.split('@')[0]}.atom" end
  def salmon_url;  "#{url}receive/users/#{guid}" end

  alias_attribute :seed_url, :url
  alias_attribute :public_key, :serialized_public_key

  def nickname;         diaspora_handle.split("@")[0] end
  def photo_large_url;  "#{url}assets/user/default.png" end
  def photo_medium_url; "#{url}assets/user/default.png" end
  def photo_small_url;  "#{url}assets/user/default.png" end

  def searchable; true end
  def full_name;  "Dummy User" end
  def first_name; "Dummy" end
  def last_name;  "User" end

  def self.find_local_by_diaspora_handle(identifier)
    # no remote? and closed_account? check ... this class is only for testing
    find_by_diaspora_handle(identifier)
  end

  def self.find_local_by_guid(guid)
    # no remote? and closed_account? check ... this class is only for testing
    find_by_guid(guid)
  end
end
