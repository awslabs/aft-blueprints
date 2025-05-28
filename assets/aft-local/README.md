# AFT local script

## Purpose

This script runs a local copy of Terraform code as if it were running within AFT pipelines. It provides a way to run terraform locally using arguments that are currently not supported within the pipeline, such as `plan`, `move` or `refresh`.

## Prerequisites

* Run on a Unix shell, such as **bash** or **zsh**.
* Local copy of `aft-account-customizations` or `aft-global-customizations` repositories (`aft-account-provisioning-customizations` or `aft-account-request` are not supported).
* Terraform and Python installed and available on your local PATH.
* **jinja2** and **jinja2-cli** installed (e.g. `pip install jinja2 jinja2-cli`)
* AWS CLI installed and configured with credentials to access the AFT Management account.
* [Recommended] **.gitignore** file containing `**/backend.tf`, `**/aft-providers.tf`, `**/.terraform.lock*` files and `**/.terraform` directory. This ensures that these local contents are not be pushed back to git repository.
* Access to AWS AFT Management account with permissions to read AWS SSM Parameters and assume the `AWSAFTAdmin` IAM role.

## Getting started

1. Download the `aft-local.sh`.
2. Give the file permission to run.
3. Move the file to your local PATH (e.g. `/usr/local/bin`.).

```shell
curl https://github.com/awslabs/aft-blueprints/blob/main/assets/aft-local/aft-local.sh -o aft-local.sh
chmod +x aft-local.sh
mv aft-local.sh /usr/local/bin/aft-local.sh
```

## How to use

First, sign in to the AFT Management account using AWS CLI. You can either user `aws configure sso` command and define the AFT Management account as your default profile, or you can just copy the AWS access key credentials from your AWS Access Portal and paste them as environment variables. See [Setting up new configuration and credentials](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-quickstart.html#getting-started-quickstart-new) for more information.

Now let's say that you want to run a `terraform plan` for the `NETWORK` customization code on your AWS Network account (e.g. 123123123123). In this case, you would need to enter the `{{ aft-account-customizations path}}/NETWORK/terraform` directory to run the `aft-local.sh` script from there.

```shell
# Script usage: ./<script_name>.sh <ACCOUNT ID> <TERRAFORM COMMAND>"
cd ./aft-account-customizations/NETWORK/terraform
aft-local.sh 123123123123 init
aft-local.sh 123123123123 plan
```

The `init` command will initialize the terraform directory, and replace the `jinja` variables in the `backend.jina` and `aft-providers.jinja`, generating new Terraform files. This way, the `plan` command can run with the AFT backend configuration and the Network account parameter values.

For each execution of the script, it will retrieve the AFT parameters and assume the `AWSAFTAdmin` role in the AFT Management account. So that when it runs the Terraform code, he can assume the `AWSAFTExecution` role in the target accounts, defined by the AWS Terraform provider configuration.

**Note:** The arguments passed to this script are not validated or linted. They are simply passed directly to terraform.
