module MartenMemcachedCache
  # A cache store implementation that stores data in Memcached.
  #
  # The `host` and `port` arguments are optional and default respectively to localhost and 11211. It should be noted
  # that this cache store also supports all the existing initialization options in addition to these arguments (eg.
  # namespace, version, expires_in, etc).
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

    def decrement(
      key : String,
      amount : Int32 = 1,
      expires_at : Time? = nil,
      expires_in : Time::Span? = nil,
      version : Int32? = nil,
      race_condition_ttl : Time::Span? = nil,
      compress : Bool? = nil,
      compress_threshold : Int32? = nil
    ) : Int
      effective_expires_in = if !expires_at.nil?
                               expires_at.to_utc - Time.utc
                             else
                               expires_in.nil? ? self.expires_in : expires_in
                             end

      effective_expires_in = adapt_expiry_for_race_condition(effective_expires_in, race_condition_ttl)

      client.decrement(
        normalize_key(key),
        amount,
        initial_value: 0,
        expire: effective_expires_in.try(&.total_seconds.to_i) || 0
      ).not_nil!
    end

    def increment(
      key : String,
      amount : Int32 = 1,
      expires_at : Time? = nil,
      expires_in : Time::Span? = nil,
      version : Int32? = nil,
      race_condition_ttl : Time::Span? = nil,
      compress : Bool? = nil,
      compress_threshold : Int32? = nil
    ) : Int
      effective_expires_in = if !expires_at.nil?
                               expires_at.to_utc - Time.utc
                             else
                               expires_in.nil? ? self.expires_in : expires_in
                             end

      effective_expires_in = adapt_expiry_for_race_condition(effective_expires_in, race_condition_ttl)

      client.increment(
        normalize_key(key),
        amount,
        initial_value: amount,
        expire: effective_expires_in.try(&.total_seconds.to_i) || 0
      ).not_nil!
    end

    private def adapt_expiry_for_race_condition(expires_in : Time::Span? = nil, race_condition_ttl : Time::Span? = nil)
      # Add an extra 5 minutes to the expiry of the memcached entry to allow for race condition TTL reads.
      if !expires_in.nil? && !race_condition_ttl.nil?
        expires_in += 5.minutes
      end

      expires_in
    end

    private def delete_entry(key : String) : Bool
      client.delete(key)
    end

    private def read_entry(key : String) : String?
      client.get(key)
    end

    private def write_entry(
      key : String,
      value : String,
      expires_in : Time::Span? = nil,
      race_condition_ttl : Time::Span? = nil
    )
      expires_in = adapt_expiry_for_race_condition(expires_in, race_condition_ttl)

      client.set(key, value, expires_in.try(&.total_seconds.to_i) || 0)
      true
    end
  end
end
