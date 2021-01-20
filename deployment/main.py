import os
from aws_cdk import (
    core,
    aws_ec2,
    aws_ecs,
    aws_ecs_patterns,
    aws_ecr,
    aws_rds,
    aws_secretsmanager
)
from aws_cdk.core import Duration


class MotivusWbApiStack(core.Stack):
    def __init__(self, scope: core.Construct, stack_id: str, **kwargs) -> None:
        super().__init__(scope, stack_id, **kwargs)
        title = 'motivus-wb-api'

        repository = aws_ecr.Repository(self, f'{title}-repository', removal_policy=core.RemovalPolicy.DESTROY,
                                        repository_name=title)

        vpc = aws_ec2.Vpc(self, f'{title}-vpc', max_azs=3)

        db_password = aws_secretsmanager.Secret(self,
                                                f'{title}-db-password',
                                                generate_secret_string=aws_secretsmanager.SecretStringGenerator(
                                                    password_length=20))

        secret_key = aws_secretsmanager.Secret(self,
                                               f'{title}-phx-app-secret-key',
                                               generate_secret_string=aws_secretsmanager.SecretStringGenerator(
                                                   password_length=65))

        creds = aws_rds.Credentials.from_password("motivus_admin", db_password.secret_value)

        security_group = aws_ec2.SecurityGroup(self, f'{title}-security-group', vpc=vpc)

        security_group.add_ingress_rule(aws_ec2.Peer.ipv4('0.0.0.0/0'), aws_ec2.Port.tcp(5432))

        database_name = "motivus_wb_api"
        db = aws_rds.DatabaseInstance(self, f'{title}-db',
                                      engine=aws_rds.DatabaseInstanceEngine.POSTGRES,
                                      preferred_backup_window="05:00-06:00",
                                      backup_retention=Duration.days(7),
                                      removal_policy=core.RemovalPolicy.RETAIN,
                                      deletion_protection=True,
                                      database_name=database_name,
                                      credentials=creds,
                                      instance_type=aws_ec2.InstanceType.of(aws_ec2.InstanceClass.BURSTABLE2,
                                                                            aws_ec2.InstanceSize.MICRO),
                                      storage_type=aws_rds.StorageType.GP2,
                                      security_groups=[security_group],
                                      instance_identifier=title,
                                      vpc=vpc)

        cluster = aws_ecs.Cluster(self, f'{title}-cluster', vpc=vpc, cluster_name=f'{title}-cluster')

        registry = aws_ecs.EcrImage(repository=repository, tag='latest')

        aws_ecs_patterns.ApplicationLoadBalancedFargateService(
            self,
            f'{title}-fargate-service',
            cluster=cluster,  # Required
            desired_count=1,  # Default is 1
            service_name=f'{title}-service',
            task_image_options=aws_ecs_patterns.ApplicationLoadBalancedTaskImageOptions(
                image=registry,
                secrets={
                    'DB_PASSWORD': aws_ecs.Secret.from_secrets_manager(db_password),
                    'SECRET_KEY_BASE': aws_ecs.Secret.from_secrets_manager(secret_key)
                },
                environment={
                    'MIX_ENV': 'prod',
                    'DB_USER': 'motivus_admin',
                    'DB_NAME': database_name,
                    'DB_HOST': db.db_instance_endpoint_address
                }),
            memory_limit_mib=2048,
            health_check_grace_period=core.Duration.minutes(15),
            public_load_balancer=True,  # Default is False
        )
