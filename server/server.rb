
require 'rubygems'
require 'cool.io'
require_relative 'listener.rb'

ADDR = '127.0.0.1'
PORT = 1337


client_id = 0
clients = []

createServer = lambda { |addr, port, callback|
	cool.io.server addr, port do
		on_connect do
			callback.call(self)
		end
		on_close do
			Listener.call(self, 'close')
		end
		on_read do |data|
			Listener.call(self, 'data', data)
		end
	end
	cool.io.run
}

send = lambda { |clients, *msg|
	msg = msg.join(' ')
	puts "> #{msg}"
	clients.each { |client|
		client['socket'].write msg + "\r\n"
	}
}

query = lambda { |clients, msg, init, update, callback|
	msg = msg.join(' ')
	puts "> #{msg}"

	n = clients.length

	answer = lambda {
		n -= 1
		if n == 0
			callback[]
		end
	}

	clients.each { |client|
		init[client]

		Listener.once(client['socket'], 'data', lambda { |data|
			data = data.slice(0, data.length - 2)
			puts "< #{data}"
			update[client, data]
			answer[]
		})

		client['socket'].write msg + "\r\n"
	}
}


game = lambda {
	players = clients

	query[players, ['Start'],
		lambda { |client|
			client['name'] = "Unnamed-#{client['id']}"
			client['score'] = 0
		},
		lambda { |client, name|
			client['name'] = "#{name}-#{client['id']}"
			send[[client], client['name']]
		},
		lambda {
			puts "End!"
		}
	]
}


createServer[ADDR, PORT, lambda { |socket|
	client = {"id" => client_id, "socket" => socket, "alive" => true}
	client_id += 1
	Listener.add(socket, 'close', lambda {
		client['alive'] = false
	})
	clients << client
	send[[client], "Welcome! Please wait for a new game to start."]

	if client_id == 2
		game[]
	end
}]

