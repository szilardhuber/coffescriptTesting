Assume you want to test a class that logs messages received on  a ZeroMQ socket to a file. The class could be something like this:

``` coffeescript
zmq = require 'zmq'
fs = require 'fs'

class ZmqLog
  socket: null

  constructor: (@fileName, subscription = "") ->
    @socket = zmq.socket "sub"
    @socket.on "message", @writeToFile
    @socket.subscribe subscription

  connect: (address) =>
    @socket.connect address

  writeToFile: (message) =>
    fs.appendFile @fileName, message, (err) ->
      if err?
        throw err

module.exports = ZmqLog
```


I think this could be more complex but it's enough for me to show you some usage of Sinon and Chai. Chai is an assertion library that works well with Mocha and Sinon. Sinon is a standalone framework for test spies, stubs and mocks and is a great tool IMHO.

For the tests at first I need to install all required npm modules and use them in my test file:
```npm install zmq mocha chai sinon-chai sinon```

``` coffeescript
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
```

As my ZmqLog class uses zmq socket but I don't want to test ZeroMQ,  I will create a stub for that. In the stub class I don't do anything else but define the methods that I use in the ZmqLog class as spies. Spies are functions that record all kinds of information when they are called.

```coffeescript
class ZmqSocket
  constructor: ()->
    @subscribe = sinon.spy()
    @connect = sinon.spy()
    @on = sinon.spy()
```

Now that I have replaced zmq socket  I can write my first test. I check if ZmqLog creates the socket and subscribes to the given channel. I create a sandbox as otherwise spies don't get reset between tests and tests become dependent. *(Sidenote: ```beforeEach``` and ```afterEach``` are function calls and not function definitions.)*

``` coffeescript
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
```

In the second test I check if the class tested calls connect on the socket when needed.

``` coffeescript
it "should be able to connect to a zmq sub socket", ->
  logger = new ZmqLog()
  logger.connect()
  zmqSocket.connect.should.have.been.called
  zmqSocket.on.should.not.have.been.calledTwice
```

In the third test I expect my class to write out received messages to the given file. I use the feature of the function spy that it can call it's nth argument with parameters I set. This is great for simulating messages coming from the socket.

``` coffeescript
it "should write received messages to file", ->
  appendFile = sandbox.stub fs, 'appendFile'
  logger = new ZmqLog("test.txt")
  logger.connect()
  zmqSocket.on.callArgWith(1, "hello world\n")
  appendFile.should.have.been.calledWith "test.txt", "hello world\n"
```

I far from thinking my class completely tested but that wasn't the scope of this post. Also there are many other features of both Chai and Sinon but I think this is enough to get you started.
