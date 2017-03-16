note
	description: "Summary description for {FCCAT}."

class CAT_TREE

create make

feature {NONE} -- Data members (attributes)

	cat_tree: ARRAYED_TREE[STRING]
	recurse_found: BOOLEAN          -- used to exit children loop in recursion when recursive function done (ex. child added)
	cat_subtree: ARRAYED_TREE[STRING]	-- used in tree search

feature {NONE} -- Initialization

	make
		do
			create cat_tree.make (10, "RootCat")
			cat_tree.compare_objects
			cat_subtree := cat_tree
		end

feature {ANY} -- cmd

	Add_TopCategory(cat: STRING)
		require
			cat_not_exists: not Category_Exist(cat)
		do
			cat_tree.child_extend (cat.twin)
		ensure
			cat_exists: Category_Exist(cat)
		end

	Add_SubCategory(subcat: STRING; parentcat: STRING)
		require
			subcat_not_exists: not Category_Exist(subcat)
			parent_exists: Category_Exist(parentcat)
		do
			recurse_found := false
			search_cat_recurse(cat_tree, parentcat)	-- search will succeed (PRE: parent exist)
			cat_subtree.child_extend (subcat.twin)
		ensure
			cat_exists: Category_Exist(subcat)
		end

	-- Note: this will delete the whole subcategory tree of the given cat
	Del_Category(cat: STRING)
		require
			cat_exists: Category_Exist(cat)
		local
			parent_cat: ARRAYED_TREE[STRING]
		do
			recurse_found := false
			search_cat_recurse(cat_tree, cat)	-- search will succeed (PRE: parent exist)
			parent_cat := cat_subtree.parent
			if parent_cat /= void then
				from parent_cat.child_start
				until parent_cat.child_after
				loop
					if parent_cat.child.item.is_equal (cat) then
						parent_cat.remove_child
					else
						parent_cat.child_forth
					end
				end
			end
		ensure
			cat_not_exists: not Category_Exist(cat)
		end

feature {ANY} -- bool queries

	Category_Exist(cname: STRING) : BOOLEAN
		do
			Result := cat_tree.has (cname)
		end

feature {ANY} -- search queries

	Top_Categories: LIST[STRING]
		do
			Result := all_child_cats(cat_tree)
		end

	Sub_Categories(parentcat: STRING): LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			cat_subtree := cat_tree
			recurse_found := false
			search_cat_recurse(cat_tree, parentcat)
			if recurse_found then
				Result := all_child_cats(cat_subtree)
			else
				create res_str.make (0)  -- not found, returns an empty list
				Result := res_str
			end
		end

feature {NONE} -- private helpers

	all_child_cats(subtree: ARRAYED_TREE[STRING]): LIST[STRING]
		local
			res_str: ARRAYED_LIST[STRING]
		do
			create res_str.make (subtree.child_capacity)  --check, too much!?
			from subtree.child_start
			until subtree.child_after
			loop
				res_str.extend (subtree.child.item.twin)  -- adds copy!
				subtree.child_forth
			end

			Result := res_str
		end

	search_cat_recurse(subtree: ARRAYED_TREE[STRING]; cname: STRING)
		do
			if subtree.item.is_equal(cname) then
				cat_subtree := subtree
				recurse_found := true
			else
				from subtree.child_start
				until subtree.child_after or recurse_found
				loop
					search_cat_recurse(subtree.child, cname)
					subtree.child_forth
				end
			end
		end

end
