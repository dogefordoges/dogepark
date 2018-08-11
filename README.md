# DogePark

Interactive web based wallet with other gadgets for Dogecoin. Inspired by http://www.dogerain.rocks/.

# Installation

Installation instructions for Ubuntu only
```
sudo apt-get install libpq-dev #For pg dependency
gem install bundler
bundle install
```

## Elm dependency

You will need to install elm
`npm install -g elm elm-package`

Then do `elm-package install`

# Usage

Start by compiling the Elm files into js with `ruby compile_elm.rb`, then run `ruby dogepark.rb`.

# Test

Run tests with rspec
```
rspec --format doc
```
