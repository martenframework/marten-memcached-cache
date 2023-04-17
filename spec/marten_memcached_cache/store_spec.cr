require "./spec_helper"

describe MartenMemcachedCache::Store do
  around_each do |t|
    Marten.cache.clear

    t.run

    Marten.cache.clear
  end

  describe "#clear" do
    it "clears all the items in the cache" do
      Marten.cache.write("foo", "bar")
      Marten.cache.write("xyz", "test")

      Marten.cache.clear

      Marten.cache.read("foo").should be_nil
      Marten.cache.read("xyz").should be_nil
    end
  end

  describe "#decrement" do
    it "can decrement an existing integer value" do
      2.times { Marten.cache.increment("foo") }

      Marten.cache.decrement("foo").should eq 1
      Marten.cache.read("foo", raw: true).try(&.to_i).should eq 1
    end

    it "can decrement an existing integer value when a namespace is used" do
      store = MartenMemcachedCache::Store.new(
        namespace: "ns",
        host: ENV_SETTINGS["MEMCACHED_HOST"].as(String),
        port: ENV_SETTINGS["MEMCACHED_PORT"].as(Int32)
      )
      2.times { store.increment("foo") }

      store.decrement("foo").should eq 1
      store.read("foo", raw: true).try(&.to_i).should eq 1
    end

    it "can decrement an existing integer value for a key that is not expired" do
      2.times { Marten.cache.increment("foo", expires_in: 2.hours) }

      Marten.cache.decrement("foo").should eq 1
      Marten.cache.read("foo", raw: true).try(&.to_i).should eq 1
    end

    it "can decrement an existing integer value by a specific amount" do
      5.times { Marten.cache.increment("foo") }

      Marten.cache.decrement("foo", amount: 3).should eq 2
      Marten.cache.read("foo", raw: true).try(&.to_i).should eq 2
    end

    it "writes 0 in case the key does not exist" do
      Marten.cache.decrement("foo").should eq 0
      Marten.cache.read("foo", raw: true).try(&.to_i).should eq 0

      Marten.cache.decrement("bar", amount: 2).should eq 0
      Marten.cache.read("bar", raw: true).try(&.to_i).should eq 0
    end

    it "writes the amount value to the cache in case the key is expired" do
      5.times { Marten.cache.increment("foo", expires_in: 1.second) }
      5.times { Marten.cache.increment("bar", expires_in: 1.second) }

      sleep 2

      Marten.cache.decrement("foo").should eq 0
      Marten.cache.read("foo", raw: true).try(&.to_i).should eq 0

      Marten.cache.decrement("bar", amount: 2).should eq 0
      Marten.cache.read("bar", raw: true).try(&.to_i).should eq 0
    end
  end

  describe "#delete" do
    it "deletes the entry associated with the passed key and returns true" do
      Marten.cache.write("foo", "bar")

      Marten.cache.delete("foo").should be_true
      Marten.cache.exists?("foo").should be_false
    end

    it "returns false if the passed key is not in the cache" do
      Marten.cache.delete("foo").should be_false
    end
  end

  describe "#exists?" do
    it "returns true if the passed key is in the cache" do
      Marten.cache.write("foo", "bar")

      Marten.cache.exists?("foo").should be_true
    end

    it "returns false if the passed key is not in the cache" do
      Marten.cache.exists?("foo").should be_false
    end
  end

  describe "#read" do
    it "returns the cached value if there is one" do
      Marten.cache.write("foo", "bar")

      Marten.cache.read("foo").should eq "bar"
    end

    it "returns nil if the key does not exist" do
      Marten.cache.read("foo").should be_nil
    end
  end

  describe "#write" do
    it "write a Marten.cache value as expected" do
      Marten.cache.write("foo", "bar")
      Marten.cache.read("foo").should eq "bar"
    end
  end
end
