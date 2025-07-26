provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "codecommit" {
  source = "./codecommit"
  name   = var.project_name
}

module "s3" {
  source = "./s3"
  name   = var.project_name
}

module "vpc" {
  source             = "./vpc"
  availability_zones = var.availability_zones
  vpc_cidr           = var.vpc_cidr
}

module "kms" {
  source = "./kms"
  name   = var.project_name
}

module "ecr" {
  source        = "./ecr"
  name          = var.project_name
  kms_key_alias = module.kms.kms_key_alias

  depends_on = [module.kms]
}

module "iam" {
  source     = "./iam"
  name       = var.project_name
  region     = var.aws_region
  account_id = data.aws_caller_identity.current.account_id

  s3_bucket_arn           = module.s3.s3_bucket_arn
  kms_key_arn             = module.kms.kms_key_arn
  codecommit_repo_arn     = module.codecommit.aws_codecommit_repository_arn
  codebuild_project_names = ["dev-${var.project_name}", "main-${var.project_name}"]

  depends_on = [module.s3, module.ecr, module.codecommit]
}

# Dev Task Definition
module "task_definition_dev" {
  source                       = "./taskdefination"
  name                         = "dev-${var.project_name}"
  aws_region                   = var.aws_region
  task_definition_image        = "${module.ecr.ecr_repository_url}:dev-latest"
  task_definition_cpu          = var.task_definition_cpu
  task_definition_memory       = var.task_definition_memory
  task_definition_network_mode = var.task_definition_network_mode
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn            = module.iam.ecs_task_role_arn
  container_port               = var.container_port

  depends_on = [module.iam]
}

# Main Task Definition
module "task_definition_main" {
  source                       = "./taskdefination"
  name                         = "main-${var.project_name}"
  aws_region                   = var.aws_region
  task_definition_image        = "${module.ecr.ecr_repository_url}:main-latest"
  task_definition_cpu          = var.task_definition_cpu
  task_definition_memory       = var.task_definition_memory
  task_definition_network_mode = var.task_definition_network_mode
  ecs_task_execution_role_arn  = module.iam.ecs_task_execution_role_arn
  ecs_task_role_arn            = module.iam.ecs_task_role_arn
  container_port               = var.container_port

  depends_on = [module.iam]
}

# Dev CodeBuild
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

  depends_on = [module.task_definition_dev]
}

# Test CodeBuild
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

  depends_on = [module.task_definition_main]
}

# Dev Deploy
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

  depends_on = [module.task_definition_dev, module.vpc]
}

# Test Deploy
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

  depends_on = [module.task_definition_main, module.vpc]
}

# Prod Deploy
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

  depends_on = [module.task_definition_main, module.vpc]
}

# Dev CodePipeline
module "codepipeline_dev" {
  source                     = "./codepipeline_dev"
  name                       = "dev-${var.project_name}"
  pipeline_role_arn          = module.iam.codepipeline_role_arn
  artifact_bucket            = module.s3.s3_bucket_name
  codecommit_repository_name = module.codecommit.aws_codecommit_repository_name
  dev_branch_name            = var.dev_branch_name
  dev_codebuild_project_name = module.codebuild_dev.codebuild_project_name
  dev_codedeploy_app_name    = module.codedeploy_dev.codedeploy_app_name
  dev_deployment_group_name  = module.codedeploy_dev.codedeploy_deployment_group_name
  kms_key_alias              = module.kms.kms_key_alias

  depends_on = [module.codedeploy_dev, module.codebuild_dev]
}

# Test & Prod CodePipeline
module "codepipeline_main" {
  source                      = "./codepipline_main"
  name                        = "main-${var.project_name}"
  pipeline_role_arn           = module.iam.codepipeline_role_arn
  artifact_bucket             = module.s3.s3_bucket_name
  codecommit_repository_name  = module.codecommit.aws_codecommit_repository_name
  main_branch_name            = var.main_branch_name
  test_codebuild_project_name = module.codebuild_main.codebuild_project_name
  test_codedeploy_app_name    = module.codedeploy_test.codedeploy_app_name
  test_deployment_group_name  = module.codedeploy_test.codedeploy_deployment_group_name
  prod_codedeploy_app_name    = module.codedeploy_prod.codedeploy_app_name
  prod_deployment_group_name  = module.codedeploy_prod.codedeploy_deployment_group_name
  kms_key_alias               = module.kms.kms_key_alias

  depends_on = [module.codedeploy_test, module.codedeploy_prod, module.codebuild_main]
}