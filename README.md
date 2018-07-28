[![Build Status](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload)
[![Maintainability](https://api.codeclimate.com/v1/badges/00d04595661820dfba80/maintainability)](https://codeclimate.com/github/DmitryTsepelev/ar_lazy_preload/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/ar_lazy_preload/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/ar_lazy_preload?branch=master)

# ArLazyPreload

Lazy loading associations of the ActiveRecord models

Examples:

```ruby
users = User.lazy_preload(:posts).limit(10)
users.map(&:first_name)

# There will be one query because we've never accessed posts
#=> SELECT * FROM users LIMIT 10

users.map(&:posts)
# There will be two requests (one for users and one for posts), without lazy_preload it would have caused N+1 problem
#=> SELECT * FROM users LIMIT 10
#=> SELECT * FROM posts WHERE user_id in (...)
```

## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "ar_lazy_preload"
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
