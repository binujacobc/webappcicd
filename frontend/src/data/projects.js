export const projects = [
  {
    id: 'aws-frontend-cicd',
    title: 'AWS Frontend CI/CD Pipeline',
    category: 'DevOps',
    tags: ['AWS', 'Terraform', 'CodePipeline', 'CloudFront'],
    summary: 'Production-ready CI/CD pipeline for Vue.js apps using AWS CodePipeline, S3, and CloudFront with SSL.',
    description: `A fully automated CI/CD pipeline built with Terraform that deploys a Vue.js frontend to AWS.
    The infrastructure includes S3 for static hosting, CloudFront with OAC for CDN and SSL termination,
    ACM for certificate management, and Route 53 for DNS. CodePipeline watches for GitHub pushes and
    triggers CodeBuild to build and deploy automatically with CloudFront cache invalidation.`,
    highlights: [
      'Modular Terraform architecture with separate hosting and CI/CD stacks',
      'CloudFront with OAC, TLS 1.2+, HTTP/3, and security headers',
      'Automatic S3 deploy with smart caching (immutable assets, no-cache HTML)',
      'CodeStar GitHub integration with webhook-based triggers',
      'Least-privilege IAM roles for CodeBuild and CodePipeline',
    ],
    techStack: ['Vue 3', 'Vite', 'Terraform', 'AWS CodePipeline', 'AWS CodeBuild', 'S3', 'CloudFront', 'Route 53', 'ACM'],
    status: 'Live',
  },
  {
    id: 'kubernetes-microservices',
    title: 'Kubernetes Microservices Platform',
    category: 'Infrastructure',
    tags: ['Kubernetes', 'Docker', 'Helm', 'ArgoCD'],
    summary: 'Container orchestration platform running microservices with GitOps-based deployments.',
    description: `A production Kubernetes platform hosting multiple microservices with automated GitOps deployments.
    Uses Helm charts for packaging, ArgoCD for continuous delivery, and Prometheus/Grafana for observability.
    The cluster runs on EKS with managed node groups, cluster autoscaler, and pod disruption budgets
    for high availability.`,
    highlights: [
      'EKS cluster with managed node groups and cluster autoscaler',
      'GitOps workflow using ArgoCD with automatic sync',
      'Full observability stack: Prometheus, Grafana, Loki',
      'Ingress with AWS ALB controller and external-dns',
      'Network policies and pod security standards enforced',
    ],
    techStack: ['Kubernetes', 'EKS', 'Docker', 'Helm', 'ArgoCD', 'Prometheus', 'Grafana', 'Terraform'],
    status: 'In Progress',
  },
  {
    id: 'serverless-api',
    title: 'Serverless REST API',
    category: 'Backend',
    tags: ['Lambda', 'API Gateway', 'DynamoDB', 'Python'],
    summary: 'Scalable serverless API built with AWS Lambda, API Gateway, and DynamoDB.',
    description: `A high-performance serverless REST API that handles authentication, CRUD operations,
    and file uploads. Built with Python Lambda functions behind API Gateway with request validation.
    Uses DynamoDB for data persistence with single-table design patterns for efficient queries.
    Includes JWT authentication, rate limiting, and comprehensive CloudWatch monitoring.`,
    highlights: [
      'Single-table DynamoDB design for optimal query performance',
      'JWT-based authentication with Lambda authorizer',
      'API Gateway with request validation and throttling',
      'Infrastructure as Code with AWS SAM',
      'Automated testing with pytest and localstack',
    ],
    techStack: ['Python', 'AWS Lambda', 'API Gateway', 'DynamoDB', 'SAM', 'CloudWatch'],
    status: 'Completed',
  },
  {
    id: 'terraform-modules-library',
    title: 'Terraform Modules Library',
    category: 'DevOps',
    tags: ['Terraform', 'AWS', 'IaC', 'Modules'],
    summary: 'Reusable Terraform module library for common AWS infrastructure patterns.',
    description: `A collection of production-tested Terraform modules for rapidly provisioning AWS infrastructure.
    Includes modules for VPC networking, ECS clusters, RDS databases, S3 static hosting with CloudFront,
    and CI/CD pipelines. Each module follows AWS Well-Architected Framework principles with sensible
    defaults and comprehensive variable validation.`,
    highlights: [
      'Battle-tested modules used across multiple production environments',
      'Comprehensive variable validation and sensible defaults',
      'Follows AWS Well-Architected Framework principles',
      'Automated testing with Terratest',
      'Versioned releases with semantic versioning',
    ],
    techStack: ['Terraform', 'AWS', 'Go (Terratest)', 'GitHub Actions'],
    status: 'Ongoing',
  },
  {
    id: 'monitoring-dashboard',
    title: 'Real-time Monitoring Dashboard',
    category: 'Full Stack',
    tags: ['React', 'WebSocket', 'Grafana', 'Node.js'],
    summary: 'Live infrastructure monitoring dashboard with real-time metrics and alerting.',
    description: `A real-time monitoring dashboard that aggregates metrics from multiple cloud services
    and displays them in customizable widgets. Features WebSocket connections for live updates,
    threshold-based alerting with Slack/PagerDuty integration, and historical data analysis.
    Built with React frontend and Node.js backend connecting to Prometheus and CloudWatch.`,
    highlights: [
      'Real-time metrics via WebSocket with automatic reconnection',
      'Customizable dashboard layouts with drag-and-drop widgets',
      'Multi-source aggregation: Prometheus, CloudWatch, Datadog',
      'Alert rules with escalation policies and on-call rotation',
      'Historical trend analysis with anomaly detection',
    ],
    techStack: ['React', 'Node.js', 'WebSocket', 'Prometheus', 'CloudWatch', 'PostgreSQL'],
    status: 'Completed',
  },
  {
    id: 'vpc-network-design',
    title: 'Multi-AZ VPC Network Architecture',
    category: 'Infrastructure',
    tags: ['AWS', 'VPC', 'Networking', 'Terraform'],
    summary: 'Production VPC design with multi-AZ subnets, NAT gateways, and VPN connectivity.',
    description: `A comprehensive VPC network architecture designed for production workloads.
    Features public, private, and isolated subnets across three availability zones. Includes
    NAT gateways for outbound internet access, VPC endpoints for AWS service access without
    internet traversal, and site-to-site VPN for hybrid connectivity. Network ACLs and security
    groups follow defense-in-depth principles.`,
    highlights: [
      'Three-tier subnet architecture across 3 AZs',
      'VPC endpoints for S3, DynamoDB, ECR, and CloudWatch',
      'Site-to-site VPN with BGP routing',
      'Flow logs with CloudWatch analysis',
      'Transit Gateway for multi-VPC connectivity',
    ],
    techStack: ['AWS VPC', 'Terraform', 'Transit Gateway', 'VPN', 'Route 53 Resolver'],
    status: 'Completed',
  },
]
