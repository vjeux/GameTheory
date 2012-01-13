require 'rubygems'
require 'cool.io'
require_relative 'listener.rb'

def createServer(addr, port, callback)
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
end
