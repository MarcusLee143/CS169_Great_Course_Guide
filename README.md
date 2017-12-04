## CS169 Great Course Guide

A SaaS application project for CS169 Software Engineering at the University of California, Berkeley.
This application, proposed by [David Patterson](https://www2.eecs.berkeley.edu/Faculty/Homepages/patterson.html), provides 
information to help students select upcoming courses based on professor reputation.

### Setup

Simply clone this repo, go into the root directory of the project and run bundler to get things started.
```shell
git clone https://github.com/saasbook/CS169_Great_Course_Guide.git (or whichever fork you are developing on)
cd CS169_Great_Course_Guide/
bundle install --without production
```

Run Cucumber BDD tests with
```
cucumber
```

Run RSpec TDD tests with
```
rspec
```

If developing on Cloud9 (c9.io), run tests with `bundle exec` as well.

Locally startup the web application with
```
rails s
```
and point your browser to localhost:3000 to make sure things look good. For the time being, this does not work with Cloud9 due to the CAS login system currently implemented.

If you don't have them, find installers for things here:
Rails - http://installrails.com (also includes setup for Git, Gems, Bundler, Ruby and RVM)
RubyGems - https://rubygems.org/pages/download
Bundler - `gem install bundler` http://bundler.io

### Deployment

Great Course Guide is deployed on [Heroku](https://cs169-great-course-guide.herokuapp.com/)

### Trackers and Testers

[Pivotal Tracker](https://www.pivotaltracker.com/n/projects/1541787)

[<img src="https://api.travis-ci.org/MarcusLee143/CS169_Great_Course_Guide.svg"/>](https://travis-ci.org/MarcusLee143/CS169_Great_Course_Guide)

[![Maintainability](https://api.codeclimate.com/v1/badges/cff679349717ecec648d/maintainability)](https://codeclimate.com/github/MarcusLee143/CS169_Great_Course_Guide/maintainability)

[![Test Coverage](https://api.codeclimate.com/v1/badges/cff679349717ecec648d/test_coverage)](https://codeclimate.com/github/MarcusLee143/CS169_Great_Course_Guide/test_coverage)

[![Coverage Status](https://coveralls.io/repos/github/MarcusLee143/CS169_Great_Course_Guide/badge.svg?branch=master)](https://coveralls.io/github/MarcusLee143/CS169_Great_Course_Guide?branch=master)
