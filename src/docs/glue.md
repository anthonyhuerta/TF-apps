- ### Glue Inputs
    - [Glue Connection input](#glue-connection-input)
      - [database](#database)
    - [Glue Crawler input](#glue-crawler-input)
    - [Glue Job input](#glue-job-input)
    - [Glue triggers input](#glue-triggers-input)

To create a glue job the available input variables are listed below. An example file for glue can be found [here](https://github.com/OtoAnalytics/tf-womply-apps/blob/99bd7369294236fb650a0a5c6d6cb2d240095586/src/examples/glue/customer-import-service.yaml).
#### Glue-connections-input
| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of database | `string` | `null` | yes |
| engine | Name of db engine | `string` | `null` | yes |
| host | Name of database host | `string` | `null` | yes |
| port | DB port | `string` | `null` | yes |
| user | Name of user which has access to the DB. **_Note_**: Please don't override this variable as we've stored the password for datalake<env> user only, in ASM | `string` | `datalakebeta` | no |
| availability_zone | Name of az where your job should be created | `string` | `us-west-2` | no |

#### glue-crawlers-input
| Name | Description | Type | Default | Required | Supported_values |
|------|-------------|------|---------|:--------:|:--------------:|
| name | Name of the crawler | `string` | `datalake-<service_name>` | `no` | |
| include_path | This is to tell the crawler which **db_name/** or **db_name/schema_name/** should be used by crawler | `string` | `db_name` | no |  |
| exclude_paths | List of schema to be excluded from crawler | `list(string)` | `[]` | no | |
| trigger | This is to add the trigger for crawler | `string` | `null` | no | `'cron(* * * * ? *)'` |
| table_prefix | The table prefix used for catalog tables that are created | `string` | `null` | no | `string`_ |
| crawler_lineage_settings | Specifies whether data lineage is enabled for the crawler | `string` | `DISABLE` | no | `ENABLE` and `DISABLE` |
| recrawl_behavior | Specifies whether to crawl the entire dataset again or to crawl only folders that were added since the last crawler run | `string` | `CRAWL_EVERYTHING` | no | `CRAWL_EVERYTHING` and `CRAWL_NEW_FOLDERS_ONLY` |
#### glue-jobs-input
| Name | Description | Type | Default | Required | Supported_values|
|------|-------------|------|---------|:--------:|:--------------:|
| name | Name of the glue job | `string` | `<service_name>` | `no` | |
| [glue_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job#glue_version) | Glue version | `string` | `2.0` | no | `1.0` and `2.0` |
| shell_type | Glue shell type | `string` | `spark/glueetl` | no | `pythonshell` and `glueetl` |
| [max_capacity](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job#max_capacity) | Required for glue `pythonshell` | `string` | `null` | only with `shell_type=pythonshell` | `1` and `0.0625` |
| script_location | S3 path for python script | `string` | `s3://womply-datalake-scripts/${var.env}/<service_name>.py` | |
| [python_version](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job#python_version) | Python version to be used for glue job | `string` | `3` | no | `2` and `3` |
| timeout | The job timeout in minutes | `string` | `2880 minutes (48 hours)` | no | |
| max_retries | The maximum number of times to retry this job if it fails | `string` | N/A | no | value between 1 to 10 |
| number_of_workers | Number of works required by glue job | `string` | null | only when `shell_type!=pythonshell` and `glue_verison>=2.0` |  |
| worker_type | Worker type required by glue job | `string` | `null` | only when `shell_type!=pythonshell` and `glue_verison>=2.0` |  |
| [default_arguments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_job#default_arguments) | Default job parameters for the job | `map(string)` | `{}` | yes | [default_arguments](https://docs.aws.amazon.com/glue/latest/dg/aws-glue-programming-etl-glue-arguments.html)

#### glue-triggers-input
| Name | Description | Type | Default | Required | Supported_values |
|------|-------------|------|---------|:--------:|:--------------:|
| type | Type of job trigger | `string` | `ON_DEMAND` | yes | [Supported trigger types](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger#type) |
| schedule | Cron schedule to trigger the related job | `string` | null | no | `'cron(* * * * ? *)'` |
| [actions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger#actions) | Jobs/Crawler to trigger | `list(string)` |  | yes | job_name, crawler_name |
| [predicate](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/glue_trigger#predicate) | Condition to trigger the job/crawler | `list(object(list(object)))` |  | no | `{"predicate": [{"conditions": [{"job_name": "customer-import-service","state": "SUCCEEDED"}]},"logical": "ANY"]}` |
