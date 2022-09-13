import hashlib

import boto3

lambda_client = boto3.client("lambda")
codedeploy_client = boto3.client("codedeploy")

waiter = codedeploy_client.get_waiter("deployment_successful")


def deploy():
    response = lambda_client.list_versions_by_function(
        FunctionName="${function_name}"
    )
    previous_version = [r['Version'] for r in response['Versions']][-2]

    if previous_version != "${target_lambda_version}" and previous_version != "$LATEST":
        app_spec = {
            "version": 0.0,
            "Resources": [
                {
                    "myLambdaFunction": {
                        "Type": "AWS::Lambda::Function",
                        "Properties": {
                            "Name": "${function_name}",
                            "Alias": "${alias_name}",
                            "CurrentVersion": previous_version,
                            "TargetVersion": "${target_lambda_version}",
                        },
                    }
                }
            ],
        }
        response = codedeploy_client.create_deployment(
            applicationName="${app_name}",
            deploymentGroupName="${deployment_group_name}",
            revision={
                "revisionType": "AppSpecContent",
                "appSpecContent": {
                    "content": str(app_spec),
                    "sha256": hashlib.sha256(
                        str(app_spec).encode("utf-8")
                    ).hexdigest(),
                }
            },
            deploymentConfigName="${deployment_config_name}",
            description=f"Deployment from {previous_version} to {'${target_lambda_version}'}",
        )

        waiter.wait(deploymentId=response["deploymentId"])


deploy()
