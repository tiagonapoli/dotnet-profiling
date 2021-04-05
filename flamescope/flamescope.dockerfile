# Credits to @marcel-dempers
# https://github.com/marcel-dempers/my-desktop/blob/master/dockerfiles/flamescope/dockerfile

FROM python:3-alpine3.8

RUN apk update && apk add --no-cache git

RUN mkdir /src && cd /src/ && \
	git clone https://github.com/Netflix/flamescope.git && \
	cd flamescope && \
	git checkout 8eee5949c138c868895fa4db7982375f28b17cdf

WORKDIR /src/flamescope/

RUN mkdir /app/ && cp -R ./app /app/ && \
	cp ./run.py /app/ && \
	cp ./requirements.txt /app/

RUN apk add libmagic && \
  cd /app && \
  pip3 install -r requirements.txt && \
  mkdir /profiles && \
  sed -i -e s/127.0.0.1/0.0.0.0/g -e s~examples~/profiles~g app/config.py

WORKDIR "/app"
ENTRYPOINT ["python", "run.py"]
EXPOSE 5000/tcp