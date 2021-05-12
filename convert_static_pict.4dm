$projectPath:="...:Project:Sources:"
$archivePath:=System folder(Desktop)

For each ($folderName;New collection("Forms";"TableForms"))
	
	$src:=$projectPath+$folderName+Folder separator
	$dst:=$archivePath+$folderName+Folder separator
	
	DOCUMENT LIST($src;$paths;Recursive parsing | Ignore invisible | Absolute path)
	
	For ($i;1;Size of array($paths))
		$path:=$paths{$i}
		$o:=Path to object($path)
		Case of 
			: ($o.extension=".pict")
				DOCUMENT TO BLOB($path;$DATA)  //READ PICTURE FILE falis on .pict
				BLOB TO PICTURE($DATA;$PICT;".pict")
				CONVERT PICTURE($PICT;".png")
				TRANSFORM PICTURE($PICT;Transparency;0x0FFFFFFF)
				$pngPath:=$o.parentFolder+$o.name+".png"
				WRITE PICTURE FILE($pngPath;$PICT;".png")
				$dstPath:=Replace string($path;$src;$dst)
				CREATE FOLDER(Path to object($dstPath).parentFolder;*)
				MOVE DOCUMENT($path;$dstPath)
			: ($o.extension=".4DForm")
				$json:=Document to text($path)
				$n:=JSON Parse($json)
				For each ($page;$n.pages)
					If ($page#Null)
						For each ($object;$page.objects)
							If ($page.objects[$object].type="picture")
								If ($page.objects[$object].picture#Null)
									$page.objects[$object].picture:=Replace string($page.objects[$object].picture;".pict";".png";*)
								End if 
							End if 
						End for each 
					End if 
				End for each 
				$json:=JSON Stringify($n;*)
				TEXT TO DOCUMENT($path;$json;"utf-8";Document with LF)
		End case 
	End for 
	
End for each 
