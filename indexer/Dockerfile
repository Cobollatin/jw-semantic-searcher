FROM ubuntu:20.04
USER root
WORKDIR /indexer
COPY . .
RUN chmod +x run.sh
ENTRYPOINT ["./run.sh"]