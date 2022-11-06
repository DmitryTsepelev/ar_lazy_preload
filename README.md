# ArLazyPreload [![Cult Of Martians](http://cultofmartians.com/assets/badges/badge.svg)](https://cultofmartians.com/tasks/activerecord-lazy-preload.html) [![Gem Version](https://badge.fury.io/rb/ar_lazy_preload.svg)](https://rubygems.org/gems/ar_lazy_preload) [![Build Status](https://github.com/DmitryTsepelev/ar_lazy_preload/actions/workflows/rspec.yml/badge.svg)](https://github.com/DmitryTsepelev/ar_lazy_preload/actions/workflows/rspec.yml) [![Maintainability](https://api.codeclimate.com/v1/badges/00d04595661820dfba80/maintainability)](https://codeclimate.com/github/DmitryTsepelev/ar_lazy_preload/maintainability) [![Coverage Status](https://coveralls.io/repos/github/DmitryTsepelev/ar_lazy_preload/badge.svg?branch=master)](https://coveralls.io/github/DmitryTsepelev/ar_lazy_preload?branch=master) ![](https://ruby-gem-downloads-badge.herokuapp.com/ar_lazy_preload?type=total)

**ArLazyPreload** is a gem that brings association lazy load functionality to your Rails applications. There is a number of built-in methods to solve [N+1 problem](https://guides.rubyonrails.org/active_record_querying.html#eager-loading-associations), but sometimes a list of associations to preload is not obvious–this is when you can get most of this gem.

- **Simple**. The only thing you need to change is to use `#lazy_preload` instead of `#includes`, `#eager_load` or `#preload`
- **Fast**. Take a look at [performance benchmark](https://github.com/DmitryTsepelev/ar_lazy_preload/actions/workflows/bench.yml) and [memory benchmark](https://github.com/DmitryTsepelev/ar_lazy_preload/actions/workflows/memory.yml)
- **Perfect fit for GraphQL**. Define a list of associations to load at the top-level resolver and let the gem do its job
- **Auto-preload support**. If you don't want to specify the association list–set `ArLazyPreload.config.auto_preload` to `true`

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

> *Warning* : Using the `ArLazyPreload.config.auto_preload` feature makes ArLazyPreload try to preload *every* association target throughout your app, and in any other gem that makes association target calls. When enabling the setting in an existing app, you may find some edge cases where previous working queries now fail, and you should test most of your app paths to ensure that there are no such issues.

### Relation auto preloading

Another alternative for auto preloading is using relation `#preload_associations_lazily` method

```ruby
posts = User.preload_associations_lazily.flat_map(&:posts)
# => SELECT * FROM users LIMIT 10
# => SELECT * FROM posts WHERE user_id in (...)
```

## Gotchas

1. Lazy preloading [does not work](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/40/files) for ActiveRecord < 6 when `.includes` is called earlier:

  ```ruby
  Post.includes(:user).preload_associations_lazily.each do |p|
    p.user.comments.load
  end
  ```

2. When `#size` is called on association (e.g., `User.lazy_preload(:posts).map { |u| u.posts.size }`), lazy preloading won't happen, because `#size` method performs `SELECT COUNT()` database request instead of loading the association when association haven't been loaded yet ([here](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/42) is the issue, and [here](https://blazarblogs.wordpress.com/2019/07/27/activerecord-size-vs-count-vs-length/) is the explanation article about `size`, `length` and `count`).


## Installation

Add this line to your application's Gemfile, and you're all set:

```ruby
gem "ar_lazy_preload"
```

## Credits

Initially sponsored by [Evil Martians](http://evilmartians.com).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
