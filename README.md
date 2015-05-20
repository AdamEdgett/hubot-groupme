# Hubot Groupme
[![npm](https://img.shields.io/npm/v/hubot-groupme.svg)](https://www.npmjs.com/package/hubot-groupme)

Groupme adapter for hubot

## Installation

In your hubot repo, run:
`npm install --save hubot-groupme`

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
