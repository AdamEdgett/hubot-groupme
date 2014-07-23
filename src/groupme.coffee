# resurrected/hacked from https://github.com/github/hubot/blob/f5c2bedcaeb70b7276efb7b2dbe27779cf0a3058/src/hubot/groupme.coffee

{Adapter,Robot,TextMessage} = require '../../../../hubot'
HTTPS = require 'https'

class GroupMeBot extends Adapter

  # Public: Raw method for sending data back to the chat source. Extend this.
  #
  # envelope - A Object with message, room and user details.
  # strings  - One or more Strings for each message to send.
  #
  # Returns nothing.
  send: (user, strings...) ->
    strings.forEach (str) =>
      # disabling image upload until I get the basic stuff together
      #if str.match(/(png|jpg)$/i)
      #  @upload_image str, (url) =>
      #    @send_message picture_url: url
      #else
      #  @send_message text:str
      if str.length > 450
        substrings = str.match /.{1,430}/g
        for text, index in substrings
          @send_message user.room_id, "(#{index}/#{substrings.length}) #{text}"
      else
        @send_message user.room_id, str

  # Public: Raw method for building a reply and sending it back to the chat
  # source. Extend this.
  #
  # envelope - A Object with message, room and user details.
  # strings - One or more Strings for each reply to send.
  #
  # Returns nothing.
  reply: (user, strings...) ->
    strings.forEach (str) =>
      @send user, "#{user.name}: #{str}"

  # Public: Raw method for setting a topic on the chat source. Extend this.
  #
  # envelope - A Object with message, room and user details.
  # strings - One more more Strings to set as the topic.
  #
  # Returns nothing.
  topic: (envelope, strings...) ->
    strings.forEach (str) =>
      if str.length > 440
        str = str.substring(0,440)
      str = "/topic #{str}"
      @send_message user.room_id, str

  # Public: Raw method for invoking the bot to run. Extend this.
  #
  # Returns nothing.
  run: ->
    @room_ids = process.env.HUBOT_GROUPME_ROOM_IDS.split(',')
    @token    = process.env.HUBOT_GROUPME_TOKEN
    @bot_id   = process.env.HUBOT_GROUPME_BOT_ID

    @newest_timestamp = { }
    for room in @room_ids
      @newest_timestamp[room] = 0

    @timer = setInterval =>
      @room_ids.forEach (room) =>
        @fetch_messages room, (messages) =>
          messages = messages.sort (a, b) ->
            -1 if a.created_at < b.created_at
            1 if a.created_at > b.created_at
            0

          # this is a hack, but basically, just assume we get messages in linear time
          # I don't want to RE GroupMe's web push API right now.
          for msg in messages
            if msg.created_at <= @newest_timestamp[room]
              continue

            @newest_timestamp[room] = msg.created_at

            # note that the name assigned to your robot in GroupMe must exactly match the name passed to Hubot
            if msg.text and (msg.created_at * 1000) > new Date().getTime() - 6*1000 and msg.name != @robot.name
              console.log "[RECEIVED in #{room}] #{msg.name}: #{msg.text}"
              userInfo =
                name: msg.name
                room_id: room
              @receive new TextMessage userInfo, msg.text
    , 2000

    @emit 'connected'

  # Public: Raw method for shutting the bot down. Extend this.
  #
  # Returns nothing.
  close: ->
    clearInterval(@timer)

  # Private: send a message to the GroupMe room
  #
  # room_id - ID of room to send to
  # text - Text message to be sent to the room.
  #
  # Returns nothing.
  send_message: (room_id, text) ->
    messageStruct =
      #message:
        text: text
        bot_id: @bot_id
        #source_guid: @generate_guid()

    json = JSON.stringify(messageStruct)
    console.log "[SENDING GROUPME] ", json

    options =
      agent: false
      host: 'api.groupme.com'
      port: 443
      method: 'POST'
      #path: "/v3/groups/#{room_id}/messages"
      path: "/v3/bots/post"
      headers:
        'Content-Length': json.length
        'Content-Type': 'application/json'
        'Accept': 'application/json, text/javascript',
        'Accept-Charset': 'ISO-8859-1,utf-8',
        'Accept-Language': 'en-US',
        'Origin': 'https://web.groupme.com',
        'Referer': "https://web.groupme.com/groups/#{room_id}",
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.45 Safari/537.22',
        'X-Access-Token': @token

    request = HTTPS.request options, (response) ->
      data = ''
      response.on 'data', (chunk)-> data += chunk
      response.on 'end', ->
        console.log "[GROUPME RESPONSE] ", data
    request.end(json)

  # Private: fetch messages from the GroupMe room
  # Calls your callback with the latest 20 messages on completion.
  #
  # room_id - ID of room to fetch messages for
  # cb - Callback which takes an array of GroupMe message objects
  #
  # Returns nothing.
  fetch_messages: (room_id, cb) =>
    options =
      agent: false
      host: 'api.groupme.com'
      port: 443
      method: 'GET'
      path: "/v3/groups/#{room_id}/messages"
      headers:
        'Accept': 'application/json, text/javascript',
        'Accept-Charset': 'ISO-8859-1,utf-8',
        'Accept-Language': 'en-US',
        'Content-Type': 'application/json',
        'Origin': 'https://web.groupme.com',
        'Referer': "https://web.groupme.com/groups/#{room_id}",
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.22 (KHTML, like Gecko) Chrome/25.0.1364.45 Safari/537.22',
        'X-Access-Token': @token

    request = HTTPS.request options, (response) =>
      data = ''
      response.on 'data', (chunk) -> data += chunk
      response.on 'end', =>
        if data
          json = JSON.parse(data)
          cb(json.response.messages)
    request.end()

  # Private: Generate a GroupMe GUID for a message
  #
  # Returns a new GUID string.
  generate_guid: ->
    "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (curDigit) ->
      randNum = Math.floor(Math.random() * 16)
      randNum.toString(16) if curDigit is "x"
      (randNum & 3 | 8).toString(16)

exports.use = (robot) ->
  new GroupMeBot robot
