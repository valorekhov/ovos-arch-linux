## A module for parsing Makefiles (.mk) format
##

function Parse-MakeFile {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
        [string]$FilePath
    )

    # Read the contents of the Make file
    $content = Get-Content -Path $FilePath

    # Define a regular expression pattern to match Makefile variables
    $variablePattern = '^\s*([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.+)$'
    $continuationPattern = '^\s*\t(.+)$'

    # Create an empty hashtable to store the parsed variables
    $variables = @{}

    # Iterate over each line in the Make file
    for ($i = 0; $i -lt $content.Length; $i++) {
        $line = $content[$i]

        # Check if the line matches the variable pattern
        if ($line -match $variablePattern) {
            # Extract the variable name and value
            $variableName = $matches[1]
            $variableValue = $matches[2]

            # Check if the value spans multiple lines
            if ($variableValue.TrimEnd().EndsWith('\')) {
                # Remove the continuation character
                $variableValue = $variableValue.TrimEnd('\')

                # Append subsequent lines until the continuation character is not found
                do {
                    $i++
                    $nextLine = $content[$i]
                    $variableValue += "`n" + $nextLine.Trim()
                } while ($nextLine -match $continuationPattern)
            }

            # Store the variable in the hashtable
            $variables[$variableName] = $variableValue
        }
    }

    # Return the parsed variables hashtable
    return $variables
}
