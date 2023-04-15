ENV_SETTINGS_FILENAME = ".spec.env.json"

if File.exists?(ENV_SETTINGS_FILENAME)
  env_settings = Hash(String, Int32 | String).from_json(File.read(ENV_SETTINGS_FILENAME))
else
  env_settings = Hash(String, Int32 | String).new
end

Marten.configure :test do |config|
  config.secret_key = "__insecure_#{Random::Secure.random_bytes(32).hexstring}__"
  config.log_level = ::Log::Severity::None
  config.cache_store = MartenMemcachedCache::Store.new(
    host: env_settings["MEMCACHED_HOST"].as(String),
    port: env_settings["MEMCACHED_PORT"].as(Int32),
  )
end
