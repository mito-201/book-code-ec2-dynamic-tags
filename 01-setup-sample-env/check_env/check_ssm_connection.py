# test_ssm.py
# 実行コマンド　python3 check_ssm_connection.py
import boto3
import os

# AWSプロファイルを指定してください
profile_name = 'default'
# リージョンを指定してください
region_name = 'us-west-2'
# inventory_ssm.ini から実際のインスタンスIDを一つ選んでください
instance_id_to_test = 'i-03f2d8ef2d8f6fcf8' # 例: app のインスタンスID

print(f"Attempting to use profile '{profile_name}' in region '{region_name}'...")

try:
    session = boto3.Session(profile_name=profile_name, region_name=region_name)
    ssm_client = session.client('ssm')

    print(f"Describing instance information for: {instance_id_to_test}")
    response = ssm_client.describe_instance_information(
        InstanceInformationFilterList=[
            {
                'key': 'InstanceIds',
                'valueSet': [instance_id_to_test]
            }
        ]
    )

    if response.get('InstanceInformationList'):
        print("Successfully described instance via SSM:")
        print(response['InstanceInformationList'][0])
    else:
        print(f"Could not find info for instance {instance_id_to_test} via SSM, but no Python error from client.")

except Exception as e:
    print(f"Error using Boto3 with SSM: {e}")
    import traceback
    traceback.print_exc()