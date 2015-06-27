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

  def hcard_profile_hash
    {
      guid:             guid,
      nickname:         diaspora_handle.split("@")[0],
      full_name:        "Dummy User",
      url:              url,
      photo_full_url:   "#{url}assets/user/default.png",
      photo_medium_url: "#{url}assets/user/default.png",
      photo_small_url:  "#{url}assets/user/default.png",
      pubkey:           serialized_public_key,
      searchable:       true,
      first_name:       "Dummy",
      last_name:        "User"
    }
  end

  def self.find_local_by_diaspora_handle(identifier)
    # no remote? and closed_account? check ... this class is only for testing
    find_by_diaspora_handle(identifier)
  end

  def self.find_local_by_guid(guid)
    # no remote? and closed_account? check ... this class is only for testing
    find_by_guid(guid)
  end
end
