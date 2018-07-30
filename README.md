[![Build Status](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload)
[![Maintainability](https://api.codeclimate.com/v1/badges/00d04595661820dfba80/maintainability)](https://codeclimate.com/github/DmitryTsepelev/ar_lazy_preload/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/ar_lazy_preload/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/ar_lazy_preload?branch=master)

# ArLazyPreload

Lazy loading associations for the ActiveRecord models. `#includes`, `#eager_load` and `#preload` are built-in methods to avoid N+1 problem, but sometimes when DB request is made we don't know what associations we are going to need later (for instance when your API allows client to define a list of loaded associations dynamically). The only possible solution for such cases is to load _all_ the associations we might need, but it can be a huge overhead.

This gem allows to set up _lazy_ preloading for associations - it won't load anything until association is called for a first time, but when it happens - it loads all the associated records for all records from the initial relation in a single query.

For example, if we define a following relation

```ruby
users = User.lazy_preload(:posts).limit(10)
```

and use it in a following way

```ruby
users.map(&:first_name)
```

there will be one query because we've never accessed posts:

```sql
SELECT * FROM users LIMIT 10
```

Hovever, when we try to load posts

```ruby
users.map(&:posts)
```

there will be one more request for posts:

```sql
SELECT * FROM posts WHERE user_id in (...)
```

## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "ar_lazy_preload"
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
