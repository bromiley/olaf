#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""OLAF - Audit Log Parser. Because logs love warm hugs too."""

__version__     = "1.0"
__author__      = "Matt Bromiley; @mbromileyDFIR"
__copyright__   = "Copyright 2018"
__maintainer__  = "Matt Bromiley; @mbromileyDFIR"
__status__      = "Development"

import sys
import csv
import json
from elasticsearch import Elasticsearch
import geoip2.database

# Supporting variables - you can and should change these to reflect your environment.
maxmind_db_location = './maxmind/GeoLite2-Country.mmdb'
elastic_server = '<insert_elastic_server>:<insert_elastic_port>'

# Initialize Elastic; insert your server IP address here
es = Elasticsearch([elastic_server])

# Initialize GeoIP
reader = geoip2.database.Reader(maxmind_db_location)

with open(sys.argv[1]) as f:
    lines = f.readlines()[1:]
    data = csv.reader(lines)

# Parsing Details
print("Attempting to parse and ingest {0} lines.".format(len(lines)))

# Error & Checksums
i = 0
j = 0

for line in data:
    i += 1
    doc = {}
    doc['Timestamp'] = line[0]
    # Skipping userid and operation fields. They are also present in AuditData.
    # AuditData Conversion to JSON.
    try:
        json_audit_data = json.loads(line[3])
        for k, v in json_audit_data.items():
            doc[k] = v
        if 'ExtendedProperties' in doc:
            for item in doc['ExtendedProperties']:
                    doc["ExtendedProperties.{0}".format(item["Name"])] = item["Value"]
            doc.__delitem__('ExtendedProperties')
        if 'Actor' in doc:
            for item in doc['Actor']:
                    doc["Actor.{0}".format(item["Type"])] = item["ID"]
            doc.__delitem__('Actor')
        if 'ClientIP' in doc:
            ip_addr = doc['ClientIP']
            if ':' in ip_addr:
                ip_addr = ip_addr.split(':')[0]
            response = reader.country(ip_addr)
            doc['iso_code'] = response.country.iso_code                
        if 'ClientIPAddress' in doc:
            response = reader.country(doc['ClientIPAddress'])
            doc['iso_code'] = response.country.iso_code       
        # The following is an extremely inefficient ingestion tool. Need to convert this to bulk ingestion.
        es.index(index="o365_logs", doc_type="o365_exchange_audit_log", body=doc)
    except ValueError:
        j += 1
        print("Line {0} appears to be malformed - please check. Skipping for now.".format(i))
# Print out details
print("\nParsing Complete! Details on parsing:\nLines successful:\t{0}\nLines failed:\t\t{1}\n" \
        "Please correct broken lines and ingest separately.".format(i-j, j)) 
