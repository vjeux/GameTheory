from random import random

# # # # # # # # # # # # # # #
#   Socket Implementation   #
# # # # # # # # # # # # # # #

from TCPClient import TCPClient
TCP = TCPClient('127.0.0.1', 1337)

def readString():
	return TCP.readline()

def read():
	return TCP.readline().split(' ')

def write(str):
	if isinstance(str, (list, tuple)):
		str = ' '.join(str)
	TCP.writeline(str)


# # # # # # # # # # # # # # #
#         Game Code         #
# # # # # # # # # # # # # # #

print readString() # Welcome

while 1:
	print readString() # Start

	# Name
	write("BotCoop")
	myself = readString()
	print 'My Name:', myself

	game = readString()
	# Prisonnier
	if game == 'Prisonnier':

		# Receive Players
		players = read()
		print 'Players:', players

		# Send T / C
		msg = []
		for player in players:
			if player != myself:
				if random() > 0.5:
					action = 'C'
				else:
					action = 'T'

				msg.append('%s=%s' % (player, action))

		print msg
		write(msg)


	break
