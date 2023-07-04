RUNNING_PLATFORM="${READ_EXTERNAL_ENV:-shell}"

echo "Running in $RUNNING_PLATFORM"

python -u reading_in_data.py
python -u merging_rainfall.py
python -u write_output_metadata.py

if [ "$RUNNING_PLATFORM" == "docker" ];
then
  cp -r /data/stage_one/outputs/* /data/outputs
else
  cp -r ./data/stage_one/outputs/* ./data/outputs
fi
