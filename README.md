# Hubot Groupme
[![npm](https://img.shields.io/npm/v/hubot-groupme.svg)](https://www.npmjs.com/package/hubot-groupme)

Groupme adapter for hubot

## Installation

In your hubot repo, run:
`npm install --save hubot-groupme`

## Running
To use this adapter run hubot with the adapter argument

`./bin/hubot -a groupme`

Or set the adapter environment variable

`export HUBOT_ADAPTER="groupme"`

### Configuration

Three environment variables must be set:

* `HUBOT_GROUPME_ROOM_ID`: a GroupMe chat room ID. ex: `"111222"`
* `HUBOT_GROUPME_TOKEN`: a GroupMe access token. ex: `"mFKYryFoTjdPkKGd9shvjwnMunSSOLvhs44498Fc"`
* `HUBOT_GROUPME_BOT_ID`: a GroupMe bot ID token. ex: `"66J7ZcVwlRTqEQvdSLNnmV69wV"`

### Source

Forked from [cdzombak/hubot-groupme-http](https://github.com/cdzombak/hubot-groupme-http)
to support the updated Groupme V3 API
