class Person < ActiveRecord::Base
  include ::Diaspora::Guid

  def alias_url;   "#{url}people/#{guid}" end
  def hcard_url;   "#{url}hcard/users/#{guid}" end
  def profile_url; "#{url}u/#{nickname}" end
  def atom_url;    "#{url}public/#{nickname}.atom" end
  def salmon_url;  "#{url}receive/users/#{guid}" end

  def nickname;         diaspora_handle.split("@")[0] end

  def photo_default_url;  "#{url}assets/user/default.png" end

  def searchable; true end
  def full_name;  "Dummy User" end
  def first_name; "Dummy" end
  def last_name;  "User" end
end
