# Hubot Groupme

Groupme adapter for hubot

## Setup

Add this repo as a dependency of your Hubot repo: `"hubot-groupme": "git://github.com/adamedgett/hubot-groupme.git#master"`

And `npm install`

## Running
To use this adapter run hubot with the adapter argument
`./bin/hubot -a groupme`

### Configuration

Two environment variables must be set:

* `HUBOT_GROUPME_ROOM_IDS`: a string of GroupMe chat room IDs, separated by commas. ex: `"111222,333444"`
* `HUBOT_GROUPME_TOKEN`: a GroupMe access token. ex: `"mFKYryFoTjdPkKGd9shvjwnMunSSOLvhs44498Fc"`
* `HUBOT_GROUPME_BOT_ID`: a GroupMe bot ID token. ex: `"66J7ZcVwlRTqEQvdSLNnmV69wV"`

### Source

Forked from [cdzombak/hubot-groupme-http](https://github.com/cdzombak/hubot-groupme-http)
to support the updated Groupme V3 API