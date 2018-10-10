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
import re
###########################################
#FILL IN THE FOLLOWING VARIABLES FOR YOUR LOGS BEFORE RUNNING
#Set equal to destination index name
index_name = 'index_name'
#Set equal to the column number (beginning with 0) that contains the datetime
datetime_colnum = 4
#Set equal to the column number (beginning with 0) that contains the audit date (json column)
auditdata_colnum = 7
#set equal to the header in the first column
header1 = 'PSComputerName'
# Supporting variables - you can and should change these to reflect your environment.
maxmind_db_location = './maxmind/GeoLite2-Country.mmdb'
elastic_server = '<insert_elastic_server>:<insert_elastic_port>'
#############################################

#############################################
#Json fixing functions
# class for stacks
class Stack(object):
    def __init__(self):
        self.items = []
    # method for determining if stack has contents
    def isEmpty(self):
        return self.items == []
    # method to add item to stack
    def push(self,item):
        self.items.append(item)
    # method for removing and returning the top item from the stack
    def pop(self):
        return self.items.pop()
    # method for returning the top item from the stack
    def peek(self):
        return self.items[-1]
    # method to return the size of the stack
    def size(self):
        return len(self.items)
    # method for printing a stack
    def __str__(self):
        return str(self.items)

#function that checks if parenthesis and brackets are balanced        
def parChecker(symbolString):
    s = Stack()
    balanced = True
    index = 0
    while index < len(symbolString) and balanced:
        symbol = symbolString[index]
        if symbol in '([{':
            s.push(symbol)
        else:
            if s.isEmpty():
                balanced = False
            else:
                top = s.pop()
                if not matches(top,symbol):
                    balanced = False
        index = index + 1
    if balanced and s.isEmpty():
        return "Balanced"
    else:
        return s
		

#function that checks if inputs are a bracket pair match        
def matches(open,close):
    opens = '([{"'
    closers = ')]}"'
    return opens.index(open) == closers.index(close)

#function that appends needed closing parenthesis or bracket    
def append_closers(json_str,missing):
    opens = '([{"'
    closers = ')]}"'
    for i in range(missing.size()):
        closer_index = opens.index(missing.pop())
        json_str += closers[closer_index]
    return json_str
    
#function that fixes truncated json string    
def fix_json(json_str):
      while json_str[len(json_str)-1] != "}":
          json_str = json_str[:len(json_str)-1]
      chars = ""
      for word in json_str:
          if word in ["{","}","[","]"]:
              chars += word
      missing_closers = parChecker(chars)
      if missing_closers == "Balanced":
          print("Json is already balanced") 
          return json_str 
      fixed_json = append_closers(json_str,missing_closers)
      return fixed_json

# end of json fixing code
#############################################

# Initialize Elastic; insert your server IP address here
es = Elasticsearch([elastic_server])

# Initialize GeoIP
reader = geoip2.database.Reader(maxmind_db_location)
source_file = sys.argv[1]
with open(sys.argv[1]) as f:
    lines = f.readlines()
    data = csv.reader(lines)

# Create IP regex pattern to match against
ip_pattern = re.compile("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")

# Parsing Details
print("File in progress: {0}".format(sys.argv[1]))
print("Attempting to parse and ingest {0} lines.".format(len(lines)))

# Error & Checksums
i = 0
j = 0

for line in data:
# checking for header line and skipping it if present
    if line[0] == header1 or line[0] == '#TYPE Deserialized.Microsoft.Exchange.Data.ApplicationLogic.UnifiedAuditLogEvent':
        print('Skipping header or non-data line')
        i += 1
        continue
    i += 1
    doc = {}
    doc['Timestamp'] = line[datetime_colnum]
    auditdata_col = line[auditdata_colnum]
    
	# Skipping userid and operation fields. They are also present in AuditData.
    # AuditData Field Conversion to JSON.
    try:
        json_audit_data = json.loads(auditdata_col)
    except ValueError:
	# if json cannot be loaded, check for json data and attempt to fix broken json
        if auditdata_col[0] == "{":
            print("Line {0} may have broken json. Attempting to fix now".format(i))
            auditdata_col = fix_json(auditdata_col)
        else:
            print("Line doesn't contain audit data. Skipping")
            continue
        try:
		#load "fixed" json and send error message if it is not fixed
            json_audit_data = json.loads(auditdata_col)
        except ValueError:
            j+=1
            print("Could not fix json on line {0}".format(i))
            continue
        print("json successfully fixed") 
    try:
		#iterate through json items and add properties to elastic search array
        for k, v in json_audit_data.items():
            doc[k] = v
        if doc.has_key('ExtendedProperties'):
            for item in doc['ExtendedProperties']:
                    doc["ExtendedProperties.{0}".format(item["Name"])] = item["Value"]
            doc.__delitem__('ExtendedProperties')
            if doc.has_key('Actor'):
                type_2 = .1 
                for item in doc['Actor']:
                   if item["Type"] != 2:
                       doc["Actor.{0}".format(item["Type"])] = item["ID"]
                   else:
                       doc["Actor.{0}".format(item["Type"]+type_2,'.1f')] = item["ID"]
                       print(doc["Actor.{0}".format(item["Type"] + type_2, '.1f')])
                       type_2 += .1
                doc.__delitem__('Actor')
        if doc.has_key('ClientIP'):
            if ip_pattern.match(doc['ClientIP']):
                ip_addr = doc['ClientIP']
                if ':' in ip_addr:
                    ip_addr = ip_addr.split(':')[0]
                try:
                    response = reader.country(ip_addr)
                    doc['iso_code'] = response.country.iso_code
                except:
                    print("invalid or internal IP. Line {0}".format(i))                 
        if doc.has_key('ClientIPAddress'):
            if ip_pattern.match(doc['ClientIPAddress']):         
                response = reader.country(doc['ClientIPAddress'])
                doc['iso_code'] = response.country.iso_code      
      
	    #lower case UserId and Actor fields for consistency
        if 'Actor.5' in doc:
            doc['Actor.5'] = doc['Actor.5'].lower()
        if 'ExtendedProperties.UserId' in doc:
            doc['ExtendedProperties.UserId'] = doc['ExtendedProperties.UserId'].lower()
        if 'UserId' in doc:
            doc['UserId'] = doc['UserId'].lower()
   
        #add source column to index dictionary (to tell which file logs came from)
        doc['source'] = source_file 
       
	    # The following is an extremely inefficient ingestion tool. Need to convert this to bulk ingestion.
        es.index(index=index_name, doc_type="o365_exchange_audit_log", body=doc)
    except ValueError:
        j += 1
        print("Line {0} appears to be malformed - please check. Skipping for now.".format(i))
# Print out details
print("\nParsing Complete! Details on parsing:\nLines successful:\t{0}\nLines failed:\t\t{1}\n" \
        "Please correct broken lines and ingest separately.".format(i-j, j)) 
