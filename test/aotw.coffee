# Description:
#   Tests for hubot-aotw.
#
# Dependencies:
#   chai
#   sinon
#
# Configuration:
#
# Commands:
#
# Author:
#   Thomas Gaubert

chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

AotwManager = require '../src/aotw-manager.coffee'

robotStub = {}

describe 'AotwManager', ->
  a = {}

  beforeEach ->
    robotStub =
      brain:
        data: { }
        on: ->
        emit: ->
        save: ->
      logger:
        debug: ->
    a = new AotwManager(robotStub)

  describe 'nominating', ->
    it 'nominates url', ->
      r = a.nominate('user', 'url')
      expect(r).to.deep.equal({user: 'user', url: 'url'})

  describe 'selecting', ->
    it 'returns selected album if valid index', ->
      a.nominate('user', 'url')
      r = a.select(1)
      expect(r).to.deep.equal({user: 'user', url: 'url'})

    it 'returns undefined if invalid index', ->
      a.nominate('user', 'url')
      r = a.select(2)
      expect(r).to.be.undefined

    it 'sets album of the week', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getCurrentAotw()
      expect(r).to.deep.equal({user: 'user', url: 'url'})

    it 'clears nominations', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getNumNominations()
      expect(r).to.equal(0)

    it 'adds to history', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getNumHistory()
      expect(r).to.equal(1)

  describe 'resetting', ->
    it 'resets nominations', ->
      a.nominate('user', 'url')
      a.reset()
      r = a.getNumNominations()
      expect(r).to.equal(0)

    it 'resets history', ->
      a.nominate('user', 'url')
      a.select(1)
      a.reset()
      r = a.getNumNominations()
      expect(r).to.equal(0)

    it 'resets album of the week', ->
      a.nominate('user', 'url')
      a.select(1)
      a.reset()
      r = a.getCurrentAotw()
      expect(r).to.be.undefined

  describe 'command validation', ->
    it 'validates admins', ->
      r = a.isAdmin('Shell')
      expect(r).to.be.true

    it 'validates rooms', ->
      r = a.validChannel('Shell')
      expect(r).to.be.true

  describe 'nomination validation', ->
    it 'restricts urls to one nomination', ->
      a.nominate('user', 'url')
      r = a.validNomination('user2', 'url')
      expect(r).to.be.false

    it 'restricts users to one nomination', ->
      a.nominate('user', 'url')
      r = a.validNomination('user', 'url2')
      expect(r).to.be.false

  describe 'url validation', ->
    it 'validates Spotify urls', ->
      r = a.validUrl('https://play.spotify.com/album/0P3oVJBFOv3TDXlYRhGL7s')
      expect(r).to.not.be.null

    it 'validates Google Play Music urls', ->
      r = a.validUrl('https://play.google.com/music/m/Bu35ycj6hlkomjhqqmkvdmu6nj4?t=20_-_Big_Data')
      expect(r).to.not.be.null

    it 'validates YouTube urls', ->
      r = a.validUrl('https://www.youtube.com/watch?v=dQw4w9WgXcQ')
      expect(r).to.not.be.null

    it 'validates SoundCloud urls', ->
      r = a.validUrl('https://soundcloud.com/madeon/sets/youre-on-ft-kyan-remixes')
      expect(r).to.not.be.null

    it 'handles invalid urls', ->
      r = a.validUrl('https://google.com')
      expect(r).to.be.null

  describe 'utility functions', ->
    it 'return the current album of the week', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getCurrentAotw()
      expect(r).to.deep.equal({user: 'user', url: 'url'})

    it 'return if nominations exist', ->
      r = a.doNominationsExist()
      expect(r).to.equal.false

      a.nominate('user', 'url')
      r = a.doNominationsExist()
      expect(r).to.equal.true

    it 'return nominations', ->
      a.nominate('user', 'url')
      r = a.getNominations()
      expect(r).to.deep.equal([{user: 'user', url: 'url'}])

    it 'return number of nominations', ->
      a.nominate('user', 'url')
      r = a.getNumNominations()
      expect(r).to.equal(1)

    it 'return if history exist', ->
      r = a.doesHistoryExist()
      expect(r).to.equal.false

      a.nominate('user', 'url')
      a.select(1)
      r = a.doesHistoryExist()
      expect(r).to.equal.true

    it 'return history', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getHistory()
      expect(r).to.deep.equal([{user: 'user', url: 'url'}])

    it 'return number of history entries', ->
      a.nominate('user', 'url')
      a.select(1)
      r = a.getNumHistory()
      expect(r).to.equal(1)