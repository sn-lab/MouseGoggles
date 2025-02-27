#saveUtils.gc
extends Object
class_name saveUtils

#save logged data to .txt file (csv format)
static func save_logs(currentRep,dataLog,dataNames,timestamp,sceneName):
	var file = File.new()
	var numColumns = dataNames.size()
	var numRows = dataLog.size()/numColumns
	var n = 0
	var fileName = "res://logs//" + timestamp + "_" + sceneName + "_rep" + String(currentRep) + "_godotlogs.txt"
	
	if (file.open(fileName, File.WRITE)== OK):
		
		#add row 1 header for data names
		for i in range(numColumns):
			file.store_string(String(dataNames[i]))
			if i<(numColumns-1):
				file.store_string(",")
		file.store_string("\r")
		
		#add new rows for each frame of logged data
		for l in range(numRows):
			for i in range(numColumns):
				file.store_string(String(dataLog[n]))
				if i<(numColumns-1):
					file.store_string(",")
				n = n+1
			file.store_string("\r")
		file.close()
		
	else:
		print("Failed to save logged data to ", fileName)
