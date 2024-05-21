#!/usr/bin/env python3
import json
import os
import psycopg2

#define function to read json file
def read_json_file(file_name):
    with open(file_name) as f:
        data = json.load(f)
    return data

#define function to connect to postgresql
def connect_db():
    conn = psycopg2.connect("dbname=postgres user=postgres password=postgres host=aidp-pi26-psql-1.eaas.KUKU.com")
    cur = conn.cursor()
    return conn, cur

#define function to read from postgresql
def read_from_db(cur):
    cur.execute("SELECT * FROM test_json;")
    rows = cur.fetchall()
    for row in rows:
        print(row)


#define function to create table with jsonb column
def create_table_with_jsonb_column(cur):
    cur.execute("DROP TABLE IF EXISTS test_json;")
    cur.execute("CREATE TABLE test_json (id serial PRIMARY KEY, doc jsonb NOT NULL);")
    conn.commit()


#call function connect_db
conn, cur = connect_db()

create_table_with_jsonb_column(cur)

#loop on files in directory
for file in os.listdir("/JSON"):
    print(file)
    f = open("/JSON/"+file)
    data = json.load(f)
    # print(data)
#insert into table
    for i in data:
        cur.execute("INSERT INTO test_json (doc) VALUES (%s)", (json.dumps(i),))

#commit the transaction
conn.commit()

# for i in data['accountName']:
#     print(i['currency'])
