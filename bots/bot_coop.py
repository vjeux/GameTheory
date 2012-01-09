from random import random

# # # # # # # # # # # # # # #
#   Socket Implementation   #
# # # # # # # # # # # # # # #

from TCPClient import TCPClient
TCP = TCPClient('127.0.0.1', 1337)

def readString():
	str = TCP.readline()
	print '<', str
	return str

def read():
	return readString().split(' ')

def write(str):
	if isinstance(str, (list, tuple)):
		str = ' '.join(str)
	print '>', str
	TCP.writeline(str)


# # # # # # # # # # # # # # #
#         Game Code         #
# # # # # # # # # # # # # # #

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
		players = read()

		# Send T / C
		msg = []
		for player in players:
			if player != myself:
				# We don't know who to trust ... Let's use Random!
				if random() > 0.5:
					action = 'C'
				else:
					action = 'T'
				action = 'C' # debug
				msg.append('%s=%s' % (player, action))
		write(msg)

		# Receive what the others said about me
		actions = dict(x.split('=') for x in read())
		# actions = { 'Player-1' : 'C', 'Player-2' : 'T', ... }

		# Pirate Game
		while readString() == 'Pirate':

			# Receive players and bounty
			data = read()
			bounty = data[0] # bounty = 42
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
				shares = dict((x.split('=')[0], int(x.split('=')[1])) for x in read())
				# shares = { 'Player-1' : 50, 'Player-2' : 10, 'Player-3' : 0, ... }

				if shares[myself] > 0: # If we are given something, we cooperate
					action = 'C'
				else:
					action = 'T'

				write(action)

		# Pirate game is over, let's see how much we got
		score += int(readString())

	# Game is over, get the final scores
	scores = dict(x.split('=') for x in read())
	# scores = { 'Player-1' : 100, 'Player-2' : 23, 'Player-3' : 0, ... }

	break
