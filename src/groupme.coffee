{Adapter,Robot,TextMessage} = require 'hubot'
HTTPS = require 'https'

class GroupMeBot extends Adapter

  # Send a message to the room
  #
  # envelope - A Object with message, room and user details.
  # strings  - One or more Strings for each message to send.
  send: (envelope, strings...) ->
    strings.forEach (str) =>
      if str.length > 450
        substrings = str.match /.{1,430}/g
        for text, index in substrings
          @sendMessage envelope.room, "(#{index}/#{substrings.length}) #{text}"
      else
        @sendMessage envelope.room, str

  # Send message to the room
  #
  # room_id - ID of room to send to
  # text - Text message to be sent to the room.
  sendMessage: (room_id, text) ->
    messageStruct =
      text: text
      bot_id: @bot_id

    json = JSON.stringify(messageStruct)
    console.log "[SENDING GROUPME] #{json}"

    options =
      agent: false
      host: 'api.groupme.com'
      port: 443
      method: 'POST'
      path: "/v3/bots/post"
      headers:
        'Content-Length': json.length,
        'Content-Type': 'application/json',
        'X-Access-Token': @token

    request = HTTPS.request options, (response) ->
      data = ''
      response.on 'data', (chunk)-> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
    request.end(json)

  # Replies to a message
  #
  # envelope - A Object with message, room and user details.
  # strings - One or more Strings for each reply to send.
  reply: (envelope, strings...) ->
    strings.forEach (str) =>
      @send envelope, "#{envelope.user}: #{str}"

  # Sets a topic on the room
  #
  # envelope - A Object with message, room and user details.
  # strings - One more more Strings to set as the topic.
  topic: (envelope, strings...) ->
    strings.forEach (str) =>
      if str.length > 440
        str = str.substring(0,440)
      str = "/topic #{str}"
      @send envelope, str

  run: ->
    @room_id = process.env.HUBOT_GROUPME_ROOM_ID
    @token    = process.env.HUBOT_GROUPME_TOKEN
    @bot_id   = process.env.HUBOT_GROUPME_BOT_ID

    @newest_timestamp = 0

    @timer = setInterval =>
      @getMessages @room_id, (messages) =>
        messages = messages.sort (a, b) ->
          -1 if a.created_at < b.created_at
          1 if a.created_at > b.created_at
          0

        # this is a hack, but basically, just assume we get messages in linear time
        # I don't want to RE GroupMe's web push API right now.
        for msg in messages
          if msg.created_at <= @newest_timestamp
            continue

          @newest_timestamp = msg.created_at

          # note that the name assigned to your robot in GroupMe must exactly match the name passed to Hubot
          if msg.text and (msg.created_at * 1000) > new Date().getTime() - 6*1000 and msg.name != @robot.name
            console.log "[RECEIVED in #{@room_id}] #{msg.name}: #{msg.text}"
            envelope =
              user: msg.name
              room: @room_id
            @receive new TextMessage envelope, msg.text
    , 2000

    @emit 'connected'

  # Shuts the bot down
  close: ->
    clearInterval(@timer)

  # Gets messages from the GroupMe room
  # Calls the callback with the latest 20 messages on completion.
  #
  # room_id - ID of room to get messages for
  # cb - Callback which takes an array of GroupMe message objects
  getMessages: (room_id, cb) =>
    options =
      agent: false
      host: 'api.groupme.com'
      port: 443
      method: 'GET'
      path: "/v3/groups/#{room_id}/messages"
      headers:
        'Content-Type': 'application/json',
        'X-Access-Token': @token

    request = HTTPS.request options, (response) =>
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', =>
        if data
          json = JSON.parse(data)
          cb(json.response.messages)
    request.end()

exports.use = (robot) ->
  new GroupMeBot robot
