import json
import boto3
import sys
import argparse

parser = argparse.ArgumentParser(description='AWS Organization Policy capacity')
parser.add_argument('--policy-type', action="store", dest='policy_type')
args = parser.parse_args()

def get_target_policies(organizations_client, target):
    try:
        name, target_id = target.split(':')
        
        print(f"{name} Processando target")
        
        policy_type = ""
        if args.policy_type == 'scp':
            policy_type = "SERVICE_CONTROL_POLICY"
        elif args.policy_type == 'rcp':
            policy_type = "RESOURCE_CONTROL_POLICY"
        else:
            print("Policy type não suportado")
            exit()
        
        if target_id.startswith('ou-'):
            response = organizations_client.list_policies_for_target(
                TargetId=target_id,
                Filter=policy_type
            )
        else:
            response = organizations_client.list_policies_for_target(
                TargetId=target_id,
                Filter=policy_type
            )
        
        num_policies = len(response['Policies'])
        print(f"      Found {num_policies} policies")
        return num_policies
    
    except organizations_client.exceptions.TargetNotFoundException:
        print(f"Erro: Target não encontrado")
        return "Target not found"
    except Exception as e:
        print(f"      Erro: {str(e)}")
        return f"Erro: {str(e)}"

def process_scp_limits(input_file, output_file):
    try:
        organizations_client = boto3.client('organizations')
        
        print(f"Lendo arquivo de input: {input_file}")
        with open(input_file, 'r') as f:
            statements = json.load(f)
        
        print(f"Processando {len(statements)} statements...")
        output_data = []
        for i, statement in enumerate(statements, 1):
            print(f"Processando statement {i}/{len(statements)}: {statement['ID']}")
            processed_statement = {
                "ID": statement["ID"],
                "Target": {}
            }
            
            for target in statement["Target"]:
                num_policies = get_target_policies(organizations_client, target)
                processed_statement["Target"][target] = f"{num_policies}/5"
            
            output_data.append(processed_statement)
        
        print(f"\nArmazenando resultados em {output_file}")
        with open(output_file, 'w') as f:
            json.dump(output_data, indent=2, fp=f)
            
        print(f"Processamento completo. Results salvos em {output_file}")
        
    except Exception as e:
        print(f"Error occurred: {str(e)}")
        sys.exit(1)

def main():
    
    if args.policy_type is None:
        print ("Usage: python " + str(sys.argv[0]) +  " --policy-type <scp or rcp>")
        print ("Example: python " + str(sys.argv[0]) +  " --policy-type scp")
        exit()
            
    input_file = "../environments/environments.json" 
    output_file = f"environments-{str(args.policy_type)}-slots.json" 
    
    process_scp_limits(input_file, output_file)

if __name__ == "__main__":
    main()
