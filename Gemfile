source "http://rubygems.org"

gemspec unless ENV["GEMDEV"] == "1"

group :gem_default do
  gem "new_class", :path => "."
end

group :gem_development do
  gem "pry"
end

group :gem_test do
  gem "shoulda"
  gem "mocha"
end