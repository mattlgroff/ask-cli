param([string]$savePath)

if (-not $savePath) {
    throw "No save path was provided. Please specify a base path for the screenshots."
}

function Take-Screenshot {
    param(
        [string]$savePath,
        [System.Windows.Forms.Screen]$screen
    )

    # Capture the screen to a Bitmap
    $bounds = $screen.Bounds
    $bitmap = New-Object System.Drawing.Bitmap $bounds.width, $bounds.height
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($bounds.Location, [System.Drawing.Point]::Empty, $bounds.size)

    # Save the bitmap to a file
    $bitmap.Save($savePath)

    # Dispose of the graphic objects to free up resources
    $graphics.Dispose()
    $bitmap.Dispose()
}

# Load the necessary assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Take a screenshot of each screen
foreach ($screen in [System.Windows.Forms.Screen]::AllScreens) {
    $index = [System.Windows.Forms.Screen]::AllScreens.IndexOf($screen)
    $filename = $savePath + "_screen_$index.png"
    Take-Screenshot -savePath $filename -screen $screen
}
