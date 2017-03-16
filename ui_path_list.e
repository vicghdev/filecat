note
	description: "Summary description for {UI_PATH_LIST}."

class UI_PATH_LIST

create make

feature {NONE} -- Initialization

	--explorer: DIRECTORY
	ui_dir_list: UI_STR_LIST

feature	 {ANY}

	make (evl: EV_LIST)
		do
			create ui_dir_list.make (evl)
		end

	listFiles (path: STRING)
		local
			file_path: PATH
			file_explorer: DIRECTORY
			dir: DIRECTORY
		do
			create file_path.make_from_string(path)
			create file_explorer.make_with_path(file_path)

			ui_dir_list.wipe_out
			across file_explorer.entries as curfil
			loop
				-- if not a directory add filename
				if not (curfil.item.is_current_symbol or curfil.item.is_parent_symbol) then
					create dir.make_with_path (file_explorer.path.extended_path (curfil.item) )
					if not dir.exists then
						ui_dir_list.add_item (curfil.item.name.as_string_32)
					end
				end
			end
		end

	listFile (f: STRING)
		do
			ui_dir_list.wipe_out
			ui_dir_list.add_item (f)
		end

	listMulti (fs: LIST[STRING])
		do
			ui_dir_list.wipe_out
			across fs as f loop
				ui_dir_list.add_item (f.item)
			end
		end

end
