{Adapter,Robot,TextMessage} = require 'hubot'
HTTPS = require 'https'

class GroupMeBot extends Adapter

  # Send a message to the room
  #
  # envelope - A Object with message, room and user details.
  # strings  - One or more Strings for each message to send.
  send: (envelope, strings...) ->
    strings.forEach (str) =>
      if str.length > 999
        substrings = str.match /.{1,950}/g
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
      @send envelope, "#{envelope.user.name}: #{str}"

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

    @getUsers @room_id, (response) =>
      for user in response.members
        user.name = user.nickname
        if user.user_id of @robot.brain.data.users
          oldUser = @robot.brain.data.users[user.user_id]
          for key, value of oldUser
            unless key of user
              user[key] = value
          delete @robot.brain.data.users[user.user_id]
        @robot.brain.userForId(user.user_id, user)

    @getBots (bots) =>
      bot = (bot for bot in bots when bot.bot_id == @bot_id)[0]
      @robot.name = bot.name

    @message_count = 0

    @timer = setInterval =>
      @getMessages @room_id, (response) =>
        if response.count > @message_count
          @message_count = response.count
          msg = response.messages[0]

          # note that the name assigned to your robot in GroupMe must exactly match the name passed to Hubot
          if msg.text and msg.name != @robot.name
            console.log "[RECEIVED in #{@room_id}] #{msg.name}: #{msg.text}"
            user = @robot.brain.userForId(msg.user_id)
            user.room = @room_id
            @receive new TextMessage user, msg.text, msg.id
    , 2000

    @emit 'connected'

  # Shuts the bot down
  close: ->
    clearInterval(@timer)

  # Gets users in the GroupMe room
  getUsers: (room_id, cb) ->
    @get("/v3/groups/#{room_id}", cb)

  # Gets bots for the GroupMe token
  getBots: (cb) ->
    @get('/v3/bots', cb)

  # Gets messages from the GroupMe room
  getMessages: (room_id, cb) =>
    @get("/v3/groups/#{room_id}/messages", cb)

  get: (path, cb) =>
    options =
      agent: false
      host: 'api.groupme.com'
      port: 443
      method: 'GET'
      path: path
      headers:
        'Content-Type': 'application/json',
        'X-Access-Token': @token

    request = HTTPS.request options, (response) ->
      data = ''
      response.on 'data', (chunk)-> data += chunk
      response.on 'end', ->
        if process.env.HUBOT_LOG_LEVEL == "debug"
          console.log "[GROUPME RESPONSE] #{response.statusCode} #{data}"
        if data
          json = JSON.parse(data)
          cb(json.response)
    request.end()

exports.use = (robot) ->
  new GroupMeBot robot
