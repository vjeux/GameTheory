require_relative 'createserver.rb'

ADDR = '127.0.0.1'
PORT = 1337

class GameTheory
	def initialize()
		

		client_id = 0
		clients = []

		Server.new.create(ADDR, PORT, lambda { |socket|

			client = {"id" => client_id, "socket" => socket, "alive" => true}
			client_id += 1
			Listener.add(socket, 'close', lambda {
				client.alive = false
			})
			clients << client
			a = [client]
			sendMessage("vjeux", "Welcome! Please wait for a new game to start.")

			puts "#{socket.remote_addr}:#{socket.remote_port} connected"

			Listener.once(socket, 'data', lambda { |data|
				puts "Data Received #{data}"
			})

			Listener.add(socket, 'close', lambda { |data|
				client.alive = false
				puts "Closed"
			})

			socket.write "Hello\r\n"
			socket.write "Start\r\n"
		})
	end

	def sendMessage(a, b)
		puts "send - #{a} #{b}"
	end

end

GameTheory.new