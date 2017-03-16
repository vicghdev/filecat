note
	description: "Summary description for {UI_DIR_TREE_FILLER}."

class UI_DIR_TREE

create make

feature {NONE} -- Initialization

	explorer: DIRECTORY
	ui_dir_tree: UI_STR_TREE

feature	 {ANY}

	make (root: STRING; evt: EV_TREE)
		local
			root_path: PATH
		do
			create root_path.make_from_string(root)
			create explorer.make_with_path(root_path)
			create ui_dir_tree.make (evt)
		end

	fillDir
		do
			exploreDirRecurse(explorer)
		end

feature {NONE} -- Helpers

	exploreDirRecurse (arg_dir: DIRECTORY)
		local
			dir: DIRECTORY
			str_parent: STRING
			str_child: STRING
		do
			across arg_dir.entries as elem
			loop
				if not (elem.item.is_current_symbol or elem.item.is_parent_symbol) then
					create dir.make_with_path (arg_dir.path.extended_path (elem.item) )
					if dir.exists then
						create str_parent.make_from_string (arg_dir.path.name.as_string_8)
						create str_child.make_from_string (dir.path.name.as_string_8)
						ui_dir_tree.add(str_parent, str_child)
						exploreDirRecurse(dir)
					end
				end
			end

		end

end
