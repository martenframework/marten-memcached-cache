require "./spec_helper"

describe MartenMemcachedCache::Store do
  around_each do |t|
    memcached_client = Memcached::Client.new
    memcached_client.flush

    t.run

    memcached_client.flush
  end

  describe "#clear" do
    it "clears all the items in the cache" do
      store = MartenMemcachedCache::Store.new
      store.write("foo", "bar")
      store.write("xyz", "test")

      store.clear

      store.read("foo").should be_nil
      store.read("xyz").should be_nil
    end
  end

  describe "#delete" do
    it "deletes the entry associated with the passed key and returns true" do
      store = MartenMemcachedCache::Store.new
      store.write("foo", "bar")

      store.delete("foo").should be_true
      store.exists?("foo").should be_false
    end

    it "returns false if the passed key is not in the cache" do
      store = MartenMemcachedCache::Store.new

      store.delete("foo").should be_false
    end
  end

  describe "#exists?" do
    it "returns true if the passed key is in the cache" do
      store = MartenMemcachedCache::Store.new
      store.write("foo", "bar")

      store.exists?("foo").should be_true
    end

    it "returns false if the passed key is not in the cache" do
      store = MartenMemcachedCache::Store.new

      store.exists?("foo").should be_false
    end
  end

  describe "#read" do
    it "returns the cached value if there is one" do
      store = MartenMemcachedCache::Store.new
      store.write("foo", "bar")

      store.read("foo").should eq "bar"
    end

    it "returns nil if the key does not exist" do
      store = MartenMemcachedCache::Store.new

      store.read("foo").should be_nil
    end
  end

  describe "#write" do
    it "write a store value as expected" do
      store = MartenMemcachedCache::Store.new

      store.write("foo", "bar")
      store.read("foo").should eq "bar"
    end
  end
end
