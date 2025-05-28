#! /bin/bash
#
# Copyright Amazon.com, Inc. or its affiliates. All rights reserved.
# SPDX-License-Identifier: Apache-2.0

if (($# < 2))
then
  echo "Provide ACCOUNT ID as the first parameter and the Terraform COMMAND(s) as the second one."
  echo "Usage: ./<script_name>.sh <ACCOUNT ID> <TF COMMAND>"
  exit
elif [[ ! $1 =~ ^[0-9]{12}$ ]]
then
  echo "Provide a valid ACCOUNT ID with 12 digits."
  exit
fi

TF_ARGS=${@#"$1"}
TF_VAR_FILE="aft-input.auto.tfvars"
VENDED_ACCOUNT_ID=$1
AWS_PARTITION="aws"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

if [[ "$PWD" == *aft-account-customizations* ]]
then
  TF_S3_KEY=$VENDED_ACCOUNT_ID-aft-account-customizations/terraform.tfstate
elif [[ "$PWD" == *aft-global-customizations* ]]
then
  TF_S3_KEY=$VENDED_ACCOUNT_ID-aft-global-customizations/terraform.tfstate
else
  echo "Run aft-local from the aft-account-customizations or aft-global-customizations repository."
  exit
fi

if [[ ! "$PWD" == */terraform ]]
then
  echo "Run aft-local from the customizations terraform folder."
  exit
fi

set_up_profile()
{
  local account_id=$1
  local role_name=$2
  local profile_name=$3
  
  echo "Setting up $profile_name aws profile..."

  local credentials=(`aws sts assume-role \
    --role-arn arn:aws:iam::${account_id}:role/${role_name} \
    --role-session-name ${ROLE_SESSION_NAME} \
    --query '[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]' \
    --output text`)
  
  aws configure set aws_access_key_id ${credentials[0]} --profile $profile_name
  aws configure set aws_secret_access_key ${credentials[1]} --profile $profile_name
  aws configure set aws_session_token ${credentials[2]} --profile $profile_name
}

echo "Retrieving AFT SSM Parameters..."
CT_MGMT_REGION=$(aws ssm get-parameter --name "/aft/config/ct-management-region" --query "Parameter.Value" --output text)
ROLE_SESSION_NAME=$(aws ssm get-parameter --name /aft/resources/iam/aft-session-name --query "Parameter.Value" --output text)
AFT_MGMT_ACCOUNT=$(aws ssm get-parameter --name "/aft/account/aft-management/account-id" --query "Parameter.Value" --output text)
AFT_ADMIN_ROLE_NAME=$(aws ssm get-parameter --name /aft/resources/iam/aft-administrator-role-name --query "Parameter.Value" --output text)
AFT_ADMIN_PROFILE="$AFT_MGMT_ACCOUNT-$AFT_ADMIN_ROLE_NAME"

set_up_profile $AFT_MGMT_ACCOUNT $AFT_ADMIN_ROLE_NAME $AFT_ADMIN_PROFILE

if [[ "$TF_ARGS" == *init* ]]
then
  TF_DISTRIBUTION=$(aws ssm get-parameter --name "/aft/config/terraform/distribution" --query "Parameter.Value" --output text)
  AFT_EXEC_ROLE_NAME=$(aws ssm get-parameter --name /aft/resources/iam/aft-execution-role-name --query "Parameter.Value" --output text)
  TF_BACKEND_REGION=$(aws ssm get-parameter --name "/aft/config/oss-backend/primary-region" --query "Parameter.Value" --output text)
  TF_KMS_KEY_ID=$(aws ssm get-parameter --name "/aft/config/oss-backend/kms-key-id" --query "Parameter.Value" --output text)
  TF_DDB_TABLE=$(aws ssm get-parameter --name "/aft/config/oss-backend/table-id" --query "Parameter.Value" --output text)
  TF_S3_BUCKET=$(aws ssm get-parameter --name "/aft/config/oss-backend/bucket-id" --query "Parameter.Value" --output text)
  AFT_EXEC_PROFILE="$VENDED_ACCOUNT_ID-$AFT_EXEC_ROLE_NAME"

  echo "Updating jinja files..."
  for f in *.jinja
  do 
    jinja2 $f -D timestamp="$TIMESTAMP" \
              -D tf_distribution_type=$TF_DISTRIBUTION \
              -D provider_region=$CT_MGMT_REGION \
              -D region=$TF_BACKEND_REGION \
              -D aft_admin_role_arn="arn:$AWS_PARTITION:iam::$AFT_MGMT_ACCOUNT:role/$AFT_EXEC_ROLE_NAME" \
              -D target_admin_role_arn="arn:$AWS_PARTITION:iam::$VENDED_ACCOUNT_ID:role/$AFT_EXEC_ROLE_NAME" \
              -D bucket=$TF_S3_BUCKET \
              -D key=$TF_S3_KEY \
              -D dynamodb_table=$TF_DDB_TABLE \
              -D kms_key_id=$TF_KMS_KEY_ID > ./$(basename $f .jinja).tf
  done
fi

unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_SESSION_TOKEN
unset AWS_PROFILE
unset AWS_REGION

export AWS_PROFILE=$AFT_ADMIN_PROFILE
export AWS_REGION=$CT_MGMT_REGION

echo "Running command: terraform $TF_ARGS"
terraform $TF_ARGS