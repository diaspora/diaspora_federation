class Person < ActiveRecord::Base
  include ::Diaspora::Guid

  def webfinger_hash
    {
      acct_uri:    "acct:#{diaspora_handle}",
      alias_url:   "#{url}people/#{guid}",
      hcard_url:   "#{url}hcard/users/#{guid}",
      seed_url:    url,
      profile_url: "#{url}u/#{diaspora_handle.split('@')[0]}",
      atom_url:    "#{url}public/#{diaspora_handle.split('@')[0]}.atom",
      salmon_url:  "#{url}receive/users/#{guid}",
      guid:        guid,
      pubkey:      serialized_public_key
    }
  end

  def self.find_by_diaspora_handle(identifier)
    find_by(diaspora_handle: identifier)
  end

  def self.find_local_by_diaspora_handle(identifier)
    # no remote? check ... this class is only for testing
    find_by_diaspora_handle(identifier)
  end
end
