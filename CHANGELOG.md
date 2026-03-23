# Changelog

## [1.1.0] - 2026-02-28

- Configure Renovate for monthly grouped dependency updates
- Update React to v19, test libraries, and CI dependencies

## [1.0.0] - 2025-07-26

- Initial blue-green deployment pipeline on AWS
- Terraform modules: VPC (2 AZ), ECS, ALB, CodePipeline, CodeBuild, CodeDeploy
- Canary deployment (30% for 1 min, then full cutover)
- Multi-environment pipeline: Dev, Test, Manual approval, Prod
- Express + React test app with Docker multi-stage build
- Jest + Supertest with 80% coverage gate
