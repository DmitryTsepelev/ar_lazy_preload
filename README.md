[![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](https://cultofmartians.com/tasks/activerecord-lazy-preload.html)
[![Gem Version](https://badge.fury.io/rb/ar_lazy_preload.svg)](https://rubygems.org/gems/ar_lazy_preload)
[![Build Status](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload)
[![Maintainability](https://api.codeclimate.com/v1/badges/00d04595661820dfba80/maintainability)](https://codeclimate.com/github/DmitryTsepelev/ar_lazy_preload/maintainability)
[![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/ar_lazy_preload/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/ar_lazy_preload?branch=master)

# ArLazyPreload

<a href="https://evilmartians.com/?utm_source=ar_lazy_preload">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

Lazy loading associations for the ActiveRecord models. `#includes`, `#eager_load` and `#preload` are built-in methods to avoid N+1 problem, but sometimes when DB request is made we don't know what associations we are going to need later (for instance when your API allows client to define a list of loaded associations dynamically). The only possible solution for such cases is to load _all_ the associations we might need, but it can be a huge overhead.

This gem allows to set up _lazy_ preloading for associations - it won't load anything until association is called for a first time, but when it happens - it loads all the associated records for all records from the initial relation in a single query.

## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "ar_lazy_preload"
```

## Usage

For example, if we define the following relation

```ruby
users = User.lazy_preload(:posts).limit(10)
```

and use it in the following way

```ruby
users.map(&:first_name)
```

there will be one query because we've never accessed posts:

```sql
SELECT * FROM users LIMIT 10
```

However, when we try to load posts

```ruby
users.map(&:posts)
```

there will be one more request for posts:

```sql
SELECT * FROM posts WHERE user_id in (...)
```

## Auto preloading

If you want the gem to be even more lazy - you can configure it to load all the associations lazily without specifying them explicitly. In order to do that you'll need to change the configuration in the following way:

```ruby
ArLazyPreload.config.auto_preload = true
```

After that there is no need to call `lazy_preload` on the association, everything would be loaded lazily.

> Worried about the performance? Take a look at [benchmarks](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload) (`TASK=bench` and `TASK=memory`)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
