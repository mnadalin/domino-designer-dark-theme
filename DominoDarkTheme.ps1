# Function to read the DATADIR path from the Windows Registry
function Get-DataDirPath {
	$registryPath = "HKCU:\Software\HCL\Notes\Installer"
	$registryKey = "DATADIR"

	try {
		$dataDir = Get-ItemProperty -Path $registryPath -Name $registryKey | Select-Object -ExpandProperty $registryKey
		if ($dataDir) {
			$finalPath = "$($dataDir.TrimEnd("\\"))\workspace\.metadata\.plugins\org.eclipse.core.runtime\.settings"
			Write-Host "DATADIR found: $dataDir"
			Write-Host "Final working directory: $finalPath"
			if (-Not (Test-Path $finalPath)) {
				Write-Host "Error: The working directory does not exist: $finalPath"
				exit 1
			}
			return $finalPath
		} else {
			Write-Host "Error: DATADIR key not found in registry."
			exit 1
		}
	} catch {
		Write-Host "Error: Unable to read registry key. $_"
		exit 1
	}
}

# Function to update or append a key-value pair in a given file
function Update-Config {
	param (
		[string]$filePath,
		[string]$key,
		[string]$newValue
	)

	# Ensure file exists before modifying
	if (-Not (Test-Path $filePath)) {
		$fileName = Split-Path -Path $filePath -Leaf
		Write-Host "Warning: File not found: $fileName. Creating a new one."
		New-Item -ItemType File -Path $filePath -Force | Out-Null
	}

	# Read the file content
	$content = Get-Content $filePath
	$escapedKey = [regex]::Escape($key)  # Escape regex characters in key
	$pattern = "^$escapedKey(\\=|=).*"  # Handle escaped `=` in key
	$found = $false

	# Check if the key exists and update it
	for ($i = 0; $i -lt $content.Count; $i++) {
		if ($content[$i] -match $pattern) {
			$content[$i] = "$key=$newValue"  # Update existing key
			$found = $true
			break
		}
	}

	# If key was not found, append it
	if (-Not $found) {
		$content += "$key=$newValue"
	}

	# Write updated content back to file
	$content | Set-Content $filePath
}

# Get the DATADIR path from the registry
$dataDir = Get-DataDirPath

# Define configuration files and key-value pairs
$filesAndSettings = @{
	"com.ibm.designer.domino.lscript.prefs" = @{
		"com.ibm.designer.domino.scripting.lscript.editor.textfont" = "fontFamily\=Consolas;fontSize\=12;normalText\=rgb(156,220,254) 0;identifiers\=rgb(204,204,204) 0;keywords\=rgb(86,156,214) 0;comments\=rgb(106,153,85) 0;multilineComments\=rgb(106,153,85) 0;constants\=rgb(206,145,120) 0;directives\=rgb(197,134,192) 0"
	}
	"org.eclipse.jdt.ui.prefs" = @{
		"java_bracket" = "222,114,228"
		"java_comment_task_tag" = "106,153,85"
		"java_comment_task_tag_bold" = "false"
		"java_default" = "204,204,204"
		"java_doc_default" = "106,153,62"
		"java_doc_keyword" = "86,156,214"
		"java_doc_link" = "106,153,62"
		"java_doc_tag" = "106,153,62"
		"java_keyword" = "84,156,215"
		"java_keyword_bold" = "false"
		"java_keyword_return" = "222,114,228"
		"java_keyword_return_bold" = "false"
		"java_multi_line_comment" = "106,153,85"
		"java_operator" = "212,212,212"
		"java_single_line_comment" = "106,153,85"
		"java_string" = "205,145,120"
		"org.eclipse.jface.textfont" = "1|Consolas|12.0|0|WINDOWS|1|-16|0|0|0|400|0|0|0|0|3|2|1|49|Consolas;"
		"semanticHighlighting.abstractClass.color" = "79,193,255"
		"semanticHighlighting.abstractClass.enabled" = "true"
		"semanticHighlighting.abstractMethodInvocation.color" = "255,0,128"
		"semanticHighlighting.annotation.color" = "78,201,176"
		"semanticHighlighting.class.color" = "78,201,176"
		"semanticHighlighting.class.enabled" = "true"
		"semanticHighlighting.deprecatedMember.color" = "255,64,64"
		"semanticHighlighting.field.color" = "156,220,254"
		"semanticHighlighting.inheritedField.color" = "204,204,204"
		"semanticHighlighting.inheritedField.enabled" = "true"
		"semanticHighlighting.interface.color" = "86,156,214"
		"semanticHighlighting.localVariable.color" = "156,220,254"
		"semanticHighlighting.localVariableDeclaration.bold" = "false"
		"semanticHighlighting.localVariableDeclaration.color" = "158,234,255"
		"semanticHighlighting.localVariableDeclaration.enabled" = "true"
		"semanticHighlighting.method.color" = "234,236,177"
		"semanticHighlighting.method.enabled" = "true"
		"semanticHighlighting.methodDeclarationName.bold" = "false"
		"semanticHighlighting.methodDeclarationName.color" = "234,236,177"
		"semanticHighlighting.methodDeclarationName.enabled" = "true"
		"semanticHighlighting.number.color" = "181,206,168"
		"semanticHighlighting.number.enabled" = "true"
		"semanticHighlighting.parameterVariable.color" = "156,220,254"
		"semanticHighlighting.parameterVariable.enabled" = "true"
		"semanticHighlighting.staticField.color" = "156,220,254"
		"semanticHighlighting.staticField.italic" = "false"
		"semanticHighlighting.staticFinalField.bold" = "false"
		"semanticHighlighting.staticFinalField.color" = "156,220,254"
		"semanticHighlighting.staticFinalField.italic" = "false"
		"semanticHighlighting.staticMethodInvocation.color" = "220,220,170"
		"semanticHighlighting.staticMethodInvocation.italic" = "false"
		"semanticHighlighting.typeArgument.color" = "78,201,176"
		"semanticHighlighting.typeArgument.enabled" = "true"
		"sourceHoverBackgroundColor" = "31,31,31"
		"sourceHoverBackgroundColor.SystemDefault" = "false"
	}
	"org.eclipse.ui.editors.prefs" = @{
		"AbstractTextEditor.Color.Background" = "31,31,31"
		"AbstractTextEditor.Color.Background.SystemDefault" = "false"
		"AbstractTextEditor.Color.FindScope" = "255,255,0"
		"AbstractTextEditor.Color.Foreground" = "204,204,204"
		"AbstractTextEditor.Color.Foreground.SystemDefault" = "false"
		"AbstractTextEditor.Color.SelectionBackground" = "55,55,61"
		"AbstractTextEditor.Color.SelectionBackground.SystemDefault" = "false"
		"AbstractTextEditor.Color.SelectionForeground" = "204,204,204"
		"AbstractTextEditor.Color.SelectionForeground.SystemDefault" = "false"
		"currentLineColor" = "24,24,24"
		"hyperlinkColor" = "78,148,206"
		"hyperlinkColor.SystemDefault" = "false"
		"lineNumberColor" = "192,192,192"
		"lineNumberRuler" = "true"
		"occurrenceIndicationColor" = "98,51,21"
		"printMarginColor" = "0,0,0"
		"writeOccurrenceIndicationColor" = "98,51,21"
	}
	"org.eclipse.ui.workbench.prefs" = @{
		"com.ibm.v11.theme.org.eclipse.jdt.internal.ui.compare.JavaMergeViewer" = "1|Consolas|12.0|0|WINDOWS|1|-16|0|0|0|400|0|0|0|0|3|2|1|49|Consolas;"
		"org.eclipse.jdt.ui.editors.textfont" = "1|Consolas|12.0|0|WINDOWS|1|-16|0|0|0|400|0|0|0|0|3|2|1|49|Consolas;"
	}
	"org.eclipse.wst.jsdt.ui.prefs" = @{
		"java_bracket" = "255,215,0"
		"java_comment_task_tag" = "106,153,85"
		"java_comment_task_tag_bold" = "false"
		"java_default" = "220,220,170"
		"java_keyword" = "86,156,214"
		"java_keyword_bold" = "false"
		"java_keyword_return" = "197,134,192"
		"java_keyword_return_bold" = "false"
		"java_multi_line_comment" = "106,153,85"
		"java_operator" = "212,212,212"
		"java_single_line_comment" = "106,153,85"
		"java_string" = "206,145,120"
		"javascript_template_literal" = "206,145,120"
		"org.eclipse.jface.textfont" = "1|Consolas|10.0|0|WINDOWS|1|0|0|0|0|0|0|0|0|1|0|0|0|0|Consolas;"
		"semanticHighlighting.deprecatedMember.color" = "255,0,0"
		"semanticHighlighting.localVariable.color" = "79,193,255"
		"semanticHighlighting.localVariable.enabled" = "true"
		"semanticHighlighting.localVariableDeclaration.color" = "79,193,255"
		"semanticHighlighting.localVariableDeclaration.enabled" = "true"
		"semanticHighlighting.method.color" = "86,156,214"
		"semanticHighlighting.method.enabled" = "true"
		"semanticHighlighting.methodDeclarationName.bold" = "false"
		"semanticHighlighting.methodDeclarationName.color" = "86,156,214"
		"semanticHighlighting.methodDeclarationName.enabled" = "true"
		"semanticHighlighting.objectInitializer.bold" = "false"
		"semanticHighlighting.objectInitializer.color" = "255,0,128"
		"semanticHighlighting.parameterVariable.enabled" = "true"
		"sourceHoverBackgroundColor" = "255,255,225"
	}
}

# Loop through files and update configurations
foreach ($file in $filesAndSettings.Keys) {
	$filePath = "$dataDir\$file"
	$fileName = Split-Path -Path $filePath -Leaf

	Write-Host "Now updating file: $fileName"

	foreach ($key in $filesAndSettings[$file].Keys) {
		$newValue = $filesAndSettings[$file][$key]
		Update-Config -filePath $filePath -key $key -newValue $newValue
	}
}

Write-Host "Configuration updates completed successfully."
