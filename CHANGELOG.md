# Change log

## master

- [PR [#64](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/64)] Create context after `find_by`/`find_by!` when `auto_preload` is on ([@DmitryTsepelev][])

## 1.1.1 (2022-12-01 🤦‍♂️)

- [PR [#63](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/63)] Pass arguments to `.reload` ([@DmitryTsepelev][])

## 1.1.0 (2022-12-01)

- [PR [#61](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/61)] Initialize lazy context for newly created records when `auto_preload` is on ([@DmitryTsepelev][])

## 1.0.0 (2021-12-29 🎄🎅)

- [PR [#55](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/55)] Rails 7 support; removed some old Rails from CI, removed not supported Ruby versions ([@DmitryTsepelev][])

## 0.7.0 (2021-10-21)

- [PR [#53](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/53)] Avoid preloading associations with instance dependent scopes  ([@vala][])

## 0.6.2 (2021-05-18)

- [PR [#50](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/50)] Issue-49 fix - add prefix to owner attribute ([@RuslanKhabibullin][])

## 0.6.1 (2021-03-04)

- [PR [#48](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/48)] Fix deep nested includes ([@konalegi][])

## 0.6.0 (2020-11-18)

- [PR [#45](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/45)] Removed Rails 4 support ([@DmitryTsepelev][])

## 0.5.2 (2020-09-17)

- [PR [#39](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/39)] Fix error when trying to preload non-existent association on STI model ([@konalegi][])

## 0.5.1 (2020-08-28)

- [PR [#38](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/38)] Fix error when association relation spawned from relation with preload_associations_lazily called ([@PikachuEXE][])

## 0.5.0 (2020-08-27)

- [PR [#25](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/25)] Ruby 2.7 support ([@DmitryTsepelev][])

## 0.4.0 (2020-08-24)

- [PR [#36](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/36)] Feature preload_associations_lazily, allow turn on automatic preload only for given ActiveRecord::Relation ([@mpospelov][])

## 0.3.2 (2020-07-21)

- [PR [#33](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/34)] Feature skip_preload, allow turn automatic preload off ([@OuYangJinTing][])

## 0.3.1 (2020-07-10)

- [PR [#33](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/33)] Don't do merge if there is nothing to merge ([@Earendil95][])

## 0.3.0 (2020-05-08)

- [PR [#29](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/29)] Fix N+1 problem for `collection_ids` (aka collection_singular_ids) ([@zeitnot][])

## 0.2.7 (2020-05-05)

- [PR [#28](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/28)] Improve compatibility with ActiveRecord API for singular associations  ([@sandersiim][])

## 0.2.6 (2018-12-04)

- [PR [#20](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/20)] Cleanup context and active record patches ([@DmitryTsepelev][])
- [PR [#17](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/17)] Cleanup and simplify code ([@DmitryTsepelev][])
- [PR [#16](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/16)] Improve benchmark & performance  ([@PikachuEXE][])

## 0.2.5 (2018-11-29)

- [PR [#15](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/15)] Fix performance issue with benchmark ([@PikachuEXE][])

## 0.2.4 (2018-11-21)

- [PR [#14](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/14)] Fix deep association preloading when specified via array of hash  ([@PikachuEXE][])

## 0.2.3 (2018-11-20)

- [PR [#13](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/13)] Fix association loading when specified in hash inside array ([@PikachuEXE][])

## 0.2.2 (2018-11-15)

- [PR [#9](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/9)] Fix crash in CollectionProxy ([@PikachuEXE][])
- [PR [#10](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/10)] Test against edge rails version ([@DmitryTsepelev][])
- [PR [#7](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/7)] Test against main rails versions ([@PikachuEXE][])

## 0.2.0 (2018-09-18)

- [PR [#3](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/3)] Automatic preloading support ([@DmitryTsepelev][])
- [PR [#2](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/2)] Add RubyGems and CultOfMartians badges ([@palkan][])

## 0.1.1 (2018-08-08)

- [PR [#1](https://github.com/DmitryTsepelev/ar_lazy_preload/pull/1)] Cleanup code, fix initiating child context for preload associations ([@DmitryTsepelev][])

## 0.1.0 (2018-08-01)

- Initial version. ([@DmitryTsepelev][])

[@DmitryTsepelev]: https://github.com/DmitryTsepelev
[@palkan]: https://github.com/palkan
[@PikachuEXE]: https://github.com/PikachuEXE
[@sandersiim]: https://github.com/sandersiim
[@zeitnot]: https://github.com/zeitnot
[@Earendil95]: https://github.com/Earendil95
[@OuYangJinTing]: https://github.com/OuYangJinTing
[@konalegi]: https://github.com/konalegi
[@RuslanKhabibullin]: https://github.com/RuslanKhabibullin
[@vala]: https://github.com/vala
