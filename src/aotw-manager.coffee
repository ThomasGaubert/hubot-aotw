# Description:
#   Helper class for hubot-aotw.
#
# Dependencies:
#
# Configuration:
#
# Commands:
#
# Author:
#   Thomas Gaubert

class AotwManager
  constructor: (@robot) ->
    storageLoaded = =>
      @storage = @robot.brain.data.aotw ||= {
        nominations: []
        history: []
      }

      @robot.logger.debug "AOTW data loaded: " + JSON.stringify(@storage)

    # Define channels to which commands denoted by an astrisk are limited.
    # If left blank, commands can be run within any channel.
    @channels = ["bots", "music", "bot-testing", "Shell"]

    # Restrict commands denoted by a tilde to the following users.
    # If left empty, any user can issue restricted commands.
    @admins = ["colt", "thomas", "stevendiaz", "Shell"]

    # Tracks if updates have been downloaded since last reboot
    @downloaded_updates = false

    @robot.brain.on "loaded", storageLoaded
    storageLoaded()

  save = ->
    @robot.logger.debug "Saving AOTW data: " + JSON.stringify(@storage)
    @robot.brain.emit 'save'

  reset: ->
    @storage.nominations = []
    @storage.history = []
    @save

  nominate: (user, url) ->
    try
      @storage.nominations.push(user: user, url: url)
    catch
      @storage.nominations = []
      @storage.nominations.push(user: user, url: url)
    finally
      @save
    return {user: user, url: url}

  select: (index) ->
    if index > 0 && index <= @storage.nominations.length
      selected = @storage.nominations[index - 1]
      try
          @storage.history.push selected
      catch
          @storage.history = []
          @storage.history.push selected
      finally
          @storage.nominations = []
          @save
      return {user: selected["user"], url: selected["url"]}
    else return undefined

  validChannel: (channel) -> @channels.length == 0 || channel in @channels

  validUrl: (url) ->
    spotify = /^https?:\/\/(open|play)\.spotify\.com\/(album|track|user\/[^\/]+\/playlist)\/([a-zA-Z0-9]+)$/
    googlePlay = /^https?:\/\/(music|play)\.google\.com\/music\/m\/[a-zA-Z0-9]+\?t=[a-zA-Z0-9_-]+$/
    youtube = /^https?:\/\/(?:www\.)?youtube.com\/watch\?(?=.*v=\w+)(?:\S+)?$/
    soundCloud = /^https?:\/\/(soundcloud.com)\/(.*)\/(sets)\/(.*)$/
    bandCamp = /^https?:\/\/.*\.bandcamp\.com\/album\/.*$/
    url.match(spotify) || url.match(googlePlay) || url.match(youtube) || url.match(soundCloud) || url.match(bandCamp)

  validNomination: (user, url) ->
    if @storage.nominations && @storage.nominations.length > 0
      i = @storage.nominations.length - 1
      while i >= 0
          nomination = @storage.nominations[i]
          if nomination["user"] == user || nomination["url"] == url
              return false
          i--
      return true
    else return true

  isAdmin: (user) -> @admins.length == 0 || user in @admins

  getCurrentAotw: -> @storage.history[@storage.history.length - 1]

  doNominationsExist: -> @storage.nominations && @storage.nominations.length > 0

  getNominations: -> @storage.nominations

  getNumNominations: -> @storage.nominations.length

  doesHistoryExist: -> @storage.history && @storage.history.length > 0

  getHistory: -> @storage.history

  getNumHistory: -> @storage.history.length

module.exports = AotwManager