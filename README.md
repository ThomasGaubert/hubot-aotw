# hubot-aotw
[![Build Status](https://travis-ci.org/ThomasGaubert/hubot-aotw.svg?branch=master)](https://travis-ci.org/ThomasGaubert/hubot-aotw)

Track and manage the album of the week.

## Usage

* `aotw current` - view the current AOTW *
* `aotw debug <about|data|submit url|update>` - debugging tools *~
* `aotw help` - display AOTW help
* `aotw history [length]` - view all historical AOTWs, optionally limited to `[length]` *
* `aotw nominate <url>` - nominate an album *
* `aotw nominations [length]` - view all current nominations, optionally limited to `[length]` *
* `aotw reset` - reset all AOTW data * ~
* `aotw select [nomination index]` - select the AOTW (of given index or random) and reset nominations * ~

Commands denoted by * are restricted to specific channels, ~ are limited to AOTW admins.

## Installation

Run the following command:

    $ npm install hubot-aotw

Then to make sure the dependencies are installed:

    $ npm install

To enable the script, add a `hubot-aotw` entry to the `external-scripts.json`
file (you may need to create this file).

    ["hubot-aotw"]
