ENV["MARTEN_ENV"] = "test"

require "spec"
require "timecop"

require "marten"
require "marten/spec"

require "../src/marten_memcached_cache"

require "./test_project"
