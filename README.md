# Onesky::Rails

[![Build Status](https://travis-ci.org/onesky/onesky-rails.svg)](https://travis-ci.org/onesky/onesky-rails)

Integrate Rails app with [OneSky](http://www.oneskyapp.com) that provide `upload` and `download` rake command to sync string files

## Installation

Add this line to your application's Gemfile:

    gem 'onesky-rails'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install onesky-rails

## Usage

**Basic setup**
```
rails generate onesky:init <api_key> <api_secret> <project_id>
```
Generate config file at `config/onesky.yml`

**Upload string files**
```
rake onesky:upload
```
Upload all string files of `I18n.default_locale` to [OneSky](http://www.oneskyapp.com). Note that default locale must match with base language of project.

**Download translations**
```
rake onesky:download
```
Download translations of files uploaded in all languages activated in project other than the base language.

**Download base language translations**
```
rake onesky:download_base
```
Download translations of files uploaded only for the base language.

**Download all languages translations**
```
rake onesky:download_all
```
Download translations of files uploaded for all the languages including the base language.

## TODO
- Specify file to upload
- Specify file and language to download
- Support different backend

## Contributing

1. Fork it ( http://github.com/onesky/onesky-rails/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
