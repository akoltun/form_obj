# Change Log

## [v1.0.3](https://github.com/akoltun/form_obj/tree/v1.0.3) (2018-10-02)

[Full Changelog](https://github.com/akoltun/form_obj/compare/v1.0.2...v1.0.3)

**Merged pull requests:**

- Bugfix assigning subform [\#67](https://github.com/akoltun/form_obj/pull/67) ([akoltun](https://github.com/akoltun))

## [v1.0.2](https://github.com/akoltun/form_obj/tree/v1.0.2) (2018-08-14)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v1.0.1...v1.0.2)

**Closed issues:**

- Correct persisted? behaviour in accord with ActiveRecord [\#65](https://github.com/akoltun/form_obj/issues/65)

**Merged pull requests:**

- Fix persisted behaviour [\#66](https://github.com/akoltun/form_obj/pull/66) ([akoltun](https://github.com/akoltun))

## [v1.0.1](https://github.com/akoltun/form_obj/tree/v1.0.1) (2018-07-19)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v1.0.0...v1.0.1)

**Merged pull requests:**

- FormObj::Form do not raise by default on non-existent attributes update [\#64](https://github.com/akoltun/form_obj/pull/64) ([akoltun](https://github.com/akoltun))

## [v1.0.0](https://github.com/akoltun/form_obj/tree/v1.0.0) (2018-07-11)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v0.5.0...v1.0.0)

**Implemented enhancements:**

- Add parameters :read\_from\_model and :write\_to\_model [\#27](https://github.com/akoltun/form_obj/issues/27)

**Fixed bugs:**

- Create new FormObj::Form with \_destroy: true raises [\#43](https://github.com/akoltun/form_obj/issues/43)

**Closed issues:**

- Rewrite Reference Guide [\#59](https://github.com/akoltun/form_obj/issues/59)
- Rearrange Table of Content [\#58](https://github.com/akoltun/form_obj/issues/58)
- Redesign array.update\_attributes similar to array.sync\_to\_model\(s\) [\#47](https://github.com/akoltun/form_obj/issues/47)
- Add example of custom ModelMapper.sync\_to\_model\(s\) [\#45](https://github.com/akoltun/form_obj/issues/45)
- Add tests for method inspect  [\#44](https://github.com/akoltun/form_obj/issues/44)
- Rewrite FormObj::ModelMapper tests in Minitest [\#36](https://github.com/akoltun/form_obj/issues/36)
- Redesign deletion of arrayed form object in sync\_to\_model\(s\) [\#17](https://github.com/akoltun/form_obj/issues/17)
- Overwritebility for :append, :update and :delete actions in :sync\_to\_model\(s\) for arrayed form objects [\#16](https://github.com/akoltun/form_obj/issues/16)

**Merged pull requests:**

- Prepare documentation for release [\#63](https://github.com/akoltun/form_obj/pull/63) ([akoltun](https://github.com/akoltun))
- Add read from model and write to model [\#62](https://github.com/akoltun/form_obj/pull/62) ([akoltun](https://github.com/akoltun))
- Correct load\_from\_model\(s\) tests [\#61](https://github.com/akoltun/form_obj/pull/61) ([akoltun](https://github.com/akoltun))
- Rewrite reference guide [\#60](https://github.com/akoltun/form_obj/pull/60) ([akoltun](https://github.com/akoltun))
- Customize sync to models [\#57](https://github.com/akoltun/form_obj/pull/57) ([akoltun](https://github.com/akoltun))
- Refactor sync\_to\_models [\#56](https://github.com/akoltun/form_obj/pull/56) ([akoltun](https://github.com/akoltun))
- Add class methods load\_from\_model\(s\) [\#55](https://github.com/akoltun/form_obj/pull/55) ([akoltun](https://github.com/akoltun))
- Add load\_from\_model\(s\) as class methods [\#54](https://github.com/akoltun/form_obj/pull/54) ([akoltun](https://github.com/akoltun))
- Correct documentation in README [\#53](https://github.com/akoltun/form_obj/pull/53) ([akoltun](https://github.com/akoltun))
- Improve inspect method [\#52](https://github.com/akoltun/form_obj/pull/52) ([akoltun](https://github.com/akoltun))
- Test that update\_attributes returns itself [\#51](https://github.com/akoltun/form_obj/pull/51) ([akoltun](https://github.com/akoltun))
- Redesign update attributes [\#50](https://github.com/akoltun/form_obj/pull/50) ([akoltun](https://github.com/akoltun))
- Add update non existent attribute tests [\#49](https://github.com/akoltun/form_obj/pull/49) ([akoltun](https://github.com/akoltun))
- Fix wrong primary key test [\#48](https://github.com/akoltun/form_obj/pull/48) ([akoltun](https://github.com/akoltun))
- Redesign sync arrays to model [\#46](https://github.com/akoltun/form_obj/pull/46) ([akoltun](https://github.com/akoltun))
- Move tests from rspec to minitests and delete rspec [\#42](https://github.com/akoltun/form_obj/pull/42) ([akoltun](https://github.com/akoltun))
- Small refactor [\#41](https://github.com/akoltun/form_obj/pull/41) ([akoltun](https://github.com/akoltun))

## [v0.5.0](https://github.com/akoltun/form_obj/tree/v0.5.0) (2018-06-14)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v0.4.0...v0.5.0)

**Implemented enhancements:**

- Initialize FormObj::Struct with hash of attribute values [\#15](https://github.com/akoltun/form_obj/issues/15)
- Redesign deletion FormObj::Form in array in FormObj::Form.update\_attribute method [\#11](https://github.com/akoltun/form_obj/issues/11)
- Unify "model\_attribute: false" behaviour [\#7](https://github.com/akoltun/form_obj/issues/7)

**Closed issues:**

- Rewrite FormObj::Form tests in Minitest [\#30](https://github.com/akoltun/form_obj/issues/30)
- Add to documentation and tests the description of :default parameter [\#23](https://github.com/akoltun/form_obj/issues/23)
- Move update\_attributes method to FormObj::Struct class [\#14](https://github.com/akoltun/form_obj/issues/14)
- Overwritebility for :append, :update and :delete actions in update\_attributes for arrayed form objects [\#10](https://github.com/akoltun/form_obj/issues/10)
- Transform initialization or `update\_attributes` hash into HashWithIndifferentAccess before applying its values. [\#5](https://github.com/akoltun/form_obj/issues/5)

**Merged pull requests:**

- Redesign model mapper: load\_from\_models [\#40](https://github.com/akoltun/form_obj/pull/40) ([akoltun](https://github.com/akoltun))
- Migrate FormObj::Form tests to minitest [\#39](https://github.com/akoltun/form_obj/pull/39) ([akoltun](https://github.com/akoltun))
- Refactor form update attributes [\#38](https://github.com/akoltun/form_obj/pull/38) ([akoltun](https://github.com/akoltun))
- Refactor FormObj::Struct so update\_attributes behaviour could be easily overwritten in descendants [\#37](https://github.com/akoltun/form_obj/pull/37) ([akoltun](https://github.com/akoltun))
- Rework struct documentation [\#35](https://github.com/akoltun/form_obj/pull/35) ([akoltun](https://github.com/akoltun))
- Transform initialization or `update\_attributes` hash into HashWithInd… [\#34](https://github.com/akoltun/form_obj/pull/34) ([akoltun](https://github.com/akoltun))
- Add test and doc for default parameter [\#33](https://github.com/akoltun/form_obj/pull/33) ([akoltun](https://github.com/akoltun))
- Run minitests against all ruby and rails versions. Do not tests again… [\#32](https://github.com/akoltun/form_obj/pull/32) ([akoltun](https://github.com/akoltun))
- Migrate struct tests from rspec to minitest [\#31](https://github.com/akoltun/form_obj/pull/31) ([akoltun](https://github.com/akoltun))
- Move update attributes to FormObj::Struct [\#29](https://github.com/akoltun/form_obj/pull/29) ([akoltun](https://github.com/akoltun))
- Unify model\_attribute: false behaviour [\#28](https://github.com/akoltun/form_obj/pull/28) ([akoltun](https://github.com/akoltun))

## [v0.4.0](https://github.com/akoltun/form_obj/tree/v0.4.0) (2018-06-04)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v0.3.0...v0.4.0)

**Fixed bugs:**

- Avoid duplication of attributes [\#12](https://github.com/akoltun/form_obj/issues/12)

**Closed issues:**

- Refactor definition of class methods in FormObj::Form [\#24](https://github.com/akoltun/form_obj/issues/24)
- Merge tree\_struct gem [\#13](https://github.com/akoltun/form_obj/issues/13)
- Rename car model in the documentation and tests into something else [\#9](https://github.com/akoltun/form_obj/issues/9)
- Rename Mappable into ModelMapper [\#8](https://github.com/akoltun/form_obj/issues/8)
- Add form builder usage example [\#6](https://github.com/akoltun/form_obj/issues/6)
- Add description of :raise\_if\_not\_found parameter [\#4](https://github.com/akoltun/form_obj/issues/4)
- Rename method save\_to\_model\(s\) into sync\_to\_model\(s\) [\#3](https://github.com/akoltun/form_obj/issues/3)
- Rename hash: true parameter into model\_hash: true [\#2](https://github.com/akoltun/form_obj/issues/2)

**Merged pull requests:**

- Define class methods in FormObj::Form using class \<\< self [\#26](https://github.com/akoltun/form_obj/pull/26) ([akoltun](https://github.com/akoltun))
- Bug fix: Avoid attribute duplication [\#25](https://github.com/akoltun/form_obj/pull/25) ([akoltun](https://github.com/akoltun))
- Renaming [\#22](https://github.com/akoltun/form_obj/pull/22) ([akoltun](https://github.com/akoltun))
- Merge tree struct gem [\#21](https://github.com/akoltun/form_obj/pull/21) ([akoltun](https://github.com/akoltun))
- Update all dependencies to last versions [\#20](https://github.com/akoltun/form_obj/pull/20) ([akoltun](https://github.com/akoltun))
- Rename attribute model in test and docs [\#19](https://github.com/akoltun/form_obj/pull/19) ([akoltun](https://github.com/akoltun))
- Documentation update [\#18](https://github.com/akoltun/form_obj/pull/18) ([akoltun](https://github.com/akoltun))
- Updated the documentation [\#1](https://github.com/akoltun/form_obj/pull/1) ([wimcnice](https://github.com/wimcnice))

## [v0.3.0](https://github.com/akoltun/form_obj/tree/v0.3.0) (2018-05-15)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v0.2.0...v0.3.0)

## [v0.2.0](https://github.com/akoltun/form_obj/tree/v0.2.0) (2018-05-15)
[Full Changelog](https://github.com/akoltun/form_obj/compare/v0.1.0...v0.2.0)

## [v0.1.0](https://github.com/akoltun/form_obj/tree/v0.1.0) (2018-04-12)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*