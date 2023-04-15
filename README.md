# Marten Memcached Cache

[![CI](https://github.com/martenframework/marten-memcached-cache/workflows/Specs/badge.svg)](https://github.com/martenframework/marten-memcached-cache/actions)
[![CI](https://github.com/martenframework/marten-memcached-cache/workflows/QA/badge.svg)](https://github.com/martenframework/marten-memcached-cache/actions)

**Marten Memcached Cache** provides a [Memcached](https://memcached.org) cache store that can be used with Marten web framework's [cache system](https://martenframework.com/docs/caching).

## Installation

Simply add the following entry to your project's `shard.yml`:

```yaml
dependencies:
  marten_memcached_cache:
    github: martenframework/marten-memcached-cache
```

And run `shards install` afterward.

## Configuration

First, add the following requirement to your project's `src/project.cr` file:

```crystal
require "marten_memcached_cache"
```

Then you can configure your project to use the Memcached cache store by setting the corresponding configuration option as follows:

```crystal
Marten.configure do |config|
  config.cache_store = MartenMemcachedCache::Store.new(host: "localhost", port: 11211)
end
```

The `host` and `port` arguments are optional and default respectively to `localhost` and `11211`. It should be noted that this cache store also supports all the existing initialization options in addition to these arguments (eg. `namespace`, `version`, `expires_in`, etc). Please refer to the [cache system documentation](https://martenframework.com/docs/caching) to learn more about Marten's caching framework.

## Authors

Morgan Aubert ([@ellmetha](https://github.com/ellmetha)) and 
[contributors](https://github.com/martenframework/marten-memcached-cache/contributors).

## License

MIT. See ``LICENSE`` for more details.
