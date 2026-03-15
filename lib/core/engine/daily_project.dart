import 'dart:math';

class DailyProject {
  final String name;
  final String slug;
  final String description;
  final String domain;
  const DailyProject({required this.name, required this.slug, required this.description, required this.domain});
}

class DailyProjectEngine {
  static DailyProject today() {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final seed = now.year * 1000 + dayOfYear;
    final rng = Random(seed);
    return _allProjects[rng.nextInt(_allProjects.length)];
  }

  static List<DailyProject> upcomingWeek() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.add(Duration(days: i));
      final dayOfYear = date.difference(DateTime(date.year)).inDays;
      final seed = date.year * 1000 + dayOfYear;
      final rng = Random(seed);
      return _allProjects[rng.nextInt(_allProjects.length)];
    });
  }

  static const _allProjects = [
    DailyProject(name: 'Neural Architecture Search', slug: 'neural-arch-search', description: 'AutoML system for discovering optimal network topologies', domain: 'ml'),
    DailyProject(name: 'Distributed Vector Store', slug: 'vector-store-v2', description: 'High-performance embedding storage with HNSW indexing', domain: 'backend'),
    DailyProject(name: 'LLM Fine-tuning Pipeline', slug: 'llm-finetuner', description: 'LoRA-based fine-tuning with automated hyperparameter search', domain: 'ml'),
    DailyProject(name: 'Real-time API Gateway', slug: 'api-gateway-rt', description: 'WebSocket-first gateway with circuit breaker and rate limiting', domain: 'backend'),
    DailyProject(name: 'Kubernetes Operator', slug: 'k8s-ml-operator', description: 'Custom CRD for managing ML training jobs on Kubernetes', domain: 'devops'),
    DailyProject(name: 'RAG Pipeline', slug: 'rag-pipeline', description: 'Retrieval-augmented generation with multi-source indexing', domain: 'ml'),
    DailyProject(name: 'Event Streaming Platform', slug: 'event-stream', description: 'Kafka-compatible event bus with exactly-once semantics', domain: 'backend'),
    DailyProject(name: 'Model Serving Infrastructure', slug: 'model-server', description: 'gRPC inference server with dynamic batching and autoscaling', domain: 'devops'),
    DailyProject(name: 'Recommendation Engine', slug: 'rec-engine', description: 'Collaborative filtering with real-time feature store', domain: 'ml'),
    DailyProject(name: 'Auth Microservice', slug: 'auth-service', description: 'Zero-trust authentication with JWT and refresh token rotation', domain: 'backend'),
    DailyProject(name: 'CI/CD Automation Platform', slug: 'cicd-platform', description: 'GitHub Actions replacement with ML-powered test selection', domain: 'devops'),
    DailyProject(name: 'Semantic Search Engine', slug: 'semantic-search', description: 'Dense retrieval with cross-encoder re-ranking', domain: 'ml'),
    DailyProject(name: 'Payments API', slug: 'payments-api', description: 'PCI-compliant payment processing with Stripe integration', domain: 'startup'),
    DailyProject(name: 'Analytics Dashboard', slug: 'analytics-dash', description: 'Real-time metrics pipeline with ClickHouse backend', domain: 'startup'),
    DailyProject(name: 'Mobile Backend', slug: 'mobile-backend', description: 'GraphQL API with offline-first sync and push notifications', domain: 'startup'),
    DailyProject(name: 'Security Scanner', slug: 'sec-scanner', description: 'Static analysis tool for detecting vulnerabilities in Python', domain: 'devops'),
    DailyProject(name: 'Data Lake Ingestion', slug: 'data-lake', description: 'Multi-source ETL pipeline with schema evolution support', domain: 'backend'),
    DailyProject(name: 'Agent Orchestrator', slug: 'agent-orch', description: 'Multi-agent coordination framework with tool use and memory', domain: 'ml'),
    DailyProject(name: 'Edge Inference Runtime', slug: 'edge-runtime', description: 'ONNX-based inference engine optimised for mobile and IoT', domain: 'ml'),
    DailyProject(name: 'Billing Service', slug: 'billing-svc', description: 'Usage-based billing with Stripe, invoicing, and dunning', domain: 'startup'),
  ];
}
