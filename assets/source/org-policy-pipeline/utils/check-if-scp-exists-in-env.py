import json
import boto3
import sys
import argparse

def load_environments(file_path):
    """Load environments from JSON file"""
    try:
        with open(file_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: File {file_path} is not valid JSON")
        sys.exit(1)

def get_policy_targets(policy_name, policy_type):
    """Get all targets for a specific SCP"""
    print(f"\nGetting targets for SCP: {policy_name}")
    client = boto3.client('organizations')
    targets = []

    try:
        # First, find the policy ID
        paginator = client.get_paginator('list_policies')
        policy_id = None
        
        temp_policy = ""
        if policy_type == 'scp':
            temp_policy = "SERVICE_CONTROL_POLICY"
        elif policy_type == 'rcp':
            temp_policy = "RESOURCE_CONTROL_POLICY"
        else:
            print("Policy type não suportado")
            exit()        
            
        for page in paginator.paginate(Filter=temp_policy):
            for policy in page['Policies']:
                if policy['Name'] == policy_name:
                    policy_id = policy['Id']
                    break
            if policy_id:
                break

        if not policy_id:
            print(f"Error: SCP '{policy_name}' not found")
            sys.exit(1)

        # Get all targets for the policy
        paginator_targets = client.get_paginator('list_targets_for_policy')
        for page in paginator_targets.paginate(PolicyId=policy_id):
            for target in page['Targets']:
                targets.append(target['TargetId'])
        
        print(f"Found {len(targets)} targets for SCP {policy_name}")
        return targets

    except client.exceptions.PolicyNotFoundException:
        print(f"Error: SCP '{policy_name}' not found")
        sys.exit(1)
    except Exception as e:
        print(f"Error getting SCP targets: {str(e)}")
        sys.exit(1)

def check_policy_coverage(environments, policy_targets, env_id):
    env = None
    for environment in environments:
        if environment['ID'] == env_id:
            env = environment
            break

    if not env:
        print(f"Error: Environment ID '{env_id}' not found")
        sys.exit(1)

    print(f"\nChecking targets for environment: {env_id}")
    
    # Extract target IDs from the environment
    env_targets = []
    missing_targets = []
    
    for target in env['Target']:
        target_id = target.split(':')[1]  # Get the ID part after the colon
        env_targets.append(target_id)
        if target_id not in policy_targets:
            missing_targets.append(target)

    # Results
    total_targets = len(env_targets)
    covered_targets = total_targets - len(missing_targets)
    
    print("\nResults:")
    print(f"Total targets in environment: {total_targets}")
    print(f"Targets covered by SCP: {covered_targets}")
    
    if missing_targets:
        print(f"\n[WARNING] The following targets DOT NOT have the SCP:")
        for target in missing_targets:
            print(f"- {target}")
        return False
    else:
        print("\nAll targets are covered by the SCP!")
        return True

def main():
    # Set up argument parser
    parser = argparse.ArgumentParser(description='Check SCP coverage for environment targets')
    parser.add_argument('--policy-type', required=True, help='Type of the policy to check')
    parser.add_argument('--policy-name', required=True, help='Name of the policy to check')
    parser.add_argument('--env-id', required=True, help='Environment ID to check')
    
    args = parser.parse_args()

    # Load environments from file
    environments = load_environments("../environments/environments.json")

    # Get SCP targets
    policy_targets = get_policy_targets(args.policy_name, args.policy_type)

    # Check coverage
    is_fully_covered = check_policy_coverage(environments, policy_targets, args.env_id)

    # Exit with appropriate status code
    sys.exit(0 if is_fully_covered else 1)

if __name__ == "__main__":
    main()
