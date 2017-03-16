note
	description: "Summary description for {UI_STR_LIST}."
	date: "$Date$"

class UI_STR_LIST

create make

feature {NONE} -- Initialization

	str_list: EV_LIST

	make(strlist: EV_LIST)
		do
			str_list := strlist
		end

feature	 {ANY}

	add_item (str: STRING)
		local
			f: EV_LIST_ITEM
		do
			create f.make_with_text (str)
			str_list.extend(f)
		end

	wipe_out
		do
			str_list.wipe_out
		end

	set_items (items: LIST[STRING])
		do
			str_list.wipe_out
			across items as curfi
			loop
				add_item(curfi.item)
			end
		end

end
