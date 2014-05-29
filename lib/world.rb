$: << '.'
require "node"

root = Node.root do 
	room(:living_room) do
		self.exit_north = :kitchen
		self.exit_east = :hall

		item(:cat, 'cat', 'sleeping', 'fuzzy') do
			self.script_take = <<-SCRIPT
			if find(:dead_mouse)
				puts "The cat drops the dead mouse"
				get_room.move(:dead_mouse, get_room, false)
			end

			puts "The can't won't let you pick it up"
			return false
			SCRIPT
			self.script_control = <<-SCRIPT
			puts "The cat sits upright, awaiting your command)"
				return true
			SCRIPT

			item(:dead_mouse, 'mouse', 'dead', 'eaten')
		end

		item(:remote_control, 'remote', 'control') do
		self.script_accept = <<-SCRIPT
			if [:new_batteries, :old_batteries].include?(args[0].tag) &&
				children.empty?
				return true
			elsif !children.empty?
				puts "There are already batteries in the remote"
				return false
			else
				puts "That won't fit into the remote"
				return false
			end
			SCRIPT

			self.script_use = <<-SCRIPT
			if !find(:new_batteries)
				puts "The remote doesn't seem to work"
				return
			end

			if args[0].tag == :cat
				args[0].script('control')
				return
			else
				puts "The remote doesn't seem to work with that"
				return
			end
			SCRIPT

			item(:dead_batteries, 'batteries', 'dead', 'AA')
		end
	end

	room(:kitchen) do
		self.exit_south = :living_room

		player do
			item(:ham_sandwich, 'sandwich', 'ham')
		end

		item(:drawer, 'drawer', 'kitchen') do
			self.open = true

			item(:new_batteries, 'batteries', 'new', 'AA')
		end
	end

	room(:hall) do
		self.exit_west = :living_room

		self.script_enter = <<-SCRIPT
		puts "A forcefield stops you from entering the hall"
		return false
		SCRIPT
	end
end

root.find(:player).tap do|pl|
	pl.command("go south")

	pl.command("take remote")

	pl.command("take dead mouse")

	pl.command("drop remote")

	pl. command("go north")

	pl.command("take new batteries")

	pl.command("open drawer")
	pl.command("take new batteries")
	pl.command("close drawer")

	pl.command("look")
	pl.command("inventory")
end

	puts root
	root.find(:player).play

