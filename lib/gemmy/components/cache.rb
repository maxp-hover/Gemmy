class Gemmy::Components::Cache < Hash

  using Gemmy.patch("hash/i/persisted")
  using Gemmy.patch("hash/i/bury")
  using Gemmy.patch("object/i/home")
  using Gemmy.patch("object/i/m")

  def self.setup_cache_folder
    cache_path = ENV["GEMMY_CACHE_PATH"] || "#{home}/gemmy/caches"
    unless Dir.exists?(cache_path)
      `mkdir -p #{cache_path}`
    end
    cache_path
  end

  def initialize(db_name, hash={})
    cache_path = self.class.setup_cache_folder
    @db = hash.persisted "#{cache_path}/#{db_name}.yaml"
    # copy db state into memory
    @db.data.each { |k,v| self[k] = v.deep_dup }
  end

  def get_or_set(*keys, &blk)
    result = get(*keys)
    if result.blank?
      result = blk.call
      set(*keys, result)
    end
    result
  end

  def data
    @db.data
  end

  def keys
    @db.data.keys
  end

  def get(*keys)
    @db.dig *keys
  end

  # Delete functions like "dig_delete"
  # I.e. if given a few keys as arguments, it will treat only the last as
  # a delete key and all the rest as dig keys.
  def dig_delete(*keys)
    @db.dig_delete *keys
    key_to_delete = keys.pop
    if keys.empty?
      self.delete key_to_delete
    else
      self.dig(*keys).delete key_to_delete
    end
  end

  def set_state(hash)
    @db.set_state hash
    each_key &m(:delete)
    deep_merge! hash
  end

  def set(*keys, val)
    Gemmy.patch("hash/i/bury").bury(self, *keys, val)
    @db.set(*keys, val)
  end

  def clear
    each_key &m(:delete)
    @db.clear
  end

end
