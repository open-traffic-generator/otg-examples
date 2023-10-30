FROM python:3.10

RUN mkdir /snappi
WORKDIR /snappi

# copy the dependencies file to the working directory
COPY requirements.txt .
COPY ./conformance/requirements.txt conformance-requirements.txt

# install dependencies
RUN pip install -r requirements.txt
RUN pip install -r conformance-requirements.txt

CMD ["tail","-f","/dev/null"]