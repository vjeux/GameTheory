net = require 'net'
async = require 'async'
UnionFind = require './unionfind.coffee'
require 'sugar'

isInt = (x) -> typeof x == 'number' and x % 1 == 0

client_id = 0
clients = []
server = net.createServer (socket) ->
	client = {id: client_id++, socket, alive: true, toString: -> @name ? @id}
	socket.on 'close', ->
		client.alive = false
	clients.push client
	send [client], 'Welcome! Please wait for a new game to start.'

query = (clients, msg, init, update, callback) ->
	msg = msg.join(' ')
	console.log '>', msg, ids(clients)

	t = null
	send = ->
		for client in clients
			if client.alive
				client.socket.removeListener 'data', client.data
				client.socket.removeListener 'close', client.close
		clearTimeout t
		callback null

	t = setTimeout send, 1000
	n = clients.filter((client) -> client.alive).length
	answer = ->
		if --n == 0
			send()

	clients.forEach (client) ->
		init(client)

		if client.alive
			client.socket.once 'data', client.data = (data) ->
				data = data.toString()[0...-2]
				console.log '<', data, ids([client])
				update(client, data)
				answer()

			client.socket.once 'close', client.close = (data) ->
				answer()

			client.socket.write msg + '\r\n'

ids = (clients) ->
	'(' + clients.join(', ') + ')'

send = (clients, msg...) ->
	msg = msg.join(' ')
	console.log '>', msg, ids(clients)
	clients.forEach (client) ->
		if client.alive
			client.socket.write msg + '\r\n'

inGame = false
game = ->
	return if (inGame)
	inGame = true

	all_players = clients.filter((client) -> client.alive).concat()
	players = all_players.concat()
	rounds = 1

	async.waterfall [
		((callback) ->
			query players, ['Start'],
				((client) ->
					client.name = 'Unnamed-' + client.id
					client.score = 0
				),
				((client, name) ->
					client.name = name.replace(/[=\s]+/g, '') + '-' + client.id
					send([client], client.name)
				),
				callback
		),
		((callback) ->
			async.whilst (-> rounds-- > 0), ((callback) ->
				async.waterfall [
					((callback) ->
						send players, ['Prisonnier']
						query players, (player.name for player in players),
							((client) ->
								client.answer = {}
								for player in players
									client.answer[player.name] = 'T'
							),
							((client, answers) ->
								for answer_str in answers.split ' '
									[name, answer] = answer_str.split '='
									if name of client.answer and (answer == 'C' or answer == 'T')
										client.answer[name] = answer
							),
							callback
					),
					((callback) ->
						for player in players
							send [player], ((
								for other in players
									if other != player
										other.name + '=' + other.answer[player.name]
							).filter (x) -> x)...

						for player in players
							UnionFind.makeSet player

						for a in players
							for b in players
								if a != b and a.answer[b.name] == b.answer[a.name] == 'C'
									UnionFind.union(a, b)

						groups = UnionFind.components players
						players = all_players.concat()
						async.parallel groups.map((pirates) ->
							((callback) ->
								pirates.sort (x, y) -> 0.5 - Math.random()
								pirates.sort (x, y) -> y.score - x.score

								Table =
									TT: 0, TC: 1
									CT: 3, CC: 5

								bounty = (for a in pirates
									(for b in pirates
										Table[a.answer[b.name] + b.answer[a.name]]).sum()
								).sum()

								isLeaderKilled = true

								async.whilst (-> isLeaderKilled), ((callback) ->
									send pirates, 'Pirate'
									send pirates[1...], bounty, (player.name for player in pirates)...

									async.waterfall [
										((callback) ->
											query [pirates[0]], [bounty, (player.name for player in pirates)...],
												(reset = (client) ->
													for player, id in pirates
														player.share = if id == 0 then bounty else 0
												),
												((client, answers) ->
													for answer_str in answers.split ' '
														[name, answer] = answer_str.split '='
														pirates.forEach (player) ->
															if player.name == name and isInt +answer
																player.share = +answer
													if (player.share for player in pirates).sum() != bounty
														reset()
												),
												callback
										),
										((callback) ->
											pirates[0].answer = 'C'
											query pirates[1...], (player.name + '=' + player.share for player in pirates),
												((client) ->
													client.answer = 'C'
												),
												((client, answer) ->
													if answer == 'T' or answer == 'C'
														client.answer = answer
												),
												callback
										),
										((callback) ->
											dead = ((if player.answer == 'T' then 1 else 0) for player in pirates).sum()
											alive = pirates.length - dead

											isLeaderKilled = dead > alive
											if isLeaderKilled
												leader = pirates[0]
												send [leader], 'EndPirate'
												send [leader], 0
												pirates = pirates[1...]
												players.remove leader
											else
												for player in pirates
													send [player], 'EndPirate'
													send [player], player.share
													player.score += player.share
											callback()
										) # f
									], callback # waterfall
								), callback # while
							) # f
						), callback # paralell
					) # f
				], callback # waterfall
			), callback # while
		),
		((callback) ->
			players = all_players.concat()
			send players, 'EndPrisonnier'
			send players, (player.name + '=' + player.score for player in players)...
			inGame = false
		) # f
	] # waterfall



if process.argv.length == 3:
	ip = process.argv[1]
	port = +process.[2]
else:
	ip = '127.0.0.1'
	port = 1337

server.listen port, ip

console.log 'Press Enter to Start a Game!'

readline = require 'readline'
rl = readline.createInterface process.stdin, process.stdout
rl.on 'line', (line) ->
	game()
