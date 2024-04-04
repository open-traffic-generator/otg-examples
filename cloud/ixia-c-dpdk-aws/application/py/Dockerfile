FROM python:3.10

RUN mkdir /snappi
WORKDIR /snappi

# copy the dependencies file to the working directory
COPY requirements.txt .

# install dependencies
RUN apt-get update
RUN apt-get install jq -y
RUN pip install -r requirements.txt

CMD ["tail","-f","/dev/null"]