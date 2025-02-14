source "https://rubygems.org"

gemspec

group :docs do
  gem "yard"
  gem "redcarpet"
  gem "github-markup"
end

group :test do
  gem "chefstyle", "= 2.2.3"
  gem "rspec", "~> 3.13"
  gem "docile", "~> 1.4.1" # pin until we drop ruby support 2.4
  gem "rake"
end

group :debug do
  gem "pry"
  gem "pry-byebug"
  gem "rb-readline"
  gem "simplecov", "~> 0.22.0" # pin until we drop ruby support 2.4
end
