module MartenMemcachedCache
  # A cache store implementation that stores data in Memcached.
  class Store < Marten::Cache::Store::Base
    def initialize(
      @namespace : String? = nil,
      @expires_in : Time::Span? = nil,
      @version : Int32? = nil,
      @compress = true,
      @compress_threshold = Marten::Cache::Store::Base::DEFAULT_COMPRESS_THRESHOLD,
      host : String = "localhost",
      port : Int32 = 11211
    )
      super(@namespace, @expires_in, @version, @compress, @compress_threshold)

      @client = Memcached::Client.new(host: host, port: port)
    end

    private getter client

    def clear : Nil
      client.flush
    end

    private def delete_entry(key : String) : Bool
      client.delete(key)
    end

    private def read_entry(key : String) : Marten::Cache::Entry?
      deserialize_entry(client.get(key))
    end

    private def write_entry(
      key : String,
      entry : Marten::Cache::Entry,
      expires_in : Time::Span? = nil,
      race_condition_ttl : Time::Span? = nil,
      compress : Bool? = nil,
      compress_threshold : Int32? = nil
    )
      serialized_entry = serialize_entry(entry, compress, compress_threshold)

      # Add an extra 5 minutes to the expiry of the memcached entry to allow for race condition TTL reads.
      if !expires_in.nil? && !race_condition_ttl.nil?
        expires_in += 5.minutes
      end

      client.set(key, serialized_entry, expires_in.try(&.total_seconds.to_i) || 0)
      true
    end
  end
end
