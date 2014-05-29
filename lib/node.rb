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
end
end