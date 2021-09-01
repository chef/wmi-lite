source "https://rubygems.org"

gemspec

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :test do
  gem "chefstyle", "= 1.2.0"
  gem "rspec", "~> 3.1"
  gem "docile", "~> 1.3.5" # pin until we drop ruby support 2.4
  gem "rake"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "rb-readline"
  gem "simplecov", "~> 0.18.5" # pin until we drop ruby support 2.4
end
