#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { Issue5498Stack } from '../lib/issue_5498-stack';

const app = new cdk.App();
new Issue5498Stack(app, 'Issue5498Stack');
