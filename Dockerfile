FROM python

WORKDIR /usr/src

RUN pip install pip --upgrade 

RUN apt-get update &&\
    apt-get install sqlite3

COPY requirements.txt .
COPY app.py .
COPY *.json .

RUN pip install -r requirements.txt

RUN sqlite3 bookstore.db

CMD ["python", "app.py"]
