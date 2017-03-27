Swift clone of Buzzer (by @bufferapp) using Vapor, available in https://github.com/bufferapp/buzzer.

Test it using Heroku

[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy?template=https://github.com/bre7/buzzer-swift)


## Notes
Doesn't use Socket.io (wasn't able to get it working with Vapor's Websockets) so instead I used native WebSockets.

🚨 When using Vapor locally, change `wss://` to `ws://` in `Public/js/join.js` and `Public/js/hosts.js`
