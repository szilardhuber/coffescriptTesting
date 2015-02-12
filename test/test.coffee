# these will be stubbed so we need to include them
zmq = require 'zmq'
fs = require 'fs'

# for the tests
chai = require "chai"
sinon = require 'sinon'
chai.should()
sinonChai = require("sinon-chai")
chai.use sinonChai

# the class we will be testing
ZmqLog = require "../zmqLog"

# stub of the zmq socket class
class ZmqSocket
  constructor: ()->
    @subscribe = sinon.spy()
    @connect = sinon.spy()
    @on = sinon.spy()

describe "ZmqLog", ->
  sandbox = sinon.sandbox.create()
  zmqSocket = null
  socketStub = null

  beforeEach ->
    zmqSocket = new ZmqSocket sandbox
    socketStub = sandbox.stub zmq, "socket"
    socketStub.returns zmqSocket

  afterEach ->
    sandbox.restore()

  it "should create a zmq sub socket when created", ->
    logger = new ZmqLog()
    socketStub.should.have.been.calledWith "sub"
    zmqSocket.on.should.have.been.called
    zmqSocket.subscribe.should.have.been.calledWith ""

  it "should be able to connect to a zmq sub socket", ->
    logger = new ZmqLog()
    logger.connect()
    zmqSocket.connect.should.have.been.called
    zmqSocket.on.should.not.have.been.calledTwice

  it "should write received messages to file", ->
    appendFile = sandbox.stub fs, 'appendFile'
    logger = new ZmqLog("test.txt")
    logger.connect()
    zmqSocket.on.callArgWith(1, "hello world\n")
    appendFile.should.have.been.calledWith "test.txt", "hello world\n"
