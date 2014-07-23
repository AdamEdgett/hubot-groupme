# Hubot Groupme

Groupme adapter for hubot

### Source

Forked from cdzombak/hubot-groupme-http
to support the updated Groupme V3 API

## Setup

Add this repo as a dependency of your Hubot repo: `"hubot-groupme": "git://github.com/adamedgett/hubot-groupme.git#master"`

And `npm install`

### Configuration

Two environment variables must be set:

* `HUBOT_GROUPME_ROOM_IDS`: a string of GroupMe chat room IDs, separated by commas. ex: `"111222,333444"`
* `HUBOT_GROUPME_TOKEN`: a GroupMe access token. ex: `"mFKYryFoTjdPkKGd9shvjwnMunSSOLvhs44498Fc"`