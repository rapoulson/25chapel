$: << '.'
require "node"

root = Node.root do 
	room(:living_room) do
		self.exit_north = :kitchen
		self.exit_east = :hall

		item(:cat, 'cat', 'sleeping', 'fuzzy') do
			item(:dead_mouse, 'mouse', 'dead', 'eaten')
		end

		item(:remote_control, 'remote', 'control') do 
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

