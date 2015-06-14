class Person < ActiveRecord::Base
  def salmon_url
    "#{url}receive/users/#{guid}"
  end

  def atom_url
    "#{url}public/#{diaspora_handle.split('@')[0]}.atom"
  end

  def profile_url
    "#{url}u/#{diaspora_handle.split('@')[0]}"
  end

  def hcard_url
    "#{url}hcard/users/#{guid}"
  end

  def self.find_by_diaspora_handle(identifier)
    find_by(diaspora_handle: identifier)
  end

  def self.find_local_by_diaspora_handle(identifier)
    # no remote? check ... this class is only for testing
    find_by_diaspora_handle(identifier)
  end
end
