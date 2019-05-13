# Use the latest stable "ALPINE" image from Docker Hub as the parent image
FROM alpine:3.9

LABEL version="1.0"
LABEL maintainer="bleken@gmail.com"

# Set timeezone to Oslo
ENV TZ Europe/Oslo

# Define environment variables to be used in our .sh-script
# ENV DOCKER_OUTPUT_DIR output

# Update all Alpine Linux packages
RUN apk update 

# Install the extra packages we need.
# OPTION "--no-cache": avoid caching the index locally, to keep containers small.
RUN apk add --no-cache tzdata bash join column curl jq

# WORKDIR: Setting the working directory to "/app".
#  1) Affects all subsequent commands in this Dockerfile (CMD, COPY etc),
#  2) Also affects commands executed in a container based on this image.
WORKDIR /app

# COPY: Copy files from a source on the host to the container’s own filesystem at the set destination.

# Copy our "shell script" to "WORKDIR" in the container's filesystem
COPY ./citybikestatus.sh ./citybikestatus.sh

# Make sure the shell script is executable
# RUN chmod +x ./citybikestatus.sh

# Make port 80 available to the world outside this container
# EXPOSE 80

# ENTRYPOINT: command that will be executed first when a container is created.
#
# NOTE: Docker has a default entrypoint which is "/bin/sh -c", but it does not have a default command (CMD).
# NOTE: Use ENTRYPOINT e.g. when you want to use the Docker image as an "executable".  
#
# NB! We decided to use only CMD, without ENTRYPOINT, since using 
#     the "shebang" at the first line of a ".sh" script invokes "bash". 
ENTRYPOINT ["/bin/bash"]

# VOLUME: Enable access from the container to a directory on the host machine.
# NOT USED: we wil use "Bind mounts" instead to mount "host directories" to directories in the running container.

# CMD: Execute a specific command within the container.
# NOTE: The main purpose of a CMD is to provide defaults for an executing container. 
#
# Run the bash "shell script" when the container launches:
# CMD ["./citybikestatus.sh"]
