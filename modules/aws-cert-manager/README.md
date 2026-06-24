# IAM for AWS cert-manager

**This Terraform module generates the IAM permissions required by cert-manager on AWS.**

> **Note**: This module is part of [SIGHUP Distribution (SD)](https://github.com/sighupio/distribution) and is consumed automatically by `furyctl` when you create a cluster. You don't need to use it directly: its inputs are derived from your `furyctl.yaml`. The reference below is intended for maintainers and contributors.

> [!WARNING]
> This module uses ["IAM Roles for ServiceAccount"](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to inject AWS credentials inside cert-manager pods

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | >= 0.15.4 |
| aws       | >= 3.37.0 |

## Providers

| Name | Version   |
| ---- | --------- |
| aws  | >= 3.37.0 |

## Modules

| Name                                | Source                                                              | Version |
| ----------------------------------- | ------------------------------------------------------------------- | ------- |
| cert\_manager\_iam\_assumable\_role | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |

## Resources

| Name                                                                                                                  | Type        |
| --------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.cert_manager](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource    |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)    | data source |

## Inputs

| Name             | Description                               | Type          | Default | Required |
| ---------------- | ----------------------------------------- | ------------- | ------- | :------: |
| cluster\_name    | EKS cluster name                          | `string`      | n/a     |   yes    |
| public\_zone\_id | Route53 public zone ID                    | `string`      | n/a     |   yes    |
| tags             | Additional tags for the created resources | `map(string)` | `{}`    |    no    |

## Outputs

| Name                          | Description                               |
| ----------------------------- | ----------------------------------------- |
| cert\_manager\_iam\_role\_arn | cert-manager IAM role                     |
| cert\_manager\_patches        | cert-manager Kubernetes resources patches |
