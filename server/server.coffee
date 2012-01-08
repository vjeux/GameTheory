net = require 'net'
async = require 'async'
UnionFind = require './unionfind.coffee'

client_id = 0
clients = []
server = net.createServer (socket) ->
	client = {id: client_id++, socket, toString: -> @name ? @id}
	clients.push client
	socket.write 'Welcome! Please wait for a new game to start.\r\n'

query = (clients, msg..., init, update, callback) ->
	msg = msg.join(' ')
	console.log '>', msg, ids(clients)

	n = clients.length
	answer = ->
		if --n == 0
			callback null, clients

	clients.forEach (client) ->
		init(client)

		client.socket.once 'data', (data) ->
			update(client, data.toString()[0...-2])
			answer()

		client.socket.write msg + '\r\n'

ids = (clients) ->
	'(' + clients.join(', ') + ')'

send = (clients, msg...) ->
	msg = msg.join(' ')
	console.log '>', msg, ids(clients)
	clients.forEach (client) ->
		client.socket.write msg + '\r\n'

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
						client.answer[player.name] = 'T'
				),
				((client, answers) ->
					console.log '<', answers, ids([client])
					for answer_str in answers.split ' '
						[name, answer] = answer_str.split '='
						if name of client.answer and (answer == 'C' or answer == 'T')
							client.answer[name] = answer
				),
				callback
		),
		((players, callback) ->
			for player in players
				send [player], (
					for other in players
						if other != player
							other.name + '=' + other.answer[player.name]
				).filter (x) -> x

			for player in players
				UnionFind.makeSet player

			for a in players
				for b in players
					if a != b and a.answer[b.name] == b.answer[a.name] == 'C'
						UnionFind.union(a, b)

			console.log UnionFind.components players
		)
	]

server.listen 1337, '127.0.0.1'

console.log 'server'

readline = require 'readline'
rl = readline.createInterface process.stdin, process.stdout
rl.on 'line', (line) ->
	console.log 'Starting game!'
	game()
