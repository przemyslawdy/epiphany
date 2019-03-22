import boto3
from cli.helpers.list_helpers import select_single
from cli.helpers.objdict_helpers import dict_to_objdict


class AWSAPIProxy:
    def __init__(self, cluster_model, config_docs):
        self.cluster_model = cluster_model
        self.config_docs = config_docs

    def __enter__(self):
        credentials = self.cluster_model.specification.cloud.credentials
        self.client = boto3.client('ec2', aws_access_key_id=credentials.key, aws_secret_access_key=credentials.secret)
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        print('close')

    def get_ips_of_autoscaling_group(self, feature_key, look_for_public = False):
        region = self.cluster_model.specification.cloud.region
        cluster_name = self.cluster_model.specification.name.lower()

        vpc_id = self.get_vpc_id()
        print(vpc_id)

        ec2 = boto3.resource('ec2', region)
        running_instances = ec2.instances.filter(
            Filters=[{
                'Name': 'instance-state-name',
                'Values': ['running']
            },
            {
                'Name': 'vpc-id',
                'Values': [vpc_id]
            },
                {
                    'Name': 'tag:'+feature_key,
                    'Values': ['']
                },
                {
                    'Name': 'tag:cluster_name',
                    'Values': [cluster_name]
                }]
        )

        result = list()
        for instance in running_instances:
            if look_for_public:
                result.append(instance.public_ip_address)
            else:
                result.append(instance.private_ip_address)

    def get_vpc_id(self):
        vpc_config = dict_to_objdict(select_single(self.config_docs, lambda x: x.kind == 'infrastructure/vpc'))
        region = self.cluster_model.specification.cloud.region
        ec2 = boto3.resource('ec2', region)
        filters = [{'Name': 'tag:Name', 'Values': [vpc_config.specification.name]}]
        vpcs = list(ec2.vpcs.filter(Filters=filters))

        if len(vpcs) == 1:
            return vpcs[0].id

        raise Exception("Expected 1 VPC matching tag Name: "+vpc_config.specification.name+" but received: "+str(len(vpcs)))

