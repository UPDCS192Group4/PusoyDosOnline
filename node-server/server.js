// Importing the required modules
const WebSocketServer = require('ws')
const WebSocket = require('ws')
const utils = require('./game_utils')
const ngrok = require('ngrok')

// Creating a new websocket server
//// Not sure how to properly place this when created by the matchmaking server
let port = 8765 // provided by mm server
const wss = new WebSocketServer.Server({ port: port })
wss.broadcast = data => {
  wss.clients.forEach(client => {
      if (client.readyState === WebSocket.OPEN)
          client.send(data)
  })
}


const session_data = null // placeholder for game session data; could be an object?
const States = {
    INIT: "INIT",
    GAME: "GAME",
    CLEANUP: "CLEANUP"
}

var players = [] 
var hands = utils.generateHands()
var turn = 0 // index of current player turn; int
var state = States.INIT

function playerIndex(ws) {
    return players.indexOf(ws)
}

function broadcast_all_players(data) {
  players.forEach(ws => ws.send(data))
}

function _on_connect(ws) {
    if (players.length < 4) {
        if (!(ws in players)){
            console.log(`new player!`)
            players.push(ws) // temporarily being lazy and just adding ws objects directly to the list, assumes not disconnects
            let i = playerIndex(ws)
            let h = hands[playerIndex(ws)]
            setTimeout(()=>ws.send("hand " + h), 3000)
            console.log(`gave player ${i} hand: ${h}`)
        }
    }
}

function _on_data_receive(ws, data) {
    var msg = String(data)
    console.log(`FROM player ${playerIndex(ws)}: ${msg}`)
    msg = msg.split(" ")
    switch(msg[0]){
      case "play":
        let out_msg = `play ${playerIndex(ws)} ${msg[1]}`
        wss.broadcast(out_msg)
    }
}

// Creating connection using websocket
wss.on("connection", ws => {
    console.log("new client connected")
    // sending message
    ws.on("message", (data) => _on_data_receive(ws, data));
    // handling what to do when clients disconnects from server
    ws.on("close", () => {
        console.log(`player ${playerIndex(ws)} disconnected`)
    })
    // handling client connection error
    ws.onerror = function () {
        console.log("Some Error occurred")
    }
    _on_connect(ws)
});

console.log(`The WebSocket server is running on port ${port}`);
console.log(`Player hands:`)
Object.keys(hands).forEach(i => console.log(`\t${hands[i]}`))



// REFERENCES

// ws github doc
//// https://github.com/websockets/ws#server-broadcast

/* Copy pasting for future reference sa connection checking
import { WebSocketServer } from 'ws';

function heartbeat() {
  this.isAlive = true;
}

const wss = new WebSocketServer({ port: 8080 });

wss.on('connection', function connection(ws) {
  ws.isAlive = true;
  ws.on('pong', heartbeat);
});

const interval = setInterval(function ping() {
  wss.clients.forEach(function each(ws) {
    if (ws.isAlive === false) return ws.terminate();

    ws.isAlive = false;
    ws.ping();
  });
}, 30000);

wss.on('close', function close() {
  clearInterval(interval);
});
*/

// nodejs websocket tutorial
//// https://www.piesocket.com/blog/nodejs-websocket/