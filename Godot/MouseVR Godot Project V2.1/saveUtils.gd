#saveUtils.gc
extends Object
class_name saveUtils


static func save_logs(currentRep, dataLog, dataNames, experimentName):
	# Create directory path
	var save_dir = "res://logs/" + experimentName
	var dir = Directory.new()
	
	# Create directory if it doesn't exist
	if not dir.dir_exists(save_dir):
		var err = dir.make_dir_recursive(save_dir)
		if err != OK:
			print("Failed to create directory: ", save_dir)
			return
	 
	# Create file path
	var file_path = "%s/rep_%04d_godotlogs.txt" % [save_dir, currentRep]
	var file = File.new()
	var numColumns = dataNames.size()
	var numRows = dataLog.size()/numColumns
	var n = 0
	
	# Open and write to file
	if file.open(file_path, File.WRITE) == OK:
		# Write header row
		for i in range(numColumns):
			file.store_string(dataNames[i])
			if i < (numColumns-1):
				file.store_string(",")
		file.store_string("\n")
			
		# Write data rows
		for l in range(numRows):
			for i in range(numColumns):
				file.store_string(String(dataLog[n]))
				if i < (numColumns-1):
					file.store_string(",")
				n += 1
			file.store_string("\n")
		file.close()
	else:
		print("Failed to save logged data to ", save_dir)
