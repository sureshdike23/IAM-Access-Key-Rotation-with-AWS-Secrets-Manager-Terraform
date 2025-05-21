import boto3
import json

def lambda_handler(event, context):
    secret_arn = event['SecretId']
    step = event['Step']

    secretsmanager = boto3.client('secretsmanager')
    iam = boto3.client('iam')

    username = secret_arn.split("/")[-1].replace("-access-key", "")

    if step == "createSecret":
        new_key = iam.create_access_key(UserName=username)['AccessKey']

        secretsmanager.put_secret_value(
            SecretId=secret_arn,
            ClientRequestToken=event['ClientRequestToken'],
            SecretString=json.dumps({
                "AccessKeyId": new_key["AccessKeyId"],
                "SecretAccessKey": new_key["SecretAccessKey"]
            }),
            VersionStages=["AWSPENDING"]
        )

    elif step == "finishSecret":
        secretsmanager.update_secret_version_stage(
            SecretId=secret_arn,
            VersionStage="AWSCURRENT",
            MoveToVersionId=event['ClientRequestToken'],
            RemoveFromVersionId=event['PreviousVersionId']
        )

    return {"status": "Rotation complete"}
