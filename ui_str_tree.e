note
	description: "EV_TREE of strings"

class UI_STR_TREE

create make

feature {NONE} -- Initialization

	ref_tree: EV_TREE
	recurse_found: BOOLEAN

feature {ANY}

	make( dt: EV_TREE)
		do
			ref_tree := dt
		end

	add(txt_parent: STRING; txt_sub: STRING)
		local
			newpath: EV_TREE_ITEM
			sub_node: EV_TREE_ITEM
		do
			if ref_tree.is_empty then
				create newpath.make_with_text (txt_parent)
				create sub_node.make_with_text (txt_sub)
				newpath.extend (sub_node)
				ref_tree.extend (newpath)
			else
				recurse_found := false
				ref_tree.start
				add_sub_item_recurse(ref_tree.item, txt_parent, txt_sub)
			end
		end


feature {NONE} -- Helpers

	add_sub_item_recurse( parent_node: EV_TREE_NODE; txt_parent: STRING; txt_sub: STRING )
		local
			sub_node: EV_TREE_ITEM
		do
			if parent_node.text.is_equal (txt_parent) then
				create sub_node.make_with_text (txt_sub)
				parent_node.extend (sub_node)
				recurse_found := true
			else
				from parent_node.start
				until parent_node.off or recurse_found
				loop
					add_sub_item_recurse(parent_node.item, txt_parent, txt_sub)
					parent_node.forth
				end
			end
		end

end
