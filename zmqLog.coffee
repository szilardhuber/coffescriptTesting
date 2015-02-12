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
