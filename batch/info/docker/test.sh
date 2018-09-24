docker run -e INPUT_FILE='s3://entwine/ky/0-0-0-0-1005.laz' \
            -e HOME='/tmp' \
            -e AWS_ALLOW_INSTANCE_PROFILE='1' \
            -e ARBITER_VERBOSE='1' \
            /usr/bin/run.sh
