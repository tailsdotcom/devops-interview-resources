#!/bin/sh

# Branch hardcoded for testing
BRANCH="main"
COMMIT_ID=${CI_COMMIT_ID}

terraform init -reconfigure \
    -backend-config "bucket=example-tfstate" \
    -backend-config "key=$BRANCH"
terraform fmt
terraform validate
terraform plan \
    -var="branch=$BRANCH" \
    -var="commitid=$COMMIT_ID" \
    -var="GE_SNOWFLAKE_USERNAME=$GE_SNOWFLAKE_USERNAME" \
    -var="GE_SNOWFLAKE_PASSWORD=$GE_SNOWFLAKE_PASSWORD" \
    -var="GE_SNOWFLAKE_HOST=$GE_SNOWFLAKE_HOST" \
    -var="GE_SNOWFLAKE_DATABASE=$GE_SNOWFLAKE_DATABASE" \
    -var="GE_SNOWFLAKE_SCHEMA=$GE_SNOWFLAKE_SCHEMA" \
    -var="GITHUB_API_KEY=$GITHUB_API_KEY" \
    -var="EMARSYS_API_USERNAME=$EMARSYS_API_USERNAME" \
    -var="EMARSYS_API_SECRET=$EMARSYS_API_SECRET" \
    -var="AIRFLOW__CORE__SQL_ALCHEMY_CONN=$AIRFLOW__CORE__SQL_ALCHEMY_CONN" \
    -out ciplan

terraform apply \
    -input=false \
    -auto-approve \
    ciplan
