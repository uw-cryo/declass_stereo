#! /usr/bin/env python

"""
First request API and db access through EarthExplorer: https://ers.cr.usgs.gov/profile/access
https://earthexplorer.usgs.gov/inventory/documentation
The snippet below (from Scott Henderson) will generate a dictionary of available records in EarthExplorer.

DES query on 2019-03-11
Download-ready/total:
27K/837K declass1
4K/47K declass2
2K/40K declass3

Example download for LS8: https://github.com/scottyhq/usgs-json-api/blob/master/0-usgs-api.ipynb

Amaury Dehecq has separate tool to query EE API to extract metadata for individual scenes
"""

import requests
import json
payload = dict(username=XXXXXXXX, password=XXXXXXXXX, catalogId='EE', authType='EROS')
data = dict(jsonRequest=json.dumps(payload))
r = requests.post('https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/login', data=data)
creds = r.json()
apiKey = creds['data']
request_code = 'datasets'
baseurl = f'https://earthexplorer.usgs.gov/inventory/json/v/1.4.0/{request_code}'
payload = {'apiKey':apiKey, 'datasetName':'CORONA2'}
data = dict(jsonRequest=json.dumps(payload))
r = requests.get(baseurl, params=data)
print(r.url)
r.json()
