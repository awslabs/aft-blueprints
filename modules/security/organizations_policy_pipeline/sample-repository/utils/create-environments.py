# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import boto3
import json
import argparse
import sys 

parser = argparse.ArgumentParser(description='AWS Organization environments creation')
parser.add_argument('--policy-type', action="store", dest='policy_type')
args = parser.parse_args()


def get_all_accounts():
    print("Getting all AWS accounts...")
    accounts = {}
    client = boto3.client('organizations')
    paginator = client.get_paginator('list_accounts')
    
    account_count = 0
    for page in paginator.paginate():
        for account in page['Accounts']:
            accounts[account['Id']] = account['Name']
            account_count += 1
    
    print(f"Found {account_count} accounts in the organization")
    return accounts

def get_ou_details():
    print("Getting all Organizational Units...")
    ous = {}
    client = boto3.client('organizations')
    
    roots = client.list_roots()['Roots']
    root_id = roots[0]['Id']
    
    def get_child_ous(parent_id):
        paginator = client.get_paginator('list_organizational_units_for_parent')
        try:
            for page in paginator.paginate(ParentId=parent_id):
                for ou in page['OrganizationalUnits']:
                    ous[ou['Id']] = ou['Name']
                    get_child_ous(ou['Id'])
        except client.exceptions.ParentNotFoundException:
            pass
    
    get_child_ous(root_id)
    print(f"Found {len(ous)} Organizational Units")
    return ous

def get_scp_targets():
    print("Getting Service Control Policies...")
    client = boto3.client('organizations')
    result = []
    
    accounts = get_all_accounts()
    ous = get_ou_details()
    
    paginator = client.get_paginator('list_policies')
    
    policy_count = 0
    skipped_count = 0
    processed_count = 0

    policy_type = ""
    if args.policy_type == 'scp':
        policy_type = "SERVICE_CONTROL_POLICY"
    elif args.policy_type == 'rcp':
        policy_type = "RESOURCE_CONTROL_POLICY"
    else:
        print("Policy type não suportado")
        exit()
    
    for page in paginator.paginate(Filter=policy_type):
        for policy in page['Policies']:
            policy_count += 1
            print(f"\nProcessing {args.policy_type}: {policy['Name']}")
            
            if (policy['Name'].startswith('aws-guardrails-') or 
                policy['Name'] == 'FullAWSAccess' or 
                policy['Name'] == 'RCPFullAWSAccess' or 
                policy['Name'].startswith('AWSControlTower-Controls')):
                print(f"Skipping excluded policy: {policy['Name']}")
                skipped_count += 1
                continue
                
            targets = []
            
            try:
                paginator_targets = client.get_paginator('list_targets_for_policy')
                target_count = 0
                for target_page in paginator_targets.paginate(PolicyId=policy['Id']):
                    for target in target_page['Targets']:
                        if target['Type'] == 'ACCOUNT':
                            if target['TargetId'] in accounts:
                                targets.append(f"{accounts[target['TargetId']]}:{target['TargetId']}")
                                target_count += 1
                        elif target['Type'] == 'ORGANIZATIONAL_UNIT':
                            if target['TargetId'] in ous:
                                targets.append(f"{ous[target['TargetId']]}:{target['TargetId']}")
                                target_count += 1
                
                print(f"Found {target_count} targets for policy {policy['Name']}")
                
                if targets:  # Only add policies that have targets
                    result.append({
                        "ID": policy['Name'],
                        "Target": targets
                    })
                    processed_count += 1
                else:
                    print(f"No targets found for policy {policy['Name']}")
                    
            except client.exceptions.PolicyNotFoundException:
                print(f"Policy {policy['Name']} not found")
                continue
    
    print("\nSummary:")
    print(f"Total {args.policy_type}s found: {policy_count}")
    print(f"Skipped {args.policy_type}s: {skipped_count}")
    print(f"Processed {args.policy_type}s: {processed_count}")
    
    return result

def main():
    
    if args.policy_type is None:
        print ("Usage: python " + str(sys.argv[0]) +  " --policy-type <scp or rcp>")
        print ("Example: python " + str(sys.argv[0]) +  " --policy-type scp")
        exit()
            
    try:
        print("Starting {args.policy_type} target analysis...")
        
        scp_data = get_scp_targets()
        
        output_file = f'environments-{args.policy_type}-based.json'
        print(f"\nWriting results to {output_file}...")
        with open(output_file, 'w') as f:
            json.dump(scp_data, f, indent=4)
        
        print(f"Successfully created {output_file}")
        print(f"Found {len(scp_data)} {args.policy_type}s with targets")
        
    except Exception as e:
        print(f"\nAn error occurred: {str(e)}")

if __name__ == "__main__":
    main()
