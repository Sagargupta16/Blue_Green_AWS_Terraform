# Foundation

module "s3" {
  source      = "./s3"
  name        = var.project_name
  kms_key_arn = module.kms.kms_key_arn
}

module "vpc" {
  source             = "./vpc"
  name               = var.project_name
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
  kms_key_arn        = module.kms.kms_key_arn
  flow_log_role_arn  = module.iam.vpc_flow_logs_role_arn
}

module "kms" {
  source = "./kms"
  name   = var.project_name
}

module "ecr" {
  source        = "./ecr"
  name          = var.project_name
  kms_key_alias = module.kms.kms_key_alias
}

module "iam" {
  source                  = "./iam"
  name                    = var.project_name
  region                  = var.aws_region
  account_id              = data.aws_caller_identity.current.account_id
  s3_bucket_arn           = module.s3.s3_bucket_arn
  kms_key_arn             = module.kms.kms_key_arn
  codebuild_project_names = ["dev-${var.project_name}", "main-${var.project_name}"]
  github_connection_arn   = var.github_connection_arn
  deployment_engine       = var.deployment_engine

  depends_on = [module.s3, module.ecr]
}


# Task definitions

module "task_definition_dev" {
  source                       = "./task_definition"
  name                         = "dev-${var.project_name}"
  aws_region                   = var.aws_region
  task_definition_image        = "${module.ecr.ecr_repository_url}:dev-latest"
  task_definition_cpu          = var.task_definition_cpu
  task_definition_memory       = var.task_definition_memory
  task_definition_network_mode = var.task_definition_network_mode
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn            = module.iam.ecs_task_role_arn
  container_port               = var.container_port
}

module "task_definition_main" {
  source                       = "./task_definition"
  name                         = "main-${var.project_name}"
  aws_region                   = var.aws_region
  task_definition_image        = "${module.ecr.ecr_repository_url}:main-latest"
  task_definition_cpu          = var.task_definition_cpu
  task_definition_memory       = var.task_definition_memory
  task_definition_network_mode = var.task_definition_network_mode
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn            = module.iam.ecs_task_role_arn
  container_port               = var.container_port
}


# CodeBuild

module "codebuild_dev" {
  source              = "./codebuild"
  aws_region          = var.aws_region
  name                = "dev-${var.project_name}"
  build_env           = "dev"
  codebuild_role_arn  = module.iam.codebuild_role_arn
  ecr_repository_url  = module.ecr.ecr_repository_url
  task_definition_arn = module.task_definition_dev.task_definition_arn
  container_name      = module.task_definition_dev.container_name
  container_port      = var.container_port
  aws_kms_alias       = module.kms.kms_key_alias
}

module "codebuild_main" {
  source              = "./codebuild"
  aws_region          = var.aws_region
  name                = "main-${var.project_name}"
  build_env           = "main"
  codebuild_role_arn  = module.iam.codebuild_role_arn
  ecr_repository_url  = module.ecr.ecr_repository_url
  task_definition_arn = module.task_definition_main.task_definition_arn
  container_name      = module.task_definition_main.container_name
  container_port      = var.container_port
  aws_kms_alias       = module.kms.kms_key_alias
}


# Environments (one per env). The module name is historical: it always
# builds the ECS stack and adds CodeDeploy only for deployment_engine = codedeploy.

module "codedeploy_dev" {
  source                 = "./codedeploy"
  name                   = "dev-${var.project_name}"
  vpc_id                 = module.vpc.vpc_id
  task_definition_arn    = module.task_definition_dev.task_definition_arn
  app_task_role_arn      = module.iam.codedeploy_role_arn
  public_subnets         = module.vpc.public_subnet_ids
  asg_ec2_ami_name       = var.asg_ec2_ami_name
  asg_ec2_instance_type  = var.asg_ec2_instance_type
  asg_desired_capacity   = var.asg_desired_capacity
  asg_max_size           = var.asg_max_size
  asg_min_size           = var.asg_min_size
  container_name         = module.task_definition_dev.container_name
  container_port         = var.container_port
  private_subnets        = module.vpc.private_subnet_ids
  desired_count          = var.desired_count
  ecs_instance_role_name = module.iam.ecs_instance_role_name
  s3_bucket_name         = module.s3.s3_bucket_name
  kms_key_arn            = module.kms.kms_key_arn
  alarm_email            = var.alarm_email

  deployment_engine           = var.deployment_engine
  ecs_deployment_strategy     = var.ecs_deployment_strategy
  canary_percent              = var.canary_percent
  canary_interval_minutes     = var.canary_interval_minutes
  bake_time_minutes           = var.bake_time_minutes
  ecs_infrastructure_role_arn = module.iam.ecs_infrastructure_role_arn
}

module "codedeploy_test" {
  source                 = "./codedeploy"
  name                   = "test-${var.project_name}"
  vpc_id                 = module.vpc.vpc_id
  task_definition_arn    = module.task_definition_main.task_definition_arn
  app_task_role_arn      = module.iam.codedeploy_role_arn
  public_subnets         = module.vpc.public_subnet_ids
  asg_ec2_ami_name       = var.asg_ec2_ami_name
  asg_ec2_instance_type  = var.asg_ec2_instance_type
  asg_desired_capacity   = var.asg_desired_capacity
  asg_max_size           = var.asg_max_size
  asg_min_size           = var.asg_min_size
  container_name         = module.task_definition_main.container_name
  container_port         = var.container_port
  private_subnets        = module.vpc.private_subnet_ids
  desired_count          = var.desired_count
  ecs_instance_role_name = module.iam.ecs_instance_role_name
  s3_bucket_name         = module.s3.s3_bucket_name
  kms_key_arn            = module.kms.kms_key_arn
  alarm_email            = var.alarm_email

  deployment_engine           = var.deployment_engine
  ecs_deployment_strategy     = var.ecs_deployment_strategy
  canary_percent              = var.canary_percent
  canary_interval_minutes     = var.canary_interval_minutes
  bake_time_minutes           = var.bake_time_minutes
  ecs_infrastructure_role_arn = module.iam.ecs_infrastructure_role_arn
}

module "codedeploy_prod" {
  source                 = "./codedeploy"
  name                   = "prod-${var.project_name}"
  vpc_id                 = module.vpc.vpc_id
  task_definition_arn    = module.task_definition_main.task_definition_arn
  app_task_role_arn      = module.iam.codedeploy_role_arn
  public_subnets         = module.vpc.public_subnet_ids
  asg_ec2_ami_name       = var.asg_ec2_ami_name
  asg_ec2_instance_type  = var.asg_ec2_instance_type
  asg_desired_capacity   = var.asg_desired_capacity
  asg_max_size           = var.asg_max_size
  asg_min_size           = var.asg_min_size
  container_name         = module.task_definition_main.container_name
  container_port         = var.container_port
  private_subnets        = module.vpc.private_subnet_ids
  desired_count          = var.desired_count
  ecs_instance_role_name = module.iam.ecs_instance_role_name
  s3_bucket_name         = module.s3.s3_bucket_name
  kms_key_arn            = module.kms.kms_key_arn
  alarm_email            = var.alarm_email

  deployment_engine           = var.deployment_engine
  ecs_deployment_strategy     = var.ecs_deployment_strategy
  canary_percent              = var.canary_percent
  canary_interval_minutes     = var.canary_interval_minutes
  bake_time_minutes           = var.bake_time_minutes
  ecs_infrastructure_role_arn = module.iam.ecs_infrastructure_role_arn
}


# CodePipelines

module "codepipeline_dev" {
  source                     = "./codepipeline_dev"
  name                       = "dev-${var.project_name}"
  pipeline_role_arn          = module.iam.codepipeline_role_arn
  artifact_bucket            = module.s3.s3_bucket_name
  github_connection_arn      = var.github_connection_arn
  github_owner               = var.github_owner
  github_repo                = var.github_repo
  dev_branch_name            = var.dev_branch_name
  dev_codebuild_project_name = module.codebuild_dev.codebuild_project_name
  dev_codedeploy_app_name    = module.codedeploy_dev.codedeploy_app_name
  dev_deployment_group_name  = module.codedeploy_dev.codedeploy_deployment_group_name
  kms_key_alias              = module.kms.kms_key_alias
  deployment_engine          = var.deployment_engine
  dev_ecs_cluster_name       = module.codedeploy_dev.ecs_cluster_name
  dev_ecs_service_name       = module.codedeploy_dev.ecs_service_name
}

module "codepipeline_main" {
  source                      = "./codepipeline_main"
  name                        = "main-${var.project_name}"
  pipeline_role_arn           = module.iam.codepipeline_role_arn
  artifact_bucket             = module.s3.s3_bucket_name
  github_connection_arn       = var.github_connection_arn
  github_owner                = var.github_owner
  github_repo                 = var.github_repo
  main_branch_name            = var.main_branch_name
  test_codebuild_project_name = module.codebuild_main.codebuild_project_name
  test_codedeploy_app_name    = module.codedeploy_test.codedeploy_app_name
  test_deployment_group_name  = module.codedeploy_test.codedeploy_deployment_group_name
  prod_codedeploy_app_name    = module.codedeploy_prod.codedeploy_app_name
  prod_deployment_group_name  = module.codedeploy_prod.codedeploy_deployment_group_name
  kms_key_alias               = module.kms.kms_key_alias
  deployment_engine           = var.deployment_engine
  test_ecs_cluster_name       = module.codedeploy_test.ecs_cluster_name
  test_ecs_service_name       = module.codedeploy_test.ecs_service_name
  prod_ecs_cluster_name       = module.codedeploy_prod.ecs_cluster_name
  prod_ecs_service_name       = module.codedeploy_prod.ecs_service_name
}
