# Cfn SES Action

A Github Action which wraps the Cloudformation Resource [cfn-ses-provider](https://github.com/binxio/cfn-ses-provider) created by [binx.io](https://www.binx.io) who did all the hard work. If you don't want to use this as a Github Action then I suggest going to [cfn-ses-provider](https://github.com/binxio/cfn-ses-provider).

## Inputs

### `aws-access-key-id`

**Required** The aws access key to give access to create the resource.

### `aws-secret-access-key`

**Required** The aws secret access key to give access to create the resource.

### `aws-default-region`

**Required** The region where this should be deployed.

## Outputs

### `service-token`

The service token for the custom resource.

## Example usage

```yaml

    - uses: danieljarrett74/cfn-ses-action@main
      with:
        aws-access-key-id: XXXXXXXXXXXXXXXXXXXX
        aws-secret-access-key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
        aws-default-region: us-east-1
```


The documentation below was copied from [cfn-ses-provider](https://github.com/binxio/cfn-ses-provider)


A  CloudFormation custom provider for managing SES Domain Identities, Identity Notifications, DKIM tokens and the active receipt rule set.

Read the blog on [How to configure SES domain identities and DKIM records using cloudformation](https://binx.io/blog/2019/11/14/how-to-deploy-aws-ses-domain-identities-dkim-records-using-cloudformation/)


## How do I add SES Domain Identity in CloudFormation?
It is quite easy: you specify a CloudFormation resource of type [Custom::DomainIdentity](docs/DomainIdentity.md):

```yaml
Resources:
  DomainIdentity:
    Type: Custom::DomainIdentity
    Properties:
      Domain: !Ref 'ExternalDomainName'
      Region: !Ref 'EmailRegion'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```
This will create a domain identity in the region, and return the DNS entry as attributes, so you can proof you own the domain by adding a Route53 record:

```yaml
  DomainVerificationRecord:
    Type: AWS::Route53::RecordSetGroup
    Properties:
        Comment: !Sub 'SES identity for ${ExternalDomainName}'
        HostedZoneId: !Ref 'HostedZone'
        RecordSets: !GetAtt 'DomainIdentity.RecordSets'
```

To wait until the domain identity is verified, add a [Custom::VerifiedIdentity](docs/VerifiedIdentity.md):
```yaml
  VerifiedDomainIdentity:
    Type: Custom::VerifiedIdentity
    Properties:
      Identity: !GetAtt 'DomainIdentity.Domain'
      Region: !GetAtt 'DomainIdentity.Region'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

If you wish to add a MAIL FROM domain, add a [Custom::MailFromDomain](docs/MailFromDomain.md):
```yaml
Resources:
  MailFromDomain:
    Type: Custom::MailFromDomain
    Properties:
      Domain: !Ref 'ExternalDomainName'
      Region: !Ref 'EmailRegion'
      MailFromSubdomain: 'mail'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

You can verify the MAIL FROM domain in Route53 like this:
```yaml
  MailFromDomainVerificationRecords:
    Type: AWS::Route53::RecordSetGroup
    Properties:
        Comment: !Sub 'SES MAIL FROM domain for ${ExternalDomainName}'
        HostedZoneId: !Ref 'HostedZone'
        RecordSets: !GetAtt 'MailFromDomain.RecordSets'
```

To wait until the MAIL FROM domain is verified, add a [Custom::VerifiedMailFromDomain](docs/VerifiedMailFromDomain.md):
```yaml
  VerifiedMailFromDomain:
    Type: Custom::VerifiedMailFromDomain
    Properties:
      Identity: !GetAtt 'DomainIdentity.Domain'
      Region: !GetAtt 'DomainIdentity.Region'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

If you wish to configure the notifications, add a [Custom::IdentityNotifications](docs/IdentityNotifications.md):
```yaml
  DomainNotifications:
    Type: Custom::IdentityNotifications
    Properties:
      Identity: !GetAtt 'DomainIdentity.Domain'
      Region: !GetAtt 'DomainIdentity.Region'
      BounceTopic: !Ref BounceTopic
      ComplaintTopic: !Ref ComplaintTopic
      HeadersInBounceNotificationsEnabled: true
      HeadersInComplaintNotificationsEnabled: true
      ForwardingEnabled: false
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

If you wish to activate a SES Receipt Rule set, add a [Custom::ActiveReceiptRuleSet](docs/ActiveReceiptRuleSet.md):

```yaml
  Type: Custom::ActiveReceiptRuleSet
  Properties:
    Region: !Ref 'AWS::Region'
    RuleSetName: !Ref ReceiptRuleSet
    ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

If you wish to authorize other AWS accounts, IAM users, and AWS services to send for this identity, add an identity policy:
```yaml
  IdentityPolicy:
    Type: Custom::IdentityPolicy
    Properties:
      Identity: !GetAtt 'DomainIdentity.Domain'
      PolicyName: CrossAccountAllow
      PolicyDocument:
        Version: '2012-10-17'
        Statement:
          - Effect: Allow
            Principal:
              AWS:
                - 'arn:aws:iam::000111222333:root'
            Action:
              - ses:SendEmail
              - ses:SendRawEmail
            Resource: !Sub 'arn:aws:ses:${AWS::Region}:${AWS::AccountId}:identity/${DomainIdentity.Domain}'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```

## How do I get DKIM tokens in CloudFormation?
It is quite easy: you specify a CloudFormation resource of type [Custom::DkimTokens](docs/DkimTokens.md):

```yaml
Resources:
  DkimTokens:
    Type: Custom::DkimTokens
    Properties:
      Domain: !GetAtt 'DomainIdentity.Domain'
      Region: !GetAtt 'DomainIdentity.Region'
      ServiceToken: !Sub 'arn:aws:lambda:${AWS::Region}:${AWS::AccountId}:function:binxio-cfn-ses-provider'
```
This will return the DKIM tokens and the DNS entries as attributes, so that
receiver can validate that the messages were sent by the owner of the domain.
You can use these values to create the required DKIM DNS records, as follows:

```yaml
  DkimRecords:
    Type: AWS::Route53::RecordSetGroup
    Properties:
      HostedZoneId: !Ref 'HostedZone'
      RecordSets: !GetAtt 'DkimTokens.RecordSets'
```
