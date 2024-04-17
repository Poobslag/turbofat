# zip_exec (Version: 20210707)

## Description

zip_exec is a program designed to set the executable flag of a file within a zip archive.
This tool is particularly useful on Windows systems when creating zip files containing
valid executables that will be unpacked on Linux or macOS.

## Installation

Before using zip_exec, you may need to install vcredist_x86.exe, which can be downloaded
from Microsoft's website: https://learn.microsoft.com/en-us/cpp/windows/latest-supported-
vc-redist?view=msvc-170#visual-studio-2013-vc-120

## Usage

To use zip_exec, simply provide the path to the zip file and the path to the file within
the zip archive that you want to mark as executable.

### Example command line

zip_exec.exe "C:\path_to_zip\file.zip" "some_path/some_file_in_the_zip.exe"

## Note

When using zip_exec on macOS or Linux, Unix attributes will be set on all files and
directories within the zip archive:

- Directories:  drw-r--r--
- Executables:  -rwxr-xr-x
- Normal files: -rw-r--r--
