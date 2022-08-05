FROM ubuntu:20.04
WORKDIR /root
COPY . .
RUN apt update \
	&& apt-get install acl \
	&& apt-get install -y bc \
	&& apt-get install -y python3
ENTRYPOINT ["./runset.sh"]

