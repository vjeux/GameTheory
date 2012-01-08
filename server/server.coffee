net = require 'net'
async = require 'async'

client_id = 0
clients = []
server = net.createServer (socket) ->
	client = {id: client_id++, socket}
	clients.push client
	socket.write 'Welcome! Please wait for a new game to start.\r\n'

query = (clients, msg..., init, update, callback) ->
	console.log 'Query', ids(clients), msg

	n = clients.length
	answer = ->
		if --n == 0
			callback null, clients

	clients.forEach (client) ->
		init(client)

		client.socket.once 'data', (data) ->
			update(client, data.toString()[0...-2])
			answer()

		client.socket.write msg.join(' ') + '\r\n'

ids = (clients) ->
	'(' + (client.name ? client.id for client in clients).join(', ') + ')'

send = (clients, msg...) ->
	console.log 'Send', ids(clients), msg...
	clients.forEach (client) ->
		client.socket.write msg.join(' ') + '\r\n'

game = ->
	players = clients.concat()
	async.waterfall [
		((callback) ->
			query players, ['Start'],
				((client) ->
					client.name = 'Unnamed'
					client.score = 0
				),
				((client, name) ->
					client.name = name.replace(/[=\s]+/g, '') + '-' + client.id
					send([client], client.name)
				),
				callback
		),
		((players, callback) ->
			send players, ['Prisonnier']
			query players, (player.name for player in players)...,
				((client) ->
					client.answer = {}
					for player in players
						client.answer[player.name] = 'C'
				),
				((client, answers) ->
					for answer_str in answers.split ' '
						[name, answer] = answer_str.split '='
						if name of client.answer and (answer == 'C' or answer == 'T')
							client.answer[name] = answer
				),
				callback
		),
		((players, callback) ->
			console.log player.answer for player in players
		)
	]
server.listen 1337, '127.0.0.1'

console.log 'server'

readline = require 'readline'
rl = readline.createInterface process.stdin, process.stdout
rl.on 'line', (line) ->
	console.log 'Starting game!'
	game()
