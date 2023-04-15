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
    it "write a store value as expected" do
      Marten.cache.write("foo", "bar")
      Marten.cache.read("foo").should eq "bar"
    end
  end
end
