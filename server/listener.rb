
class ListenerHandler
	def initialize()
		@listeners = {}
		@listeners.default_proc = lambda { |hash, key|
			h = {}
			h.default_proc = lambda { |hash, key|
				hash[key] = []
			}
			hash[key] = h;
		}
	end

	def call(key, type, data)
		@listeners[key][type].each { |listener|
			listener.call(data)
		}
	end

	def remove(key, type, listener)
		@listeners[key][type].delete(listener)
	end

	def removeAll(key, type)
		@listeners[key].delete(type)
	end

	def add(key, type, listener)
		@listeners[key][type] << listener
	end

	def once(key, type, callback)
		listener = lambda { |data|
			callback.call(data)
			self.remove(key, type, listener)
		}
		@listeners[key][type] << listener
	end
end

Listener = ListenerHandler.new
