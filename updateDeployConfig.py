import os, time, sys
import json, argparse
import boto3

parser=argparse.ArgumentParser()

parser.add_argument('--env', help='ex: external-dev')

args=parser.parse_args()

if (args.env=='None'):
    print("Please provide environment name.")
    exit()
else:
  environment = args.env

#Load json parameters file
print("Uploading deployment config to AWS SSM...")
inFile =  environment + '-parameters.json'

with open(os.path.join(sys.path[0], inFile), "r") as inputFile:
    data = json.load(inputFile)

region = data['/path/region']

ssm_client = boto3.client('ssm', region_name=region)
for parameter in data:
    key = parameter
    value = data[parameter]
    response = ssm_client.put_parameter(
                Name=key,
                Description='string',
                Value=value,
                Overwrite=True,
                Tier='Standard'
            )
    print(response)
print("Done - Uploading deployment config to AWS SSM.")
