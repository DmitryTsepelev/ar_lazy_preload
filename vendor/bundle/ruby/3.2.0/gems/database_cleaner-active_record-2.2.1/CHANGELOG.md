# Development (unreleased)

## v2.2.1 2025-05-13

* https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/111 by @tagliala
* https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/104 by @fatkodima
* https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/118 by @pat, @thegeorgeous, and @nnishimura

## v2.2.0 2024-07-12

* Fix "ERROR:  currval of sequence" in Postgres adapter: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/103
* Use lock synchronize on transaction callback: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/73
* Stop testing with EOLed Ruby & Rails versions: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/105
* Fix compatibility issue with Rails 7.2: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/107
* Fix typo in truncation methods: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/94/files
* Address deprecation of ActiveRecord::Base.connection in Rails 7.2: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/102
* Support Rails 7.2+: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/101
* Fix reset_ids test with Trilogy adapter: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/93
* Implement resetting ids for deletion strategy: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/71
* Avoid loading ActiveRecord::Base early: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/91
* Fix specs to account for trilogy: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/88
* Add basic support for trilogy: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/85

## v2.1.0 2023-02-17

* Add Ruby 3.2 to CI matrix: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/79
* Add Rails 7.1 support: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/78
* Add WHERE clause to make `ruby-spanner-activerecord` happy: https://github.com/DatabaseCleaner/database_cleaner-active_record/pull/77