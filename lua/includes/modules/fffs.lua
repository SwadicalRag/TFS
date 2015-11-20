local FFFS = {}

FFFS.BaseFS = {}
do
	local FS = FFFS.BaseFS

	FS.data = {
		[".."] = FS.data,
		__ident = "/"
	}
	FS.currentDir = FS.data
	FS.path = "/"

	function FS:CreateDir(name)
		self.currentDir[name] = {
			[".."] = self.currentDir,
			__ident = self.path..name.."/"
		}
	end

	function FS:Delete(name)
		self.currentDir[name] = nil
	end

	function FS:CreateFile(name,data)
		if(type(self.currentDir[name]) == "table") then
			error("Attempt to create a file with the same identifier as a folder")
		else
			self.currentDir[name] = data or ""
		end
	end

	function FS:ChangeDir(name)
		if(type(self.currentDir[name]) == "table") then
			self.currentDir = self.currentDir[name]
			self.path = self.path..name.."/"
		else
			error(self.path..name.." is not a directory!")
		end
	end

	function FS:Search(name)
		-- to-do
	end
end
