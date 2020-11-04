# terraform-aws-mcaf-eks

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13.0 |

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the cluster | `string` | n/a | yes |
| tags | A mapping of tags to assign to the cluster | `map(string)` | n/a | yes |
| create\_node\_group | Whether or not to create a node group | `bool` | `true` | no |
| instance\_types | List of EC2 instance types to use for the worker nodes | `list(string)` | `null` | no |
| log\_retention | Retention of CloudWatch logs for the EKS cluster | `number` | `7` | no |
| scaling\_config | The config that is used for the node group scaling | <pre>object({<br>    desired_size = number<br>    max_size     = number<br>    min_size     = number<br>  })</pre> | <pre>{<br>  "desired_size": 3,<br>  "max_size": 3,<br>  "min_size": 3<br>}</pre> | no |
| subnet\_ids | List of subnet IDs to deploy EKS in | `list(string)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | The Amazon Resource Name (ARN) of the cluster |
| name | The EKS cluster name |

<!--- END_TF_DOCS --->
