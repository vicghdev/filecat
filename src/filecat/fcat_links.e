note
	description: "Manages the many-many association between files and categories"

class FCAT_LINKS

create make

feature {NONE} -- Read-only Data members (attributes)

	file_cat_list: ARRAYED_LIST[FCAT_LINK]

feature {NONE} -- Initialization

	make
		do
			create file_cat_list.make (10)
			file_cat_list.compare_objects
		end

feature {ANY} -- Cmd

	Add_File_Cat(fn: STRING; cat: STRING)
		require
			not_linked: not Is_Linked(fn,cat)
		local
			new_link: FCAT_LINK
		do
			create new_link.make (fn, cat)
			file_cat_list.extend (new_link)
		ensure
			linked: Is_Linked(fn,cat)
		end

	Del_File_Cat(fn: STRING; cat: STRING)
		require
			linked: Is_Linked(fn,cat)
		local
			rem_link: FCAT_LINK
		do
			create rem_link.make (fn, cat)
			file_cat_list.prune(rem_link)
		ensure
			not_linked: not Is_Linked(fn,cat)
		end

	-- removes all the links containing fn
	Del_File(fn: STRING)
		do
			from file_cat_list.start
			until file_cat_list.after
			loop
				if file_cat_list.item.filename.is_equal (fn) then
					file_cat_list.remove	--also moves cursor to right neighbor!
				else
					file_cat_list.forth
				end
			end
		end

	-- removes all the links containing cat
	Del_Cat(cat: STRING)
		do
			from file_cat_list.start
			until file_cat_list.after
			loop
				if file_cat_list.item.category.is_equal (cat) then
					file_cat_list.remove	--also moves cursor to right neighbor!
				else
					file_cat_list.forth
				end
			end
		end


feature {ANY} -- Q.bool

	Is_Linked(fn: STRING; cat: STRING): BOOLEAN
		local
			search_link: FCAT_LINK
		do
			create search_link.make (fn, cat)
			file_cat_list.start
			file_cat_list.search (search_link)
			Result := not file_cat_list.exhausted
		end

feature {ANY} -- Q.search

	All_Links : LIST[FCAT_LINK]
		local
			retup: ARRAYED_LIST[FCAT_LINK]
			lnk: FCAT_LINK
		do
			create retup.make (file_cat_list.count)
			across file_cat_list as cursa
			loop
				create lnk.make (cursa.item.filename.twin, cursa.item.category.twin)  --makes a copy!
				retup.extend (lnk)
			end
			Result := retup
		end

	Categories_of_file( fn: STRING ) : LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			create res_str.make (0)	--empty list
			across file_cat_list as cursfc
			loop
				if cursfc.item.filename.is_equal (fn) then
					res_str.extend (cursfc.item.category.twin)
				end
			end
			Result := res_str
		end

	Files_of_category( cat: STRING ) : LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			create res_str.make (0)	--empty list
			across file_cat_list as cursfc
			loop
				if cursfc.item.category.is_equal (cat) then
					res_str.extend (cursfc.item.filename.twin)
				end
			end
			Result := res_str
		end

end
