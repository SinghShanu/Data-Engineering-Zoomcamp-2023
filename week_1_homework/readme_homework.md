Question 1. Knowing docker tags

    Run the command to get information on Docker

    docker --help

    Now run the command to get help on the "docker build" command

    Which tag has the following text? - Write the image ID to the file

        docker build --help

        --iidfile string   -->  Write the image ID to the file

Question 2. Understanding docker first run

    Run docker with the python:3.9 image in an interactive mode and the entrypoint of bash. Now check the python modules that are installed ( use pip list). How many python packages/modules are installed? --> By default, 3 python packages/modules are installed

    $ docker run -it python:3.9 bash
    Unable to find image 'python:3.9' locally
    3.9: Pulling from library/python
    bbeef03cda1f: Pull complete 
    f049f75f014e: Pull complete 
    56261d0e6b05: Pull complete 
    9bd150679dbd: Pull complete 
    5b282ee9da04: Pull complete 
    03f027d5e312: Pull complete 
    3c8304b923fa: Pull complete 
    1f510f0937ac: Pull complete 
    cb0f5bf32016: Pull complete 
    Digest: sha256:4b7ee97f021e0d1f5749ea3ad6d1bae1ca15a9b42cdebcf40269502d54f56666
    Status: Downloaded newer image for python:3.9
    root@a7b6ce26a457:/# pip list
    Package    Version
    ---------- -------
    pip        22.0.4
    setuptools 58.1.0
    wheel      0.38.4
    WARNING: You are using pip version 22.0.4; however, version 22.3.1 is available.
    You should consider upgrading via the '/usr/local/bin/python -m pip install --upgrade pip' command.
    root@a7b6ce26a457:/#