# IAM for AWS external-dns

**This Terraform module generates the IAM permissions required by external-dns (public and private) on AWS.**

> [!NOTE]
> This module is part of [SIGHUP Distribution (SD)](https://github.com/sighupio/distribution) and is consumed automatically by `furyctl` when you create a cluster. You don't need to use it directly: its inputs are derived from your `furyctl.yaml`. The reference below is intended for maintainers and contributors.

> ⚠️ **Warning**: this module uses ["IAM Roles for ServiceAccount"](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to inject AWS credentials inside external-dns pods.

## Requirements

| Name      | Version   |
| --------- | --------- |
| terraform | ~> 1.3    |
| aws       | >= 3.76.0 |

## Providers

| Name | Version   |
| ---- | --------- |
| aws  | >= 3.76.0 |

## Modules

| Name                                         | Source                                                              | Version |
| -------------------------------------------- | ------------------------------------------------------------------- | ------- |
| external\_dns\_private\_iam\_assumable\_role | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |
| external\_dns\_public\_iam\_assumable\_role  | terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc | v3.16.0 |

## Resources

| Name                                                                                                                          | Type        |
| ----------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_iam_policy.external_dns_private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource    |
| [aws_iam_policy.external_dns_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy)  | resource    |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster)            | data source |

## Inputs

| Name              | Description                                          | Type          | Default | Required |
| ----------------- | ---------------------------------------------------- | ------------- | ------- | :------: |
| cluster\_name     | EKS cluster name                                     | `string`      | n/a     |   yes    |
| private\_zone\_id | Route53 private zone ID                              | `string`      | `""`    |    no    |
| enable\_private   | Flag to enable the creation for the private IAM role | `bool`        | `false` |    no    |
| public\_zone\_id  | Route53 public zone ID                               | `string`      | n/a     |   yes    |
| tags              | Additional tags for the created resources            | `map(string)` | `{}`    |    no    |

## Outputs

| Name                                   | Description                                       |
| -------------------------------------- | ------------------------------------------------- |
| external\_dns\_private\_iam\_role\_arn | external-dns-private IAM role                     |
| external\_dns\_private\_patches        | external-dns-private Kubernetes resources patches |
| external\_dns\_public\_iam\_role\_arn  | external-dns-public IAM role                      |
| external\_dns\_public\_patches         | external-dns-public Kubernetes resources patches  |
