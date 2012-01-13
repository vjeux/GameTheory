
require 'fiber'
require 'rubygems'
require 'cool.io'

ADDR = '127.0.0.1'
PORT = 1337


listeners = {}
listeners.default_proc = lambda { |hash, key|
	h = {}
	h.default_proc = lambda { |hash, key|
		hash[key] = []
	}
	hash[key] = h;
}

Listener_call = lambda { |key, type, data|
	listeners[key][type].each { |listener|
		listener[data]
	}
}

Listener_remove = lambda { |key, type, listener|
	listeners[key][type].delete(listener)
}

Listener_removeAll = lambda { |key, type|
	listeners[key].delete(type)
}

Listener_add = lambda { |key, type, listener|
	listeners[key][type] << listener
}

Listener_once = lambda { |key, type, callback|
	listener = lambda { |data|
		callback[data]
		Listener_remove[key, type, listener]
	}
	listeners[key][type] << listener
}


client_id = 0
clients = []

createServer = lambda { |addr, port, callback|
	cool.io.server addr, port do
		on_connect do
			callback[self]
		end
		on_close do
			Listener_call[self, 'close']
		end
		on_read do |data|
			Listener_call[self, 'data', data]
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

root_fiber = Fiber.current

query = lambda { |clients, msg, init, update, callback|

	f = Fiber.new {
		msg = msg.join(' ')
		puts "> #{msg}"

		n = clients.length

		answer = lambda {
			n -= 1
			if n == 0
				Fiber.yield
			end
		}

		clients.each { |client|
			init[client]

			Listener_once[client['socket'], 'data', lambda { |data|
				data = data.slice(0, data.length - 2)
				puts "< #{data}"
				update[client, data]
				f.resume
				answer[]
			}]

			client['socket'].write msg + "\r\n"
		}
	}
	f.resume
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
	puts "End2"
}


createServer[ADDR, PORT, lambda { |socket|
	client = {"id" => client_id, "socket" => socket, "alive" => true}
	client_id += 1
	Listener_add[socket, 'close', lambda {
		client['alive'] = false
	}]
	clients << client
	send[[client], "Welcome! Please wait for a new game to start."]

	if client_id == 2
		game[]
	end
}]

