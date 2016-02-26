# Description:
#   Track and manage the album of the week.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   aotw current - view the current AOTW *
#   aotw debug <about|data|submit url|update> - debugging tools *~
#   aotw help - display AOTW help
#   aotw history [length] - view all historical AOTWs, optionally limited to [length] *
#   aotw nominate <url> - nominate an album *
#   aotw nominations [length] - view all current nominations, optionally limited to [length] *
#   aotw reset - reset all AOTW data *~
#   aotw select [nomination index] - select the AOTW (of given index or random) and reset nominations *~
#
# Author:
#   Thomas Gaubert

AotwManager = require('./aotw-manager')

module.exports = (robot) ->

  aotw = new AotwManager(robot)

  checkMessage = (msg, cmd) ->
    if aotw.validChannel msg.message.user.room
      cmd msg
    else msg.send "You must be in a valid channel to use this command"

  checkRestrictedMessage = (msg, cmd) ->
    if aotw.isAdmin msg.message.user.name
      checkMessage msg, cmd
    else msg.send "You lack permission for this command"

  printCurrentAotw = (msg) ->
    if aotw.getHistory() > 0
      current = aotw.getCurrentAotw()
      msg.send "Current AOTW: #{current["url"]}, nominated by #{current["user"]}"
    else msg.send "No current album of the week"

  debug = (msg) ->
    if msg.match[1] != "debug"
      arg = msg.match[1].split(" ")[1]
      switch arg
        when "about"
          try
            @exec = require('child_process').exec
            @exec 'npm view hubot-aotw version', (error, stdout, stderr) ->
              if error
                msg.send "Unable to get version: " + stderr
              else output = stdout+''
              msg.send "hubot-aotw v#{output}"
          catch error
              msg.send "Unable to get version: " + error
        when "data"
            if @storage.history
              msg.send "History (@storage.history - #{@storage.history.length} entries):"
              msg.send JSON.stringify(@storage.history)
            else msg.send "No data currently stored in @storage.history"

            if @storage.nominations
              msg.send "Nominations (@storage.nominations - #{@storage.nominations.length} entries):"
              msg.send JSON.stringify(@storage.nominations)
            else msg.send "No data currently stored in @storage.nominations"
          when "submit"
            if msg.match[1] != "debug submit"
              url = msg.match[1].split(" ")[2]
              if aotw.validUrl url
                msg.send "Valid nomination URL"
              else
                msg.send "Invalid nomination URL"
            else msg.send "Invalid command: missing url"
          when "update"
            try
              @exec = require('child_process').exec
              msg.send "Checking for updates..."
              @exec 'npm update', (error, stdout, stderr) ->
                if error
                  msg.send "Update failed: " + stderr
                else output = stdout+''

                if /node_modules/.test output
                  msg.send "Dependencies updated:\n" + output
                  changes = true
                else msg.send "No updates are currently available"

                if changes
                  @downloaded_updates = true
                  msg.send "Restart to apply updates"
                else
                  if @downloaded_updates
                    msg.send "Updates are pending, restart to apply"
            catch error
              msg.send "Update failed: " + error
          else msg.send "Invalid command: invalid debug argument"
    else msg.send "Invalid command: missing debug argument"

  printHelp = (msg) ->
    msg.send "aotw current - view the current AOTW *"
    msg.send "aotw debug <about|data|submit url|update> - debugging tools *~"
    msg.send "aotw help - display AOTW help"
    msg.send "aotw history [length] - view all historical AOTWs, optionally limited to [length] *"
    msg.send "aotw nominate <url> - nominate an album *"
    msg.send "aotw nominations [length] - view all current nominations, optionally limited to [length] *"
    msg.send "aotw reset - reset all AOTW data *~"
    msg.send "aotw select [nomination index] - select the AOTW (of given index or random) and reset nominations *~"
    if @channels.length > 0
      msg.send "Commands denoted by * are restricted to specific channels, ~ are limited to AOTW admins"
    else msg.send "Commands denoted by ~ are limited to AOTW admins"

  printHistory = (msg) ->
    if msg.match[1] != "history"
      limit = msg.match[1].split(" ")[1]
    else
      limit = 10

    if aotw.doesHistoryExist()
      history = aotw.getHistory()
      msg.send "Total of #{history.length} previous AOTWs"
      i = history.length - 1
      count = 0
      while i >= 0 && count < limit
        album = history[i]
        msg.send "#{count + 1} - #{album["user"].slice(0, 1) + "." + album["user"].slice(1)} - #{album["url"]}"
        i--
        count++
    else msg.send "No previous AOTWs"

  printNominations = (msg) ->
    if msg.match[1] != "nominations"
      limit = msg.match[1].split(" ")[1]
    else
      limit = 10

    if aotw.doNominationsExist()
      nominations = aotw.getNominations()
      i = nominations.length - 1
      count = 0
      while i >= 0 && count < limit
        nomination = nominations[i]
        msg.send "#{count + 1} - #{nomination["user"].slice(0, 1) + "." + nomination["user"].slice(1)} - #{nomination["url"]}"
        i--
        count++
    else msg.send "No current nominations"

  nominate = (msg) ->
    if msg.match[1] != "nominate"
      url = msg.match[1].split(" ")[1]
      user = msg.message.user.name.toLowerCase()
      if aotw.validUrl url
        valid = aotw.validNomination user, url
        if valid == true
          aotw.nominate user, url
          msg.send "Nomination saved"
        else msg.send "Invalid nomination: duplicate #{valid}"
      else msg.send "Invalid nomination: invalid url"
    else msg.send "Invalid nomination: missing url"

  reset = (msg) ->
    aotw.reset()
    msg.send "All AOTW data has been reset"

  select = (msg) ->
    if msg.match[1] != "select"
      selected = aotw.select msg.match[1].split(" ")[1]
      if selected?
        msg.send "Selected #{selected["url"]}, nominated by #{selected["user"]}"
      else msg.send "Invalid selection: invalid nomination index"
    else
      if aotw.getNumNominations() > 0
        selected = aotw.select Math.floor(Math.random() * aotw.getNumNominations()) + 1
        if selected?
          msg.send "Randomly selected #{selected["url"]}, nominated by #{selected["user"]}"
        else
          msg.send "Unable to randomly select AOTW: invalid index"
      else
        msg.send "Unable to randomly select AOTW: no nominations"

  robot.hear /^\s*aotw\s*$/i, (msg) ->
    msg.send "Invalid command, say \"aotw help\" for help"

  robot.hear /^\s*aotw (.*)/i, (msg) ->
    cmd = msg.match[1].split(" ")[0]
    switch cmd
      when "current" then checkMessage msg, printCurrentAotw
      when "debug" then checkRestrictedMessage msg, debug
      when "help" then printHelp msg
      when "history" then checkMessage msg, printHistory
      when "nominate" then checkMessage msg, nominate
      when "nominations" then checkMessage msg, printNominations
      when "reset" then checkRestrictedMessage msg, reset
      when "select" then checkRestrictedMessage msg, select
      else msg.send "Invalid command, say \"aotw help\" for help"
