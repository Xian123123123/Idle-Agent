class AgentModel {
  final String id;
  final String name;
  final String role;
  final String description;
  final bool isPro;

  const AgentModel({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.isPro,
  });
}

class Agents {
  static const gptEngineer = AgentModel(
    id: 'gpt_engineer',
    name: 'GPT-Engineer-4',
    role: 'Full-Stack Engineer',
    description: 'Writes, tests and deploys production code',
    isPro: false,
  );
  static const researcher = AgentModel(
    id: 'researcher',
    name: 'Research-Agent',
    role: 'ML Researcher',
    description: 'Runs experiments and trains models',
    isPro: true,
  );
  static const devops = AgentModel(
    id: 'devops',
    name: 'DevOps-Agent',
    role: 'DevOps Engineer',
    description: 'Manages CI/CD, Docker and infrastructure',
    isPro: true,
  );
  static const cto = AgentModel(
    id: 'cto',
    name: 'Startup-CTO',
    role: 'Chief Technology Officer',
    description: 'Reviews code, plans architecture, leads team',
    isPro: true,
  );

  static List<AgentModel> get all => [gptEngineer, researcher, devops, cto];
}
