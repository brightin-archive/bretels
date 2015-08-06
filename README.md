# Bretels

Bretels is the base Rails application used at [brightin](http://brightin.nl). Big thanks to [thoughtbot](http://thoughtbot.com) for providing such a great starting point.

  ![Suspenders boy](http://media.tumblr.com/1TEAMALpseh5xzf0Jt6bcwSMo1_400.png)

Installation
------------

First install the bretels gem:

    gem install bretels

Then run:

    bretels projectname

This will create a Rails 4.2 app in `projectname`. This script creates a
new git repository. It is not meant to be used against an existing repo.

Dependencies
------------

Some gems included have native extensions. You should have GCC
installed on your machine before generating an app with Suspenders.

Use [OS X GCC Installer](https://github.com/kennethreitz/osx-gcc-installer/) for
Snow Leopard (OS X 10.6).

Use [Command Line Tools for XCode](https://developer.apple.com/downloads/index.action)
for Lion (OS X 10.7) or Mountain Lion (OS X 10.8).

We use [Capybara Webkit](https://github.com/thoughtbot/capybara-webkit) for
full-stack Javascript integration testing. It requires QT. Instructions for
installing QT are
[here](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit).

PostgreSQL needs to be installed and running for the `db:create` rake task.
