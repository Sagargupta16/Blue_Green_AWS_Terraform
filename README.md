# Blue-Green Deployment with AWS Terraform

A comprehensive Infrastructure as Code (IaC) solution for implementing Blue-Green deployment strategy on AWS using Terraform. This project provides a complete CI/CD pipeline with automated testing, containerized applications, and zero-downtime deployments.

## 🏗️ Architecture Overview

This project creates a robust AWS infrastructure that includes:

- **ECS Fargate** - Containerized application hosting
- **Application Load Balancer** - Traffic routing and health checks
- **Auto Scaling Groups** - Dynamic scaling based on demand
- **CodePipeline** - Automated CI/CD pipeline
- **CodeBuild** - Build and test automation
- **CodeDeploy** - Blue-Green deployment orchestration
- **ECR** - Docker image registry
- **VPC** - Isolated network environment
- **IAM** - Security and access management
- **KMS** - Encryption key management
- **S3** - Artifact storage

## 🚀 Features

- ✅ **Zero-downtime deployments** using Blue-Green strategy
- ✅ **Automated CI/CD pipeline** with AWS CodePipeline
- ✅ **Containerized applications** with Docker and ECS Fargate
- ✅ **Infrastructure as Code** with Terraform modules
- ✅ **Automated testing** integration
- ✅ **Security best practices** with IAM roles and KMS encryption
- ✅ **Scalable architecture** with Auto Scaling Groups
- ✅ **Monitoring and logging** capabilities
- ✅ **Multi-environment support** (dev/staging/production)

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate credentials
- [Docker](https://www.docker.com/get-started) for local testing
- [Node.js](https://nodejs.org/) >= 14.x (for the test application)
- [Yarn](https://yarnpkg.com/) package manager

## 🛠️ Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd Blue_Green_AWS_Terraform
   ```

2. **Configure AWS credentials**
   ```bash
   aws configure
   ```

3. **Initialize Terraform**
   ```bash
   cd terraform
   terraform init
   ```

4. **Review and customize variables**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your specific values
   ```

## 🚀 Usage

### Deploy Infrastructure

1. **Plan the deployment**
   ```bash
   terraform plan
   ```

2. **Apply the infrastructure**
   ```bash
   terraform apply
   ```

3. **Verify deployment**
   ```bash
   terraform output
   ```

### Deploy Application

The application deployment is automated through CodePipeline. Simply push code to the main branch:

```bash
git add .
git commit -m "Deploy new version"
git push origin main
```

### Local Development

To run the test application locally:

```bash
cd Test_App
yarn install
yarn all-install
yarn start
```

The application will be available at `http://localhost:3000`

## 📁 Project Structure

```
├── terraform/                 # Terraform infrastructure modules
│   ├── main.tf               # Main configuration
│   ├── variables.tf          # Variable definitions
│   ├── outputs.tf            # Output values
│   ├── alb/                  # Application Load Balancer
│   ├── asg/                  # Auto Scaling Groups
│   ├── codebuild/            # CodeBuild configuration
│   ├── codecommit/           # CodeCommit repository
│   ├── codedeploy/           # CodeDeploy configuration
│   ├── codepipeline_dev/     # Dev pipeline
│   ├── codepipeline_main/    # Production pipeline
│   ├── ecr/                  # Elastic Container Registry
│   ├── ecs/                  # ECS Fargate service
│   ├── iam/                  # IAM roles and policies
│   ├── kms/                  # KMS encryption keys
│   ├── s3/                   # S3 buckets
│   ├── security-groups/      # Security group configurations
│   ├── taskdefinition/       # ECS task definitions
│   └── vpc/                  # VPC and networking
├── Test_App/                 # Sample application
│   ├── buildspec.yml         # CodeBuild specification
│   ├── Dockerfile            # Docker configuration
│   ├── index.js              # Backend server
│   ├── package.json          # Dependencies
│   ├── client/               # React frontend
│   └── tests/                # Test files
└── README.md                 # This file
```

## ⚙️ Configuration

### Key Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `us-west-2` |
| `project_name` | Project identifier | `intern-project` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `availability_zones` | AZs for deployment | `["us-west-2a", "us-west-2b"]` |

### Environment Configuration

Customize your deployment by modifying `terraform/variables.tf` or creating a `terraform.tfvars` file:

```hcl
aws_region = "us-east-1"
project_name = "my-project"
vpc_cidr = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b"]
```

## 🔄 Blue-Green Deployment Process

1. **Blue Environment** - Current production version running
2. **Green Environment** - New version deployed alongside blue
3. **Health Checks** - Automated testing of green environment
4. **Traffic Switch** - Gradual traffic routing to green environment
5. **Monitoring** - Continuous monitoring of new deployment
6. **Rollback** - Instant rollback capability if issues detected

## 🧪 Testing

Run the test suite:

```bash
cd Test_App
yarn test
```

## 🔍 Monitoring

The infrastructure includes:
- CloudWatch logs and metrics
- ALB health checks
- ECS service monitoring
- Auto Scaling metrics

## 🚨 Troubleshooting

### Common Issues

1. **Terraform state conflicts**
   ```bash
   terraform force-unlock <lock-id>
   ```

2. **AWS permissions issues**
   - Ensure your AWS credentials have sufficient permissions
   - Check IAM policies for required services

3. **Docker build failures**
   - Verify Dockerfile syntax
   - Check buildspec.yml configuration

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the ISC License - see the [LICENSE](LICENSE) file for details.

## 👥 Authors

- Sagar Gupta - Initial work

## 🙏 Acknowledgments

- AWS documentation and best practices
- Terraform community modules
- Blue-Green deployment patterns
