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

	# Name
	write("BotCoop")
	myself = readString()


	# Prisonnier
	while 1:
		game = readString()
		if game != 'Prisonnier':
			break

		# Receive Players
		players = read()

		# Send T / C
		msg = []
		for player in players:
			if player != myself:
				if random() > 0.5:
					action = 'C'
				else:
					action = 'T'
				action = 'C'
				msg.append('%s=%s' % (player, action))

		write(msg)

		# Receive what other said against me
		read()

		while 1:
			game = readString()
			if game != 'Pirate':
				break

			read()

	break
