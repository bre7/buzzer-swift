const socket = new WebSocket('wss://'+location.host+'/ws')
const active = document.querySelector('.js-active')
const buzzList = document.querySelector('.js-buzzes')
const clear = document.querySelector('.js-clear')

socket.onmessage = function(message) {
    console.log(message)
    const json    = JSON.parse(message.data)
    const event   = json["event"]
    const payload = json["payload"]
    console.log("event")
    console.log(event)
    console.log("payload")
    console.log(payload)
    if ( typeof event === 'undefined') {
        return
    }

    switch (event) {
        case "active":
            active.innerText = `${payload} joined`
            break;
        case "buzzes":
            buzzList.innerHTML = payload
                .split(",")
                .map(buzz => {
                    const p = buzz.split('-')
                    return { name: p[0], team: p[1] }
                })
                .map(user => `<li>${user.name} on Team ${user.team}</li>`)
                .join('')
            break;
    }
}

clear.addEventListener('click', () => {
    const wsData = JSON.stringify({
        "event": "clear",
        "payload": ""
    })
    socket.send(wsData)
})
