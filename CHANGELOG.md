# Change log

## master

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
