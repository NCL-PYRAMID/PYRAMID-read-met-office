# PYRAMID-read-met-office
Application to read Met Office C-band composite rainfall radar data

## About
This application reads C-band composite rainfall radar from the Met Office CEDA facility.

### Notes
- Large chunk of messy Met Office code at the beginning.
- The ftp server requires a CEDA username and password, these credentials will be passed in as parameters, However an account for PYRAMID should probably be created.
- This is currently set to get the rainfall data (gridded composite radar 1km resolution data) for the Toon Monsoon rainfall event for Newcastle upon Tyne.
- TO DO: Replace copied nimrod code with a GitHub subproject

### What does the code do?
- Creates a list of file names (daily) to look for on the ftp server.
- Downloads daily .tar files.
- Unzips the files and extracts 5min .dat files.
- Uses Met Office nimrod code to read in the .dat files, and clips using specified bounding box.
- Saves the raw 5 and 15 min files (just as .npy files, I would usually save them as .h5 files however I don't think at any point the data will get too big at the moment.

### Outputs format
- `./data/outputs` folder path - this will be `/data/outputs` in a Docker container
  - `/MET` folder path (5 minute radar data)
    - `arrays.npy` - radar data arrays (t, y, x)
    - `timestamp.csv`- radar data timestamp
    - `coords_x.csv` - radar data x-coordinates
    - `coords_y.csv` - radar data y-coordinates
    - `/15min` folder path (15 minute radar data)
      - `arrays.npy` - radar data arrays (t, y, x)
      - `timestamp.csv` - radar data timestamp
      - `coords_x.csv` - radar data x-coordinates
      - `coords_y.csv` - radar data y-coordinates

### Project Team
Amy Green, Newcastle University  ([amy.green3@newcastle.ac.uk](mailto:amy.green3@newcastle.ac.uk))  
Elizabeth Lewis, Newcastle University  ([elizabeth.lewis2@newcastle.ac.uk](mailto:elizabeth.lewis2@newcastle.ac.uk))  

### RSE Contact
Robin Wardle  
RSE Team, NICD  
Newcastle University NE1 7RU  
([robin.wardle@newcastle.ac.uk](mailto:robin.wardle@newcastle.ac.uk))  

## Built With
[Python 3.9](https://www.python.org/)

[Anaconda](https://www.anaconda.com/)

[Docker](https://www.docker.com)  

Other required tools: [tar](https://www.unix.com/man-page/linux/1/tar/), [zip](https://www.unix.com/man-page/linux/1/gzip/).

## Getting Started

### Prerequisites
Python 3.9 is required to run the Python script, and Docker also needs to be installed. If working on a Windows system, it is recommended that [WSL](https://learn.microsoft.com/en-us/windows/wsl/install) is used for any local Docker builds; a) because DAFNI requires Linux Docker images, and b) native command-line Linux tools are much superior to those provided by Windows.

A [CEDA](https://www.ceda.ac.uk/) account is required. The account username and password are read from environment variables (see "Running Locally" below).

An up-to-date version of [Anaconda](https://www.anaconda.com/) must be installed.

### Installation
The models are Python 3 scripts and need no installation for local execution. Deployment to DAFNI is covered below.

### Running Locally
The model can be run in a `bash` shell in the repository directory.

```
export CEDA_USERNAME=<ceda_username>
export CEDA_PASSWORD=<ceda_password>
conda create --name read-met-office -f environment.yml
conda activate read-met-office
python -u read_met_office.py
```
The application will download data files from CEDA and organise them into a unified data set as described above. To clean up and reset the file and environment state to previously, enter the following shell commands:
```
rm -r ./data
unset CEDA_USERNAME
unset CEDA_PASSWORD
```

### Running Tests
There are no additional tests at present.

## Deployment

### Local
Local deployment consists of the creation and testing of a Docker image. A local Docker container can be built and executed using (with the correct CEDA username and password):
```
sudo docker build . -t pyramid-read-met-office -f Dockerfile
sudo docker run -v "$(pwd)/data:/data"
  -e CEDA_USERNAME=<username> \
  -e CEDA_PASSWORD=<password> \
  pyramid-read-met-office:latest
```
Note that output from the container, placed in the `./data` subdirectory, will have `root` ownership as a result of the way in which Docker's access permissions work. To clean up, from within the repository root. WARNING, BE VERY CAREFUL RUNNING `sudo rm -r` FROM WITHIN THE WRONG DIRECTORY!
```
sudo rm -r data
```

### Production
#### Manual upload to DAFNI
The model is containerised using Docker, and the image is _tar_'ed and _zip_'ed for uploading to DAFNI. Use the following commands in a *nix shell to accomplish this.

```
docker build . -t pyramid-read-met-office -f Dockerfile
docker save -o pyramid-read-met-office.tar pyramid-read-met-office:latest
gzip pyramid-read-met-office.tar
```

The `pyramid-read-met-office.tar.gz` Docker image and accompanying DAFNI model definition file `model-definition.yml` should be uploaded as new DAFNI models using the "Add model" facility at [https://facility.secure.dafni.rl.ac.uk/models/](https://facility.secure.dafni.rl.ac.uk/models/). Alternatively, the existing model can be updated manually in DAFNI by locating the relevant model through the DAFNI UI, selecting "Edit Model", uploading a new image and / or metadata file, and incrementing the semantic version number in the "Version Message" field appropriately.

As of 05/07/2023 the read-met-office DAFNI parent model UUID is
| Model | UUID |
| --- | --- |
| read-met-office | (TBC)) |

#### CI/CD with GitHub Actions
The model can be deployed to DAFNi using GitHub Actions. The relevant workflows are built into the model repository and use the [DAFNI Model Uploader Action](https://github.com/dafnifacility/dafni-model-uploader) to update the DAFNI model. The workflows trigger on the creation of a new release tag which follows [semantic versioning](https://semver.org/) and takes the format `vx.y.z` where `x` is a major release, `y` a minor release, and `z` a patch release.

The DAFNI model upload process is prone to failing, often during model ingestion, in which case a deployment action will show a failed status. Such deployment failures might be a result of a DAFNI timeout, or there might be a problem with the model build. It is possible to re-run the action in GitHub if it is evident that the failure is as a result of a DAFNI timeout. However, deployment failures caused by programming errors (e.g. an error in the model definition file) that are fixed as part of the deployment process will **not** be included in the tagged release! It is thus best practice in case of a deployment failure always to delete the version tag and to go through the release process again, re-creating the version tag and re-triggering the workflows.

The DAFNI model upload process requires valid user credentials. These are stored in the NCL-PYRAMID organization "Actions secrets and variables", and are:
```
DAFNI_SERVICE_ACCOUNT_USERNAME
DAFNI_SERVICE_ACCOUNT_PASSWORD
```
Any NCL-PYRAMID member with a valid DAFNI login may update these credentials.

## Usage
The deployed models can be run in a DAFNI workflow. See the [DAFNI workflow documentation](https://docs.secure.dafni.rl.ac.uk/docs/how-to/how-to-create-a-workflow) for details.

## Roadmap
- [x] Initial Research  
- [x] Minimum viable product
- [x] Alpha Release  
- [ ] Feature-Complete Release  

## Contributing
The PYRAMID project has ended. Pull requests from outside the project team will be ignored.

### Main Branch
The stable branch is `main`. All development should take place on new branches. Pull requests are enabled on `main`.

## License
Pending.

## Acknowledgements
This work was funded by NERC, grant ref. NE/V00378X/1, “PYRAMID: Platform for dYnamic, hyper-resolution, near-real time flood Risk AssessMent Integrating repurposed and novel Data sources”. See the project funding [URL](https://gtr.ukri.org/projects?ref=NE/V00378X/1).

