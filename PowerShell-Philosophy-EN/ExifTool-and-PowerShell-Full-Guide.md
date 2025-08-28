# Full Guide to ExifTool and PowerShell

Every time you take a photo, your camera records not only the image itself but also service information into the file: camera and lens model, date and time of shooting, shutter speed, aperture, ISO, GPS coordinates. This data is called **EXIF (Exchangeable Image File Format)**.

While PowerShell has built-in tools for reading some metadata, they are limited. To access **all** information, a specialized tool is needed. In this article, I use **ExifTool**.

**ExifTool** is a free, cross-platform, open-source utility written by Phil Harvey. It is the gold standard for reading, writing, and editing metadata in a wide variety of file formats (images, audio, video, PDF, etc.). ExifTool knows thousands of tags from hundreds of device manufacturers, making it the most comprehensive tool in its class.

### Downloading and Correct Setup

Before writing any code, you need to prepare the utility itself.

1.  Go to the **official ExifTool website: [https://exiftool.org/](https://exiftool.org/)**. On the main page, find and download **"Windows Executable"**.

2.  **Renaming (Critically Important Step!):** The downloaded file will be named `exiftool(-k).exe`. This is not accidental.

    Rename it to **`exiftool.exe`** to **disable the "pause" mode**, which is intended for users who launch the program by double-clicking.

3.  **Storage:** You have two main options for where to store `exiftool.exe`.
    *   **Option 1 (Simple): In the same folder as your script.** This is the easiest way. Your PowerShell script will always be able to find the utility because it's located nearby. Ideal for portable scripts that you move from computer to computer.
    *   **Option 2 (Recommended for frequent use): In a folder from the system `PATH` variable.** The `PATH` variable is a list of directories where Windows and PowerShell automatically search for executable files.
        You can create a folder (e.g., `C:\Tools`), put `exiftool.exe` there, and add `C:\Tools` to the system `PATH` variable.
        After that, you can call `exiftool.exe` from any folder in any console.

Scripts for adding to `$PATH`:
Adding a directory to `PATH` for the CURRENT USER
Adding a directory to the SYSTEM `PATH` for ALL USERS

---

## PowerShell and External Programs

To effectively use ExifTool, you need to know how PowerShell launches external `.exe` files.
The correct and most reliable way to run external programs is the **call operator `&` (ampersand)**.
PowerShell will throw an error if the program path contains spaces. For example, `C:\My Tools\exiftool.exe`.
`&` (ampersand) tells PowerShell: "The text that follows me in quotes is the path to the executable file. Run it, and everything that follows is its arguments."

```powershell
# Correct syntax
& "C:\Path With Spaces\program.exe" "argument 1" "argument 2"
```

Always use `&` when working with program paths in variables or paths that may contain spaces.

---

## Practical Tricks: ExifTool + PowerShell

Now let's combine our knowledge.

### Example #1: Basic Extraction and Interactive Viewing

The simplest way to get all data from a photo and examine it is to request it in JSON format and pass it to `Out-ConsoleGridView`.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# 1. Run exiftool with the -json flag for structured output
# 2. Convert JSON text to a PowerShell object
#    Call exiftool.exe directly, without a variable and the call operator &.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 3. Transform the "wide" object into a convenient "Parameter-Value" table
$reportData = $exifObject.psobject.Properties | Select-Object Name, Value

# 4. Output the result to an interactive window for analysis
$reportData | Out-ConsoleGridView -Title "File Metadata: $($photoPath | Split-Path -Leaf)"
```

This code will open an interactive window where you can sort data by parameter name or value, and filter it by simply starting to type text. This is incredibly convenient for quickly finding the necessary information.

### Example #2: Creating a Clean Report and Sending to Different "Devices"

`Out-ConsoleGridView` is just the beginning. You can direct processed data anywhere using other `Out-*` cmdlets.

Suppose we have data in the `$reportData` variable from the previous example.

#### **A) Sending to a CSV file for Excel**
```powershell
$reportData | Export-Csv -Path "C:\Reports\photo_exif.csv" -NoTypeInformation -Encoding UTF8
```
`Export-Csv` creates a perfectly structured file that can be opened in Excel or Google Sheets.

#### **B) Sending to a Text File**
```powershell
# For nice formatting, first use Format-Table
$reportData | Format-Table -AutoSize | Out-File -FilePath "C:\Reports\photo_exif.txt"
```
`Out-File` will save an exact text copy of what you see in the console to a file.

#### **C) Sending to Clipboard**
Want to quickly paste data into an email or chat? Use `Out-Clipboard`.
```powershell
$reportData | Format-Table -AutoSize | Out-String | Out-Clipboard
```

Now you can press `Ctrl+V` in any text editor and paste a neatly formatted table.

### Example #3: Getting Specific Data for Use in a Script

Often you don't need the entire report, but just one or two values. Since `$exifObject` is a regular PowerShell object, you can easily access its properties.

```powershell
$photoPath = "D:\Photos\IMG_1234.JPG"

# Call exiftool.exe directly by name.
# PowerShell will automatically find it in one of the folders listed in PATH.
$exifObject = exiftool.exe -json $photoPath | ConvertFrom-Json

# 1. Create one PowerShell object with understandable property names.
#    This is similar to creating a structured record.
$reportObject = [PSCustomObject]@{ 
    "Camera"           = $exifObject.Model
    "Date Taken"       = $exifObject.DateTimeOriginal
    "Sensitivity"      = $exifObject.ISO
    "File Name"        = $exifObject.FileName # Add file name for context
}

# 2. Output this object to an interactive window.
#    Out-GridView will automatically create columns from property names.
$reportObject | Out-ConsoleGridView -Title "File Metadata: $(Split-Path $photoPath -Leaf)"
```

This approach is the basis for any serious automation, such as renaming files based on the date taken, sorting photos by camera model, or adding watermarks with exposure information.

### Example #4: Batch Extraction of Metadata from a Folder

Sometimes you need to analyze not just one photo, but an entire folder of images.

```powershell
# Specify only the photo folder.
$photoFolder = "D:\Photos"

# Call exiftool.exe directly. No variable for the path and no & operator are needed.
$allExif = exiftool.exe -json "$photoFolder\*.jpg" | ConvertFrom-Json

# Transform into a convenient view
$report = foreach ($photo in $allExif) {
    [PSCustomObject]@{ 
        # --- Basic file and camera data ---
        FileName       = $photo.FileName
        DateTime       = $photo.DateTimeOriginal
        CameraMake     = $photo.Make                 # Manufacturer (e.g., "Canon", "SONY")
        CameraModel    = $photo.Model                 # Camera model (e.g., "EOS R5")
        LensModel      = $photo.LensID                # Full name of the lens model
        
        # --- Shooting parameters (exposure) ---
        ISO            = $photo.ISO
        ShutterSpeed   = $photo.ShutterSpeed
        Aperture       = $photo.Aperture
        FocalLength    = $photo.FocalLength           # Focal length (e.g., "50.0 mm")
        ExposureMode   = $photo.ExposureProgram       # Shooting mode (e.g., "Manual", "Aperture Priority")
        Flash          = $photo.Flash                 # Information about whether the flash fired
        
        # --- GPS and image data ---
        GPSPosition    = $photo.GPSPosition           # GPS coordinates as a single string (if available)
        Dimensions     = "$($photo.ImageWidth)x$($photo.ImageHeight)" # Image dimensions in pixels
    }
}

# Output data to an interactive table in the CONSOLE
$report | Out-ConsoleGridView -Title "Summary Report for Folder: $photoFolder"
```

💡 You get a neat table for the entire folder at once.

--- 

### Example #5: Recursive Search in Subfolders

ExifTool can search for files in all subfolders itself when using the `-r` flag.

```powershell
& $exifToolPath -r -json "D:\Photos" | ConvertFrom-Json |
    Select-Object FileName, Model, DateTimeOriginal |
    Export-Csv "C:\Reports\all_photos_recursive.csv" -NoTypeInformation -Encoding UTF8
```

--- 

### Example #6: Renaming Files by Date Taken

This is one of the most popular automation scenarios – files are named by the date/time they were taken.

```powershell
$exifToolPath = "C:\Tools\exiftool.exe"
$photoFolder = "D:\Photos"

# Rename to YYYY-MM-DD_HH-MM-SS.jpg format
& $exifToolPath -r -d "%Y-%m-%d_%H-%M-%S.%%e" "-FileName<DateTimeOriginal" $photoFolder
```

💡 *ExifTool will automatically insert the original file extension via `%%e`.*

--- 

### Example #7: Extracting Only GPS Coordinates

Useful if you want to build a map from your photos.

```powershell
# 1. Specify the path to the folder with your photos
$photoFolder = "E:\DCIM\Camera"

# 2. List the tags we need: file name and three GPS tags.
#    This makes the query much faster than if we were retrieving all tags.
$tagsToExtract = @(
    "-SourceFile", # SourceFile is better than FileName, as it usually contains the full path
    "-GPSLatitude",
    "-GPSLongitude",
    "-GPSAltitude"
)

# 3. Call exiftool.exe directly (since it's in PATH).
#    The -r flag searches for files in all subfolders.
#    The result is immediately converted from JSON.
$allExifData = exiftool.exe -r -json $tagsToExtract $photoFolder | ConvertFrom-Json

# 4. Filter the results: keep ONLY those objects that have latitude and longitude.
$filesWithGps = $allExifData | Where-Object { $_.GPSLatitude -and $_.GPSLongitude }

# 5. Check if any files with GPS data were found at all
if ($filesWithGps) {
    # 6. Create a nice report from the filtered data.
    #    Use Select-Object to rename columns and format.
    $report = $filesWithGps | Select-Object @{Name="File Name"; Expression={Split-Path $_.SourceFile -Leaf}},
                                             @{Name="Latitude"; Expression={$_.GPSLatitude}},
                                             @{Name="Longitude"; Expression={$_.GPSLongitude}},
                                             @{Name="Altitude"; Expression={if ($_.GPSAltitude) { "$($_.GPSAltitude) m" } else { "N/A" }}}
    
    # 7. Output the final report to an interactive console table.
    $report | Out-ConsoleGridView -Title "Files with GPS data in folder: $photoFolder"

} else {
    # If nothing is found, politely inform the user.
    Write-Host "Files with GPS data in folder '$photoFolder' not found." -ForegroundColor Yellow
}
```

--- 

### Example #8: Bulk Deletion of All GPS Data (for privacy)

```powershell
# Delete all GPS tags from JPG and PNG
& $exifToolPath -r -overwrite_original -gps:all= "D:\Photos"
```

💡 *This action is irreversible, so back up before executing.*

--- 

### Example #9: Converting Shooting Time to Local Time

Sometimes photos are taken in a different time zone. ExifTool can shift the date.

```powershell
# Shift time by +3 hours
& $exifToolPath "-AllDates+=3:0:0" "D:\Photos\IMG_*.JPG"
```

--- 

### Example #10: Getting a List of All Unique Camera Models in a Folder

```powershell
$models = & $exifToolPath -r -Model -s3 "D:\Photos" | Sort-Object -Unique
$models | ForEach-Object { Write-Host "Model: $_" }
```

--- 

### Example #11: Outputting Only Necessary Tags in Tabular Form

```powershell
& $exifToolPath -T -Model -DateTimeOriginal -ISO -Aperture -ShutterSpeed "D:\Photos\IMG_1234.JPG"
```

`-T` outputs in a tab-separated tabular format – convenient for further processing.

--- 

### Example #12: Checking for GPS in a Large Array of Files

```powershell
$files = & $exifToolPath -r -if "$gpslatitude" -p '$FileName' "D:\Photos"
Write-Host "Files with GPS:"
$files
```

--- 

### Example #13: Copying Metadata from One File to Another

```powershell
# 1. Select the reference file
$sourceFile = Get-ChildItem "D:\Photos" -Filter "*.jpg" | Out-ConsoleGridView -Title "Select REFERENCE file"

# 2. If a reference is selected, select target files
if ($sourceFile) {
    $targetFiles = Get-ChildItem "D:\Photos\New" -Filter "*.jpg" | Out-ConsoleGridView -Title "Select TARGET files for metadata copying" -OutputMode Multiple
    
    # 3. If targets are selected, perform the copy
    if ($targetFiles) {
        & exiftool.exe -TagsFromFile $sourceFile.FullName ($targetFiles.FullName)
        Write-Host "Metadata copied from $($sourceFile.Name) to $($targetFiles.Count) files."
    }
}
```

--- 

### Example #14: Saving Original Metadata to a Separate JSON Before Modification

```powershell
$backupPath = "C:\Reports\metadata_backup.json"
& $exifToolPath -r -json "D:\Photos" | Out-File -Encoding UTF8 $backupPath
```

--- 

### Example #15: Using PowerShell for Automatic Photo Sorting by Date

```powershell
$photos = Get-ChildItem "D:\Photos" -Filter *.jpg -Recurse
foreach ($photo in $photos) {
    $meta = & $exifToolPath -json $photo.FullName | ConvertFrom-Json
    $date = Get-Date $meta.DateTimeOriginal -ErrorAction SilentlyContinue
    if ($date) {
        $targetFolder = "D:\Sorted\{0:yyyy}\{0:MM}" -f $date
        if (-not (Test-Path $targetFolder)) { New-Item -Path $targetFolder -ItemType Directory }
        Move-Item $photo.FullName -Destination $targetFolder
    }
}
```

--- 

### Example 16: Finding All Unique Camera Models in a Collection

While this can be done in one line, outputting to `GridView` allows you to immediately copy the desired model name.

```powershell
# The -s3 flag outputs only values, -Model - the tag name
$uniqueModels = & exiftool.exe -r -Model -s3 "D:\Photos" | Sort-Object -Unique

# Output to GridView for easy viewing and copying
$uniqueModels | Out-ConsoleGridView -Title "Unique camera models in collection"
```