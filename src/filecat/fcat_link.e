note
	description: "Represents an association between filename-category; to be used by FCC"

class FCAT_LINK

inherit ANY
	redefine is_equal
end

create make

feature {ANY} -- Read-only Data members (attributes)

	filename: STRING
	category: STRING

feature {NONE} -- Initialization

	make (fname: STRING; cat: STRING)
		do
			filename := fname
			category := cat
		end

feature {ANY}

	-- redefinition for is_equal so that it compares the string objects not their refs!
	is_equal (other: like Current): BOOLEAN
		do
			Result := filename.is_equal (other.filename) and
					  category.is_equal (other.category)
		end

end
