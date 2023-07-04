# PYRAMID-read-met-office

## Reading in Met Office C-band composite radar data
### Notes
- Large chunk of messy Met Office code at the beginning.
- The ftp server requires a CEDA username and password, these credentials will be passed in as parameters, However an account for PYRAMID should probably be created.
- This is currently set to get the rainfall data (gridded composite radar 1km resolution data) for the Toon Monsoon rainfall event for Newcastle upon Tyne.
- TO DO: Create requirements.txt.
- TO DO: Replace copied nimrod code with a GitHub subproject

### What does the code do?
- Creates a list of file names (daily) to look for on the ftp server.
- Downloads daily .tar files.
- Unzips the files and extracts 5min .dat files.
- Uses Met Office nimrod code to read in the .dat files, and clips using specified bounding box.
- Saves the raw 5 and 15 min files (just as .npy files, I would usually save them as .h5 files however I don't think at any point the data will get too big at the moment.

### Outputs format
- `\root` folder path
  - `\MET` folder path (5 minute radar data)
    - `arrays.npy` - radar data arrays (t, y, x)
    - `timestamp.csv`- radar data timestamp
    - `coords_x.csv` - radar data x-coordinates
    - `coords_y.csv` - radar data y-coordinates
    - `\15min` folder path (15 minute radar data)
      - `arrays.npy` - radar data arrays (t, y, x)
      - `timestamp.csv` - radar data timestamp
      - `coords_x.csv` - radar data x-coordinates
      - `coords_y.csv` - radar data y-coordinates
