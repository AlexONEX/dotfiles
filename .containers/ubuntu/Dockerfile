FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    python3 python3-pip \
    software-properties-common

RUN pip install python-a2s

WORKDIR /app

CMD ["/bin/bash"]
