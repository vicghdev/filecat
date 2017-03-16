note
	description: "Summary description for {FCM}."

class FILE_CATEGORIZER

create make

feature {NONE} -- Data members (attributes)

	file_list: LIST[STRING]
	ccat_tree: CAT_TREE
	links_holder: FCAT_LINKS

feature {NONE} -- Initialization

	make
		do
			create {ARRAYED_LIST[STRING]} file_list.make (10)
			file_list.compare_objects
			create ccat_tree.make
			create links_holder.make
		end

feature {ANY} -- cmd

	Add_File(filename: STRING)
		require
			file_not_exists: not File_Exist(filename)
		do
			file_list.extend (filename.twin) --makes a copy (encapsulate it!)
		ensure
			fileExists: File_Exist(filename)
		end

	Del_File(filename: STRING)
		require
			file_exists: File_Exist(filename)
		do
			links_holder.del_file (filename)-- removes all links in which file compares, if any
			file_list.prune (filename)
		ensure
			file_removed: not File_Exist(filename)
		end

	Add_TopCategory(cat: STRING)
		require
			cat_not_exists: not Category_Exist(cat)
		do
			ccat_tree.add_topcategory (cat)
		ensure
			cat_exists: Category_Exist(cat)
		end

	Add_SubCategory(subcat: STRING; parentcat: STRING)
		require
			subcat_not_exists: not Category_Exist(subcat)
			parent_exists: Category_Exist(parentcat)
		do
			ccat_tree.add_subcategory (subcat, parentcat)
		ensure
			cat_exists: Category_Exist(subcat)
		end

	-- Note: this will delete the whole subcategory tree of the given cat
	-- and all links in which all cat nodes appear
	Del_Category(cat: STRING)
		require
			cat_exists: Category_Exist(cat)
		do
			links_holder.del_cat (cat)
			ccat_tree.del_category (cat)
		ensure
			cat_not_exists: not Category_Exist(cat)
		end

	-- Associations Files-Categories
	Add_Link(fn: STRING; cat: STRING)
		require
			not_linked: not Is_Linked(fn,cat)
		do
			links_holder.add_file_cat (fn, cat)
		ensure
			linked: Is_Linked(fn,cat)
		end

	Del_Link(fn: STRING; cat: STRING)
		require
			linked: Is_Linked(fn,cat)
		do
			links_holder.del_file_cat (fn, cat)
		ensure
			not_linked: not Is_Linked(fn,cat)
		end

feature {ANY} -- bool queries

	File_Exist(fn: STRING) : BOOLEAN
		do
			Result := file_list.has (fn)
		end

	Category_Exist(cname: STRING) : BOOLEAN
		do
			Result := ccat_tree.category_exist (cname)
		end

	Is_Linked(fn: STRING; cat: STRING): BOOLEAN
		do
			Result := links_holder.is_linked (fn, cat)
		end

feature {ANY} -- search queries

	-- this returns a copy of the filename strings (we need to ensure client code not to have access
	-- to the internally held strings!

	All_Files: LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			create res_str.make (file_list.count)
			across file_list as cursa
			loop
				res_str.extend (cursa.item.twin)		-- twin makes a copy!
			end

			Result := res_str
		end

	Top_Categories: LIST[STRING]
		do
			Result := ccat_tree.top_categories
		end

	Sub_Categories(parentcat: STRING): LIST[STRING]
		require
			parentcat_exist: Category_Exist(parentcat)
		local
			res_str: ARRAYED_LIST[STRING]
		do
			Result := ccat_tree.sub_categories (parentcat)
		end

	-- associations queries
	All_Links : LIST[FCAT_LINK]
		do
			Result := links_holder.all_links
		end

	Categories_of_file( fn: STRING ) : LIST[STRING]
		require
			file_exists: File_Exist(fn)
		do
			Result := links_holder.categories_of_file (fn)
		end

	Files_of_category( cat: STRING ) : LIST[STRING]
		require
			cat_exist: Category_Exist(cat)
		do
			Result := links_holder.files_of_category (cat)
		end

	-- complex associations queries
	Files_of_category_tree( cat: STRING ) : LIST[STRING]
		require
			cat_exist: Category_Exist(cat)
		local
			res_set: ARRAYED_SET[STRING]
			res_str: ARRAYED_LIST[STRING]
		do
			res_set := Files_of_category_tree_set(cat)
			Result := make_list_from_set(res_set)
		end

	-- Files which belong to all the given categories (AND)
	-- Note: the returned list is not ordered (should be?)

	Files_of_categories_tree( catlist: LIST[STRING] ) : LIST[STRING]
		require
			catlist_not_empty: not catlist.is_empty
			categories_exist: across catlist as curscat all Category_Exist(curscat.item) end
		local
			res_set: ARRAYED_SET[STRING]
			tmp_set: ARRAYED_SET[STRING]
			res_str: ARRAYED_LIST[STRING]
		do
			res_set := Files_of_category_tree_set(catlist[1])
			if not res_set.is_empty then
				from catlist.start; catlist.forth		-- 1st element already processed, start from 2nd if any
				until catlist.after
				loop
					tmp_set := Files_of_category_tree_set(catlist.item)
					res_set.intersect (tmp_set)
					catlist.forth
				end
			end

			Result := make_list_from_set(res_set)
		end

feature {NONE} -- private helpers

	Files_of_category_tree_set( cat: STRING ) : ARRAYED_SET[STRING]
		local
			res_set: ARRAYED_SET[STRING]
		do
			create res_set.make (10)
			res_set.compare_objects   -- this makes merge not to add duplicate strings!
			-- first add files of the given category
			across links_holder.files_of_category (cat) as cursa
			loop
				res_set.extend(cursa.item)
			end
			-- now add files of all subcategories
			across ccat_tree.sub_categories (cat) as curca
			loop
				--recurse on subcategories
				res_set.merge (Files_of_category_tree_set(curca.item))
			end

			Result := res_set
		end

	make_list_from_set(set_str: ARRAYED_SET[STRING]) : ARRAYED_LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			-- convert set to array
			create res_str.make (set_str.count)
			across set_str as curset
			loop
				res_str.extend (curset.item)
			end

			Result := res_str
		end

end
