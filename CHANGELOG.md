29.07.2025
* Replace codeclimate with qlty tool https://github.com/internetee/whois/pull/175

24.07.2025
* Refactor domain name validation https://github.com/internetee/whois/pull/179

21.07.2025
* Enable searching 1-letter domains https://github.com/internetee/whois/pull/173

21.05.2025
* Dockerfiles update https://github.com/internetee/whois/pull/170

06.03.2025
* Refactored `receive_data` method to reduce complexity by extracting logic into separate methods.
* Separated logging functionality into a new `Logging` module for better code organization.
* Changed logging format to JSON for better structured logging and improved log analysis
* Updated Ruby version to 3.4.2 and updated dependencies
* Updated test workflow to use Ruby 3.4.2 and Ubuntu 24.04

22.12.2022
* Disclose additional registrant data https://github.com/internetee/whois/pull/131
* monkey yaml patching https://github.com/internetee/whois/pull/137
* Update actions/upload-artifact action to v3.1.1 https://github.com/internetee/whois/pull/135

23.11.2022
* Configure Renovate by @renovate in https://github.com/internetee/whois/pull/110
* Update dependency ruby to v3.0.2 by @renovate in https://github.com/internetee/whois/pull/112
* Revert "Update dependency ruby to v3.0.2" by @keijoraamat in https://github.com/internetee/whois/pull/113
* Build and deploy on pr by @keijoraamat in https://github.com/internetee/whois/pull/114
* Update dependency ruby to v3.1.0 by @renovate in https://github.com/internetee/whois/pull/117
* Update dependency pg to ~> 1.3.0 by @renovate in https://github.com/internetee/whois/pull/116
* Closes ports after closing pr by @keijoraamat in https://github.com/internetee/whois/pull/120
* Update dependency ruby to v3.1.1 by @renovate in https://github.com/internetee/whois/pull/121
* Update dependency activerecord to v7 by @renovate in https://github.com/internetee/whois/pull/119
* Update actions/checkout action to v3 by @renovate in https://github.com/internetee/whois/pull/122
* Update actions/download-artifact action to v3 by @renovate in https://github.com/internetee/whois/pull/123
* Update actions/upload-artifact action to v3 by @renovate in https://github.com/internetee/whois/pull/124
* Update dependency ruby to v3.1.2 by @renovate in https://github.com/internetee/whois/pull/125
* Change renovate config to delay ruby version updates by @thiagoyoussef in https://github.com/internetee/whois/pull/126
* Update actions/upload-artifact action to v3.1.0 by @renovate in https://github.com/internetee/whois/pull/127
* Update dependency pg to ~> 1.4.0 by @renovate in https://github.com/internetee/whois/pull/128
* Update dependency activerecord to v7.0.3.1 [SECURITY] by @renovate in https://github.com/internetee/whois/pull/130
* Update postgres Docker tag to v14 by @renovate in https://github.com/internetee/whois/pull/132
* Update actions/download-artifact action to v3.0.1 by @renovate in https://github.com/internetee/whois/pull/134

31.08.2021
* Bump rubocop to 1.20.0 [#108](https://github.com/internetee/whois/pull/108)
* Bump daemons to 1.4.1 [#109](https://github.com/internetee/whois/pull/109)

25.08.2021
* Bump mina to 1.2.4 [#104](https://github.com/internetee/whois/pull/104)
* Bump activerecord to 6.1.4.1 [#106](https://github.com/internetee/whois/pull/106)
* Bump rubocop to 1.19.1 [#107](https://github.com/internetee/whois/pull/107)

28.07.2021
* Bump rubocop to 1.18.4 [#103](https://github.com/internetee/whois/pull/103)

06.07.2021
* Bump rubocob to 1.18.2 [#101](https://github.com/internetee/whois/pull/101)

29.06.2021
* Bump activerecord to 6.1.4 [#100](https://github.com/internetee/whois/pull/100)

17.06.2021
* Bump rubocom to 1.16.1 [#98](https://github.com/internetee/whois/pull/98)

08.06.2021
* Ruby update to 3.0.1 [#97](https://github.com/internetee/whois/pull/97)
* Bump simplecov to 0.21.2 [#71](https://github.com/internetee/whois/pull/71)
* Bump pg to 1.2.3 [#72](https://github.com/internetee/whois/pull/72)
* Bump minitest to 5.14.4 [#73](https://github.com/internetee/whois/pull/73)
* Bump dotenv to 2.7.6 [#74](https://github.com/internetee/whois/pull/74)
* Bump eventmachine to 1.2.7 [#83](https://github.com/internetee/whois/pull/83)
* Bump mina to 1.2.3 [#86](https://github.com/internetee/whois/pull/86)
* Bump pry to 0.14.1 [#87](https://github.com/internetee/whois/pull/87)
* Bump simpleidn to 0.2.1 [#89](https://github.com/internetee/whois/pull/89)
* Bump dameons to 1.4.0 [#91](https://github.com/internetee/whois/pull/91)
* Bump activerecord to 6.1.3.2 [#92](https://github.com/internetee/whois/pull/92)
* Bump rubocop to 1.16.0 [#96](https://github.com/internetee/whois/pull/96)
* CI task trigger cleanup [#95](https://github.com/internetee/whois/pull/95)

28.10.2020
* Multi-language disclaimer for whois responses [#66](https://github.com/internetee/whois/pull/66)

12.06.2020
* Removed SysLogger gem, stdlib used instead [#47](https://github.com/internetee/whois/issues/47)

22.05.2020
* New disputed status for domains in disputed domains list [#15](https://github.com/internetee/whois/issues/15)

11.05.2020
* Auction process due dates are now available over whois and rest-whois [#64](https://github.com/internetee/whois/pull/64)

09.04.2020
* Better error message for 1 letter and invalid domain searches [#55](https://github.com/internetee/whois/issues/55)

12.03.2020
* Ruby upgrade to 2.6.5 [#58](https://github.com/internetee/whois/issues/58)

04.03.2020
* Bumped rake to 13.0.1 [#56](https://github.com/internetee/whois/pull/56)

10.05.2019
* Registrar postal address is removed [#52](https://github.com/internetee/whois/pull/52)

25.03.2019
* Added statuses for domainauctions [#48](https://github.com/internetee/whois/pull/48)
* Removed migrations library [#50](https://github.com/internetee/whois/pull/50)

11.02.2019
* Enable disclosable contact data [#44](https://github.com/internetee/whois/pull/44)
* Removed some unused files [#45](https://github.com/internetee/whois/pull/45)

06.12.2018
* Rack update (CVE-2018-16471) [#41](https://github.com/internetee/whois/pull/41)
* Remove unused Json key [#40](https://github.com/internetee/whois/pull/40)

05.11.2018
* Ruby update 2.4.5 [#35](https://github.com/internetee/whois/pull/35)
* Loofah update 2.2.3 [#36](https://github.com/internetee/whois/pull/36)

15.10.2018
* Nokogiri update 1.8.5 [#33](https://github.com/internetee/whois/pull/33)

08.09.2018
* Upgrade Ruby to 2.4.4 [#31](https://github.com/internetee/whois/pull/31)

05.09.2018
* Added dockerfile [#29](https://github.com/internetee/whois/pull/29)

25.05.2018
* GDPR update - hide contact data of private registrations [#24](https://github.com/internetee/whois/issues/24)
* GDPR update - move admin and tech contact data of business registration behind recaptcha [#26](https://github.com/internetee/whois/issues/26)
* Simplify WHOIS db structure [#25](https://github.com/internetee/whois/issues/25)
* Update loofah gem to version 2.2.2 [#22](https://github.com/internetee/whois/pull/22)
* Update nokogiri to version 1.8.2 [#23](https://github.com/internetee/whois/pull/23)

03.11.2016
* validate input to be legal utf-8

15.06.2016
* added syslogger

20.07.2015
* Example mina/deploy.rb renamed to mina/deploy-example.rb in order to not overwrite local deploy scripts

26.05.2015
* Updated deploy script, now staging comes from staging branch

12.05.2015
* ruby version updated to 2.2.2
