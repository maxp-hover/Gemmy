class Gemmy::Components::Cache < Hash

  using Gemmy.patch("hash/i/persisted")
  using Gemmy.patch("hash/i/bury")
  using Gemmy.patch("object/i/home")

  CachePath = ENV["GEMMY_CACHE_PATH"] || "#{home}/gemmy/caches"

  unless Dir.exists?(CachePath)
    `mkdir -p #{CachePath}`
  end

  def initialize(db_name)
    @db = {}.persisted "#{CachePath}/#{db_name}.yaml"
    @memory = @db.get(:data)
  end

  def get_or_set(*keys, &blk)
    result = get(*keys)
    if result.blank?
      result = blk.call
      set(*keys, result)
    end
    result
  end

  def keys
    @db.data.keys
  end

  def get(*keys, source: :db)
    if source == :memory
      @memory.dig *keys
    elsif source == :db
      @db.dig *keys
    else
      raise ArgumentError
    end
  end

  def set(*keys, val)
    @db.set(*keys, val)
  end

  def clear
    # forwards it to PersistedHash
    @db.clear
  end
end
