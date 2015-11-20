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
		if name:sub(-1,-1) ~= "/" then name = name.."/" end
		local name,path,dir = self:ChangeDir(name,false,true)
		dir[name] = {
			[".."] = dir,
			__ident = dir..name.."/"
		}
	end

	function FS:Delete(name)
		local name,path,dir = self:ChangeDir(name,true)
		self.currentDir[name] = nil
	end

	function FS:CreateFile(name,data)
		local name,path,dir = self:ChangeDir(name,true)
		if(type(dir[name]) == "table") then
			error("Attempt to create a file with the same identifier as a folder")
		else
			dir[name] = data or ""
		end
	end

	function FS:ChangeDir(path,doFileName,ignoreLastDir)
		local cDir,cPath
		if(path:sub(1,1) == "/") then
			cDir = self.data
			cPath = "/"
		else
			cDir = self.currentDir
			cPath = self.path
		end

		if ignoreLastDir then
			path = path:match("(.+)/.-/")
		end

		for dir in path:gmatch("([^/]+)/") do
			if(type(cDir[dir]) == "table") then
				cDir = cDir[dir]
				cPath = cDir.__ident
			else
				error(cPath..dir.." is not a folder!")
			end
		end

		if doFileName then
			local fileName,_ = path:match("[^/]+$")

			if not fileName or fileName == "" then
				error("Expected a filename in the filepath string!")
			else
				return fileName,cPath,cDir
			end
		elseif(doFileName == false) then
			local folderName,_ = path:match("([^/]+)/$")

			if not folderName or folderName == "" then
				error("Expected a folder name in the filepath string!")
			else
				return folderName,cPath,cDir
			end
		else
			self.currentDir = cDir
			self.path = cPath
		end
	end

	function FS:SearchFileName(name,recurse)
		local startPath = self.path

		local returnData = {false}

		for identifier,value in pairs(self.currentDir) do
			if(identifier ~= "..") then
				if(type(value) == "table") then
					if(recurse) then
						self:ChangeDir(identifier)
						returnData = {self:SearchFileName(name)}
						if returnData[1] then
							break
						end
					end
				else
					if(identifier:match(name)) then
						returnData = {name,value,self.path}
						break
					end
				end
			end
		end

		self:ChangeDir(startPath)
		return unpack(returnData)
	end
end
