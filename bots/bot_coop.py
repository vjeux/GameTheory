# # # # # # # # # # # # # # #
#      Socket Helpers       #
# # # # # # # # # # # # # # #

from sys import argv
from TCPClient import TCPClient

if len(argv) == 3:
	ip = argv[1]
	port = int(argv[2])
else:
	ip = '127.0.0.1'
	port = 1337

TCP = TCPClient(ip, port)

def readString():
	str = TCP.readline()
	print '<', str
	return str

def readArray():
	return readString().split(' ')

def write(str):
	if isinstance(str, (list, tuple)):
		str = ' '.join(str)
	print '>', str
	TCP.writeline(str)


# # # # # # # # # # # # # # #
#         Game Code         #
# # # # # # # # # # # # # # #

from random import random

readString() # Welcome

while 1:
	readString() # Start

	score = 0

	# Name
	write("BotCoop")
	myself = readString()

	# Prisonnier Game
	while readString() == 'Prisonnier':

		# Receive Players
		players = readArray()

		# Send T / C
		msg = []
		for player in players:
			if player != myself:
				# Everybody is our friend
				action = 'C'

				msg.append('%s=%s' % (player, action))
		write(msg)

		# Receive what the others said about me
		actions = dict(x.split('=') for x in readArray())
		# actions = { 'Player-1' : 'C', 'Player-2' : 'T', ... }

		# Pirate Game
		while readString() == 'Pirate':

			# Receive players and bounty
			data = readArray()
			bounty = int(data[0]) # bounty = 42
			players = data[1:] # players = [ 'Player-1', 'Player-2', ... ]
			# Note: players are sorted by hierarchy, the first is the leader.

			# We are the leader, let's make a share
			if players[0] == myself:
				msg = []
				for player in players:
					# Share the bounty ...
					if player == myself:
						share = bounty # Give everything to myself!
					else:
						share = 0 # And nothing to the others :)

					msg.append('%s=%s' % (player, share))

				write(msg)

			# We are not the leader, let's see if we accept the share
			else:
				shares = dict((x.split('=')[0], int(x.split('=')[1])) for x in readArray())
				# shares = { 'Player-1' : 50, 'Player-2' : 10, 'Player-3' : 0, ... }

				if shares[myself] > 0: # If we are given something, we cooperate
					action = 'C'
				else:
					action = 'T'

				write(action)

		# Pirate game is over, let's see how much we got
		score += int(readString())

	# Game is over, get the final scores
	scores = dict((x.split('=')[0], int(x.split('=')[1])) for x in readArray())
	# scores = { 'Player-1' : 100, 'Player-2' : 23, 'Player-3' : 0, ... }
