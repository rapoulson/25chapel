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
		Player.new(self, :player, DEFAULTS[:player], &block)
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

	def ancestors(list=[])
		if parent.nil?
			return list
		else
			list << parent
			return parent.ancestors(list)
		end
	end

	def hidden?
		if parent.tag == :root
			return false
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

		if dest.ancestors.include?(item)
			puts "Are you trying to destroy the universe"
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

	def find_by_string(words)
		words = words.split unless words.is_a?(Array)
		nodes = find_by_name(words)

		if nodes.empty?
			puts "I don't see that here"
			return nil
		end

		#Score nodes by matching adjectives
		nodes.each do |i|
			i.search_score = (words & i.words).length
		end

		#Sort highest scores to beginning of list
		nodes.sort! do |a,b|
			b.search_score <=> a.search_score
		end

		#Remove nodes with a search score less than that of the first item
		nodes.delete_if do |i|
			i.search_score < nodes.first.search_score
		end

		#Interpret the results
		if nodes.length == 1
			return nodes.first
		else
			puts "Which item do you mean?"
			nodes.each do |i|
				puts "*#{i.name} (#{i.words.join(', ')})"
			end

			return nil
		end
	end

	def find_by_name(words, nodes=[])
		words = words.split unless words.is_a?(Array)
		nodes << self if words.include?(name)

		children.each do |c|
			c.find_by_name(words, nodes)
		end

		return nodes
	end
end

class Player < Node
	def command(words)
		verb, *words = words.split(' ')
		verb = "do_#{verb}"

		if respond_to?(verb)
			send(verb, *words)
		else
			puts "I don't know how to do that"
		end
	end

	def do_go(direction, *a)
		dest = get_room.send("exit_#{direction}")

		if dest.nil?
			puts "You can't go that way"
		else
			get_root.move(self,dest)
		end
	end

	%w{north south east west up down}.each do|dir|
		define_method("do_#{dir}") do
			do_go(dir)
		end

		define_method("do_#{dir[0]}") do
			do_go(dir)
		end
	end

	def do_take(*thing)
		get_root.move(thing.join(' '), self)
	end
	alias_method :do_get, :do_take

	def do_drop(*thing)
		move(thing.join(' '), get_room)
	end

	def open_close(thing, state)
		container = get_room.find(thing)
		return if container.nil?

		if container.open == state
			puts "It's already #{state ? 'open' : 'closed'}"
		else
			container.open = state
		end
	end

	def do_open(*thing)
		open_close(thing, true)
	end

	def do_close(*thing)
		open_close(thing,false)
	end

	def do_look(*a)
		puts "You are in #{get_room.tag}"
	end

	def do_inventory(*a)
		puts "You are carrying:"

		if children.empty?
			puts " * Nothing"
		else
			children.each do|c|
				puts "* #{c.name} (#{c.words.join(' ')})"
			end
		end
	end
	alias_method :do_inv, :do_inventory
	alias_method :do_i, :do_inventory

	def do_put(*words)
		prepositions = ['in', 'on']

		prep_regex = Regexp.new("(#{prepositions.join('|')})")
		item_words, _, cont_words = words.join(' ').split(prep_regex)

		if cont_words.nil?
			puts "You want to  put that where?"
			return
		end

		item = get_room.find(item_words)
		container = get_room.find(cont_words)

		return if item.nil? || container.nil?

		get_room.move(item, container)
	end


	def play
		loop do
			do_look
			print "What now? "
			command(gets.chomp)
		end
	end
end