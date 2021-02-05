FROM openjdk:8-jdk-buster

ENV YCSB_VERSION 0.17.0

RUN apt-get update && apt-get install -y \
  curl \
  tar

RUN curl -L https://github.com/brianfrankcooper/YCSB/releases/download/${YCSB_VERSION}/ycsb-mongodb-binding-${YCSB_VERSION}.tar.gz -o ycsb-mongodb-binding-${YCSB_VERSION}.tar.gz && \
  tar xf ycsb-mongodb-binding-${YCSB_VERSION}.tar.gz && \
  mv ycsb-mongodb-binding-${YCSB_VERSION} ycsb && \
  rm -f ycsb-mongodb-binding-${YCSB_VERSION}.tar.gz

WORKDIR /ycsb/bin

CMD ["ycsb","--help"]
ENTRYPOINT ["ycsb"]
