require "ostruct"

class Node < OpenStruct
	DEFAULTS = {
		:root => { :open => true },
		:room => { :open => true },
		:item => { :open => false },
		:player => { :open => true }
	}

	def initialize(parent, tag, defaults={}, &block)
		super()
		defaults.each {|k, v| send("{k}=", v)}	

		self.parent = parent
		self.parent.children << self unless parent.nil?
		self.tag = tag
		self.children = []

		instance_eval(&block) unless block.nil?
	end

	def room(tag, &block)
		Node.new(self, tag, DEFAULTS[:room], &block)
	end

	def item(tag, name, *words, &block)
		i = Node.new(self, tag, DEFAULTS[:item])
		i.name = name
		i.words = words
		i.instance_eval(&block) if block_given?
	end

	def player(&block)
		Node.new(self, :player, DEFAULTS[:player], &block)
	end

	def self.root(&block)
		Node.new(nil, :root, &block)
	end

	def get_room
		if parent.tag == :root
			return self
		else
			return parent.get_room
		end
	end

	def get_root
		if tag == :root || parent.nil?
			return self
		else
			return parent.get_root
		end
	end

	def hidden?
		if parent.tag == :rootreturn false
		elsif parent.open == false
			return true
		else
			return parent.hidden?
		end
	end

	def move(thing, to, check=true)
		item = find(thing)
		dest = find(to)

		return if item.nil?
		if check && item.hidden
			puts "You can't get to that right now"
			return
		end

		return if dest.nil?
		if check && (dest.hidden? || dest.open == false)
			puts "You can't put that there"
			return
		end

		item.parent.children.delete(item)
		dest.children << item
		item.parent = dest
	end

	def find(thing)
		case thing
		when Symbol
			find_by_tag(thing)
		when String
			find_by_string(thing)
		when Node
			thing
		end
	end

	def find_by_tag(tag)
		return self if self.tag == tag

		children.each do |c|
			res = c.find_by_tag(tag)
			return res unless res.nil?
		end

		return nil
	end



end
end