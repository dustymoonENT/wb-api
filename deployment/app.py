#!/usr/bin/env python3

from aws_cdk import core

from main import MotivusWbApiStack

app = core.App()
env = core.Environment(account='522891085541', region='us-east-1')
MotivusWbApiStack(app, 'motivus-wb-api', env=env)

app.synth()
