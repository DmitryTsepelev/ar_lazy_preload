# ArLazyPreload [![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](https://cultofmartians.com/tasks/activerecord-lazy-preload.html) [![Gem Version](https://badge.fury.io/rb/ar_lazy_preload.svg)](https://rubygems.org/gems/ar_lazy_preload) [![Build Status](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload.svg?branch=master)](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload) [![Maintainability](https://api.codeclimate.com/v1/badges/00d04595661820dfba80/maintainability)](https://codeclimate.com/github/DmitryTsepelev/ar_lazy_preload/maintainability) [![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/ar_lazy_preload/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/ar_lazy_preload?branch=master)

**ArLazyPreload** is a gem that brings association lazy load functionality to your Rails applications. There is a number of built-in methods to solve [N+1 problem](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations), but sometimes a list of associations to preload is not obvious–this is when you can get most of this gem.

- **Simple**. The only thing you need to change is to use `#lazy_preload` instead of `#includes`, `#eager_load` or `#preload`
- **Fast**. Take a look at [benchmarks](https://travis-ci.org/DmitryTsepelev/ar_lazy_preload) (`TASK=bench` and `TASK=memory`)
- **Perfect fit for GraphQL**. Define a list of associations to load at the top-level resolver and let the gem do its job
- **Auto-preload support**. If you don't want to specify the association list–set `ArLazyPreload.config.auto_preload` to `true`

<p align="center">
  <a href="https://evilmartians.com/?utm_source=ar_lazy_preload">
    <img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54">
  </a>
</p>

## Why should I use it?

Lazy loading is super helpful when the list of associations to load is determined dynamically. For instance, in GraphQL this list comes from the API client, and you'll have to inspect the selection set to find out what associations are going to be used.

This gem uses a different approach: it won't load anything until the association is called for a first time. When it happens–it loads all the associated records for all records from the initial relation in a single query.

## Usage

Let's try `#lazy_preload` in action! The following code will perform a single SQL request (because we've never accessed posts):

```ruby
users = User.lazy_preload(:posts).limit(10)  # => SELECT * FROM users LIMIT 10
users.map(&:first_name)
```

However, when we try to load posts, there will be one more request for posts:

```ruby
users.map(&:posts) # => SELECT * FROM posts WHERE user_id in (...)
```

## Auto preloading

If you want the gem to be even lazier–you can configure it to load all the associations lazily without specifying them explicitly. To do that you'll need to change the configuration in the following way:

```ruby
ArLazyPreload.config.auto_preload = true
```

After that there is no need to call `#lazy_preload` on the association, everything would be loaded lazily.

If you want to turn automatic preload off for a specific record, you can call `.skip_preload` before any associations method:

```ruby
users.first.skip_preload.posts # => SELECT * FROM posts WHERE user_id = ?
```

### Relation auto preloading

Another alternative for auto preloading is using relation `#lazy_auto_preload` method

```ruby
posts = User.lazy_auto_preload.flat_map(&:posts)
# => SELECT * FROM users LIMIT 10
# => SELECT * FROM posts WHERE user_id in (...)
```

## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "ar_lazy_preload"
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
