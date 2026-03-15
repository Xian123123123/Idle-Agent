import '../models/terminal_line.dart';
import '../models/agent_model.dart';
import '../models/user_profile.dart';
import 'token_bank.dart';
import 'progress_bar_builder.dart';

typedef Scenario = List<TerminalLine> Function();

class ScenarioBank {
  /// Set by SimulationEngine before running scenarios.
  /// Scenarios read from this to personalise output.
  static UserProfile? activeProfile;

  /// Pick a project name, using profile slug when configured.
  static String _projectName() {
    final p = activeProfile;
    if (p != null && p.projectSlug.isNotEmpty) return p.projectSlug;
    return _projectName();
  }

  /// Pick a module name, preferring profile custom modules when available.
  static String _moduleName() {
    final p = activeProfile;
    if (p != null && p.customModules.isNotEmpty) return TokenBank.pick(p.customModules);
    return _moduleName();
  }
  static List<Scenario> scenariosFor(AgentModel agent) {
    switch (agent.id) {
      case 'gpt_engineer':
        return [buildModule, apiDesign, debugSession, refactor];
      case 'researcher':
        return [modelTraining, ablationStudy, paperImplementation, experimentLogging];
      case 'devops':
        return [dockerBuild, k8sDeploy, ciPipeline, infraProvision];
      case 'cto':
        return [codeReview, architectureReview, techDebt, sprintPlanning];
      default:
        return [buildModule, apiDesign, debugSession, refactor];
    }
  }

  // ── GPT Engineer Scenarios ──

  static List<TerminalLine> buildModule() {
    final project = _projectName();
    final module = _moduleName();
    final func = TokenBank.pick(TokenBank.functionNames);
    final dModel = TokenBank.pick(TokenBank.dModels);
    final nHead = TokenBank.pick(TokenBank.nHeads);
    final testCount = TokenBank.randInt(8, 24);

    return [
      TerminalLine(text: '> cd ~/projects/$project', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> creating module: $module.py', type: LineType.system, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'import torch', type: LineType.code, delayMs: 120),
      TerminalLine(text: 'import torch.nn as nn', type: LineType.code, delayMs: 100),
      TerminalLine(text: 'from typing import Optional, Tuple', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 80),
      TerminalLine(text: 'class ${_pascalCase(module)}(nn.Module):', type: LineType.code, delayMs: 150),
      TerminalLine(text: '    def __init__(self, d_model=$dModel, n_heads=$nHead):', type: LineType.code, delayMs: 120),
      TerminalLine(text: '        super().__init__()', type: LineType.code, delayMs: 100),
      TerminalLine(text: '        self.attention = nn.MultiheadAttention(d_model, n_heads)', type: LineType.code, delayMs: 130),
      TerminalLine(text: '        self.norm = nn.LayerNorm(d_model)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '        self.ffn = nn.Sequential(', type: LineType.code, delayMs: 100),
      TerminalLine(text: '            nn.Linear(d_model, d_model * 4),', type: LineType.code, delayMs: 90),
      TerminalLine(text: '            nn.GELU(),', type: LineType.code, delayMs: 90),
      TerminalLine(text: '            nn.Linear(d_model * 4, d_model)', type: LineType.code, delayMs: 90),
      TerminalLine(text: '        )', type: LineType.code, delayMs: 80),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '    def $func(self, x: torch.Tensor) -> torch.Tensor:', type: LineType.code, delayMs: 140),
      TerminalLine(text: '        attn_out, _ = self.attention(x, x, x)', type: LineType.code, delayMs: 110),
      TerminalLine(text: '        x = self.norm(x + attn_out)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '        return x + self.ffn(x)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 150),
      TerminalLine(text: '> pytest tests/ -v', type: LineType.system, delayMs: 300),
      TerminalLine(text: '  collected $testCount items', type: LineType.comment, delayMs: 200),
      for (int i = 0; i < testCount; i++)
        TerminalLine(
          text: '  ${TokenBank.pick(TokenBank.testNames)} ... PASSED',
          type: LineType.success,
          delayMs: TokenBank.randInt(80, 200),
        ),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 $testCount passed in ${(testCount * 0.3).toStringAsFixed(1)}s', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> apiDesign() {
    final project = _projectName();
    final module = _moduleName();

    return [
      TerminalLine(text: '> scaffolding REST API for $project', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'from fastapi import FastAPI, HTTPException', type: LineType.code, delayMs: 120),
      TerminalLine(text: 'from pydantic import BaseModel', type: LineType.code, delayMs: 100),
      TerminalLine(text: 'from typing import List, Optional', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 80),
      TerminalLine(text: 'app = FastAPI(title="$project")', type: LineType.code, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 80),
      TerminalLine(text: 'class ${_pascalCase(module)}Request(BaseModel):', type: LineType.code, delayMs: 130),
      TerminalLine(text: '    input_text: str', type: LineType.code, delayMs: 90),
      TerminalLine(text: '    max_tokens: int = 512', type: LineType.code, delayMs: 90),
      TerminalLine(text: '    temperature: float = 0.7', type: LineType.code, delayMs: 90),
      TerminalLine(text: '', type: LineType.blank, delayMs: 80),
      TerminalLine(text: '@app.post("/api/v1/$module")', type: LineType.code, delayMs: 120),
      TerminalLine(text: 'async def process(request: ${_pascalCase(module)}Request):', type: LineType.code, delayMs: 120),
      TerminalLine(text: '    result = await ${module}_service.process(request)', type: LineType.code, delayMs: 110),
      TerminalLine(text: '    return {"status": "ok", "data": result}', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> generating OpenAPI spec...', type: LineType.system, delayMs: 250),
      TerminalLine(text: '\u2713 openapi.json written (${TokenBank.randInt(12, 36)} endpoints)', type: LineType.success, delayMs: 200),
      TerminalLine(text: '> adding rate limiter middleware', type: LineType.system, delayMs: 200),
      TerminalLine(text: '\u2713 rate limit: 100 req/min per API key', type: LineType.success, delayMs: 150),
      TerminalLine(text: '\u2713 API scaffold complete', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> debugSession() {
    final project = _projectName();
    final module = _moduleName();
    final error = TokenBank.pick(TokenBank.errors);
    final func = TokenBank.pick(TokenBank.functionNames);

    return [
      TerminalLine(text: '> running $project test suite...', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 300),
      TerminalLine(text: 'FAILED tests/${module}_test.py::test_$func', type: LineType.error, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'Traceback (most recent call last):', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  File "src/$module.py", line ${TokenBank.randInt(42, 198)}', type: LineType.error, delayMs: 120),
      TerminalLine(text: '    result = self.$func(input_tensor)', type: LineType.error, delayMs: 120),
      TerminalLine(text: '$error: expected shape (${TokenBank.randInt(16, 64)}, ${TokenBank.pick(TokenBank.dModels)})', type: LineType.error, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 200),
      TerminalLine(text: '> analyzing error...', type: LineType.system, delayMs: 400),
      TerminalLine(text: '# Root cause: dimension mismatch in $func', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '# Fix: transpose input before matrix multiply', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 150),
      TerminalLine(text: '> applying fix...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '-    result = self.$func(input_tensor)', type: LineType.error, delayMs: 150),
      TerminalLine(text: '+    result = self.$func(input_tensor.transpose(-1, -2))', type: LineType.success, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 200),
      TerminalLine(text: '> re-running tests...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '\u2713 test_$func PASSED', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 all ${TokenBank.randInt(12, 30)} tests passed', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> refactor() {
    final project = _projectName();
    final module = _moduleName();
    final lines = TokenBank.randInt(200, 800);

    return [
      TerminalLine(text: '> analyzing $project/$module.py ($lines lines)', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 200),
      TerminalLine(text: '# Code quality analysis:', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '  - Cyclomatic complexity: ${TokenBank.randInt(12, 28)} (high)', type: LineType.error, delayMs: 120),
      TerminalLine(text: '  - Duplicate code: ${TokenBank.randInt(3, 8)} blocks', type: LineType.error, delayMs: 120),
      TerminalLine(text: '  - Missing type hints: ${TokenBank.randInt(15, 40)} functions', type: LineType.error, delayMs: 120),
      TerminalLine(text: '  - Dead code: ${TokenBank.randInt(20, 60)} lines', type: LineType.error, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 150),
      TerminalLine(text: '> extracting common patterns...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '\u2713 extracted BaseProcessor class', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 created utils/validation.py', type: LineType.success, delayMs: 180),
      TerminalLine(text: '> adding type annotations...', type: LineType.system, delayMs: 250),
      TerminalLine(text: '\u2713 annotated ${TokenBank.randInt(15, 40)} functions', type: LineType.success, delayMs: 200),
      TerminalLine(text: '> removing dead code...', type: LineType.system, delayMs: 200),
      TerminalLine(text: '\u2713 removed ${TokenBank.randInt(20, 60)} lines', type: LineType.success, delayMs: 180),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> final complexity: ${TokenBank.randInt(4, 8)} (good)', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 refactoring complete — $lines \u2192 ${(lines * 0.6).round()} lines', type: LineType.success, delayMs: 200),
    ];
  }

  // ── Researcher Scenarios ──

  static List<TerminalLine> modelTraining() {
    final project = _projectName();
    final dModel = TokenBank.pick(TokenBank.dModels);
    final numEpochs = TokenBank.pick(TokenBank.epochs);
    final displayEpochs = numEpochs > 20 ? 15 : numEpochs;

    final lines = <TerminalLine>[
      TerminalLine(text: '> training $project (d_model=$dModel)', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> initializing model weights...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '# params: ${(dModel * dModel * 12 / 1000000).toStringAsFixed(1)}M', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
    ];

    double loss = 2.4 + TokenBank.rng.nextDouble() * 0.8;
    double acc = 0.1 + TokenBank.rng.nextDouble() * 0.1;

    const barWidth = 20;
    for (int i = 1; i <= displayEpochs; i++) {
      loss *= (0.88 + TokenBank.rng.nextDouble() * 0.08);
      acc += (1.0 - acc) * (0.05 + TokenBank.rng.nextDouble() * 0.08);
      final epoch = numEpochs > 20 ? (i * numEpochs ~/ displayEpochs) : i;
      final progress = i / displayEpochs;
      final filled = (progress * barWidth).round();
      final empty = barWidth - filled;
      final bar = '${'█' * filled}${'░' * empty}';
      final pct = (progress * 100).round();
      lines.add(TerminalLine(
        text: '  Epoch $epoch/$numEpochs [$bar] $pct%',
        type: LineType.system,
        delayMs: TokenBank.randInt(150, 350),
      ));
      lines.add(TerminalLine(
        text: '    loss: ${loss.toStringAsFixed(4)}  acc: ${(acc * 100).toStringAsFixed(1)}%',
        type: LineType.code,
        delayMs: TokenBank.randInt(80, 150),
      ));
    }

    lines.addAll([
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> validation metrics:', type: LineType.system, delayMs: 200),
      TerminalLine(text: '  val_loss: ${(loss * 1.1).toStringAsFixed(4)}  val_acc: ${(acc * 0.97 * 100).toStringAsFixed(1)}%', type: LineType.code, delayMs: 200),
      TerminalLine(text: '\u2713 model saved to checkpoints/$project-best.pt', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 training complete', type: LineType.success, delayMs: 200),
    ]);

    return lines;
  }

  static List<TerminalLine> ablationStudy() {
    final project = _projectName();
    final configs = TokenBank.randInt(4, 8);

    final lines = <TerminalLine>[
      TerminalLine(text: '> ablation study: $project', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> testing $configs configurations...', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
    ];

    double bestAcc = 0;
    String bestConfig = '';

    for (int i = 0; i < configs; i++) {
      final dModel = TokenBank.pick(TokenBank.dModels);
      final nHead = TokenBank.pick(TokenBank.nHeads);
      final acc = 0.7 + TokenBank.rng.nextDouble() * 0.25;
      final config = 'd=$dModel h=$nHead';
      if (acc > bestAcc) {
        bestAcc = acc;
        bestConfig = config;
      }
      lines.add(TerminalLine(
        text: '  config $i: $config  acc: ${(acc * 100).toStringAsFixed(1)}%',
        type: LineType.code,
        delayMs: TokenBank.randInt(200, 400),
      ));
    }

    lines.addAll([
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> logging results to W&B...', type: LineType.system, delayMs: 250),
      TerminalLine(text: '\u2713 synced to wandb.ai/$project/ablation', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 best config: $bestConfig (${(bestAcc * 100).toStringAsFixed(1)}%)', type: LineType.success, delayMs: 200),
    ]);

    return lines;
  }

  static List<TerminalLine> paperImplementation() {
    final arxivId = '${TokenBank.randInt(2301, 2412)}.${TokenBank.randInt(10000, 99999)}';
    final project = _projectName();

    return [
      TerminalLine(text: '> reading arxiv:$arxivId', type: LineType.system, delayMs: 200),
      TerminalLine(text: '# "Efficient ${_pascalCase(project)} with Sparse Attention"', type: LineType.comment, delayMs: 300),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> implementing Algorithm 1...', type: LineType.system, delayMs: 250),
      TerminalLine(text: 'class SparseAttention(nn.Module):', type: LineType.code, delayMs: 150),
      TerminalLine(text: '    def __init__(self, d_model, sparsity=0.9):', type: LineType.code, delayMs: 120),
      TerminalLine(text: '        self.mask = self._create_sparse_mask(sparsity)', type: LineType.code, delayMs: 120),
      TerminalLine(text: '        self.proj_q = nn.Linear(d_model, d_model)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '        self.proj_k = nn.Linear(d_model, d_model)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '        self.proj_v = nn.Linear(d_model, d_model)', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> running benchmarks vs dense attention...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '  dense:  ${TokenBank.randInt(120, 200)}ms/batch  mem: ${TokenBank.randInt(4, 12)}GB', type: LineType.code, delayMs: 200),
      TerminalLine(text: '  sparse: ${TokenBank.randInt(40, 80)}ms/batch   mem: ${TokenBank.randInt(1, 4)}GB', type: LineType.code, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 ${TokenBank.randInt(2, 5)}x speedup achieved', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 paper implementation verified', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> experimentLogging() {
    final project = _projectName();
    final runId = 'run-${TokenBank.randInt(100, 999)}';

    return [
      TerminalLine(text: '> mlflow experiment: $project', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> creating run: $runId', type: LineType.system, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'mlflow.set_experiment("$project")', type: LineType.code, delayMs: 120),
      TerminalLine(text: 'with mlflow.start_run(run_name="$runId"):', type: LineType.code, delayMs: 120),
      TerminalLine(text: '    mlflow.log_param("learning_rate", ${(TokenBank.rng.nextDouble() * 0.01).toStringAsFixed(5)})', type: LineType.code, delayMs: 100),
      TerminalLine(text: '    mlflow.log_param("batch_size", ${TokenBank.pick(const [16, 32, 64, 128])})', type: LineType.code, delayMs: 100),
      TerminalLine(text: '    mlflow.log_param("d_model", ${TokenBank.pick(TokenBank.dModels)})', type: LineType.code, delayMs: 100),
      TerminalLine(text: '    mlflow.log_param("optimizer", "${TokenBank.pick(const ['adam', 'adamw', 'sgd', 'lamb'])}")', type: LineType.code, delayMs: 100),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> training model...', type: LineType.system, delayMs: 400),
      TerminalLine(text: '    mlflow.log_metric("final_loss", ${(0.1 + TokenBank.rng.nextDouble() * 0.3).toStringAsFixed(4)})', type: LineType.code, delayMs: 150),
      TerminalLine(text: '    mlflow.log_metric("final_acc", ${(0.85 + TokenBank.rng.nextDouble() * 0.12).toStringAsFixed(4)})', type: LineType.code, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> saving artifacts...', type: LineType.system, delayMs: 250),
      TerminalLine(text: '\u2713 model artifact saved (${TokenBank.randInt(50, 500)}MB)', type: LineType.success, delayMs: 200),
      TerminalLine(text: '\u2713 experiment $runId logged to MLflow', type: LineType.success, delayMs: 200),
    ];
  }

  // ── DevOps Scenarios ──

  static List<TerminalLine> dockerBuild() {
    final project = _projectName();
    final steps = TokenBank.randInt(8, 14);

    final lines = <TerminalLine>[
      TerminalLine(text: '> docker build -t $project:latest .', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
    ];

    final stageNames = [
      'FROM python:3.11-slim AS base',
      'RUN apt-get update && apt-get install -y gcc',
      'COPY requirements.txt .',
      'RUN pip install --no-cache-dir -r requirements.txt',
      'FROM base AS builder',
      'COPY src/ ./src/',
      'COPY config/ ./config/',
      'RUN python -m compileall src/',
      'FROM python:3.11-slim AS runtime',
      'COPY --from=builder /app /app',
      'RUN useradd -r appuser && chown -R appuser /app',
      'EXPOSE 8000',
      'HEALTHCHECK CMD curl -f http://localhost:8000/health',
      'CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0"]',
    ];

    for (int i = 0; i < steps && i < stageNames.length; i++) {
      final cached = TokenBank.rng.nextDouble() > 0.4;
      lines.add(TerminalLine(
        text: 'Step ${i + 1}/$steps : ${stageNames[i]}',
        type: LineType.code,
        delayMs: TokenBank.randInt(100, 300),
      ));
      if (cached) {
        lines.add(TerminalLine(text: ' ---> Using cache', type: LineType.comment, delayMs: 80));
      }
    }

    lines.addAll([
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      ...ProgressBarBuilder.build(label: 'Building image', durationSteps: 6, msPerStep: 250),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 built $project:latest (${TokenBank.randInt(120, 450)}MB)', type: LineType.success, delayMs: 200),
      TerminalLine(text: '> docker push registry.io/$project:latest', type: LineType.system, delayMs: 250),
      TerminalLine(text: '\u2713 pushed to container registry', type: LineType.success, delayMs: 300),
    ]);

    return lines;
  }

  static List<TerminalLine> k8sDeploy() {
    final project = _projectName();
    final replicas = TokenBank.randInt(3, 8);

    final lines = <TerminalLine>[
      TerminalLine(text: '> kubectl apply -f deployment.yaml', type: LineType.system, delayMs: 200),
      TerminalLine(text: '  deployment.apps/$project configured', type: LineType.code, delayMs: 150),
      TerminalLine(text: '  service/$project-svc configured', type: LineType.code, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> rolling update ($replicas replicas):', type: LineType.system, delayMs: 200),
    ];

    for (int i = 0; i < replicas; i++) {
      lines.addAll([
        TerminalLine(
          text: '  pod/$project-${_hexId()} terminating...',
          type: LineType.comment,
          delayMs: TokenBank.randInt(200, 400),
        ),
        TerminalLine(
          text: '  pod/$project-${_hexId()} running (1/1)',
          type: LineType.success,
          delayMs: TokenBank.randInt(150, 300),
        ),
      ]);
    }

    lines.addAll([
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> health checks:', type: LineType.system, delayMs: 200),
      TerminalLine(text: '  liveness:  \u2713 all pods healthy', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  readiness: \u2713 all pods ready', type: LineType.success, delayMs: 150),
      TerminalLine(text: '\u2713 deployment complete — $replicas/$replicas pods running', type: LineType.success, delayMs: 200),
    ]);

    return lines;
  }

  static List<TerminalLine> ciPipeline() {
    final project = _projectName();
    final coverage = TokenBank.randInt(78, 98);

    return [
      TerminalLine(text: '> GitHub Actions: $project CI/CD', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '  Stage 1/3: Test', type: LineType.system, delayMs: 200),
      TerminalLine(text: '    > pip install -r requirements-dev.txt', type: LineType.code, delayMs: 150),
      TerminalLine(text: '    > pytest --cov=src --cov-report=xml', type: LineType.code, delayMs: 300),
      ...ProgressBarBuilder.build(label: 'Running tests', durationSteps: 4, msPerStep: 200),
      TerminalLine(text: '    \u2713 ${TokenBank.randInt(50, 200)} tests passed', type: LineType.success, delayMs: 200),
      TerminalLine(text: '    \u2713 coverage: $coverage%', type: LineType.success, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '  Stage 2/3: Build', type: LineType.system, delayMs: 200),
      TerminalLine(text: '    > docker build -t $project:sha-${_hexId()}', type: LineType.code, delayMs: 250),
      TerminalLine(text: '    \u2713 image built (${TokenBank.randInt(120, 300)}MB)', type: LineType.success, delayMs: 200),
      TerminalLine(text: '    > trivy image --severity HIGH,CRITICAL', type: LineType.code, delayMs: 200),
      TerminalLine(text: '    \u2713 0 vulnerabilities found', type: LineType.success, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '  Stage 3/3: Deploy', type: LineType.system, delayMs: 200),
      TerminalLine(text: '    > kubectl set image deployment/$project', type: LineType.code, delayMs: 200),
      TerminalLine(text: '    \u2713 deployed to production', type: LineType.success, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 pipeline passed (${TokenBank.randInt(2, 8)}m ${TokenBank.randInt(10, 55)}s)', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> infraProvision() {
    final project = _projectName();
    final resources = TokenBank.randInt(8, 18);

    return [
      TerminalLine(text: '> terraform plan -var="project=$project"', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 200),
      TerminalLine(text: '  + aws_vpc.main', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  + aws_subnet.private[0]', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_subnet.private[1]', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_ecs_cluster.$project', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_ecs_service.$project', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_rds_instance.postgres', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_elasticache_cluster.redis', type: LineType.success, delayMs: 120),
      TerminalLine(text: '  + aws_alb.$project', type: LineType.success, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'Plan: $resources to add, 0 to change, 0 to destroy.', type: LineType.system, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 150),
      TerminalLine(text: '> terraform apply -auto-approve', type: LineType.system, delayMs: 300),
      TerminalLine(text: '  applying... ($resources resources)', type: LineType.comment, delayMs: 400),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: 'Outputs:', type: LineType.system, delayMs: 200),
      TerminalLine(text: '  alb_dns = "$project-alb-${TokenBank.randInt(100, 999)}.us-east-1.elb.amazonaws.com"', type: LineType.code, delayMs: 150),
      TerminalLine(text: '  rds_endpoint = "$project-db.${_hexId()}.us-east-1.rds.amazonaws.com"', type: LineType.code, delayMs: 150),
      TerminalLine(text: '\u2713 infrastructure provisioned', type: LineType.success, delayMs: 200),
    ];
  }

  // ── Startup CTO Scenarios ──

  static List<TerminalLine> codeReview() {
    final project = _projectName();
    final module = _moduleName();
    final prNum = TokenBank.randInt(100, 999);

    return [
      TerminalLine(text: '> reviewing PR #$prNum ($project): "$module refactor"', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> git diff main...feature/$module', type: LineType.system, delayMs: 200),
      TerminalLine(text: '  ${TokenBank.randInt(5, 15)} files changed, +${TokenBank.randInt(200, 800)} -${TokenBank.randInt(50, 300)}', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 200),
      TerminalLine(text: '# Issues found:', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '  [CRITICAL] N+1 query in ${module}_controller.py:${TokenBank.randInt(40, 120)}', type: LineType.error, delayMs: 200),
      TerminalLine(text: '  [WARN] Missing index on ${module}_id column', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  [INFO] Consider adding caching layer for /api/$module', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Suggested fix for N+1:', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '-  for item in items:', type: LineType.error, delayMs: 120),
      TerminalLine(text: '-      detail = db.query(Detail).filter_by(id=item.id).first()', type: LineType.error, delayMs: 120),
      TerminalLine(text: '+  details = db.query(Detail).filter(Detail.id.in_(item_ids)).all()', type: LineType.success, delayMs: 120),
      TerminalLine(text: '+  detail_map = {d.id: d for d in details}', type: LineType.success, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 approved with comments (2 must-fix, 1 suggestion)', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> architectureReview() {
    final project = _projectName();

    return [
      TerminalLine(text: '> architecture review: $project', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> analyzing system design...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Current architecture: monolith (${TokenBank.randInt(30, 80)}k LOC)', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Bottlenecks identified:', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '  1. Database: single PostgreSQL handling ${TokenBank.randInt(5, 20)}k req/s', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  2. Auth service tightly coupled to business logic', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  3. No message queue — synchronous inter-service calls', type: LineType.error, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Proposed microservices split:', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '  \u2713 api-gateway (auth + routing)', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  \u2713 user-service (profiles, preferences)', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  \u2713 core-engine (business logic)', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  \u2713 data-pipeline (async processing)', type: LineType.success, delayMs: 150),
      TerminalLine(text: '  \u2713 notification-service (email, push)', type: LineType.success, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 architecture doc generated — shared in Confluence', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> techDebt() {
    final project = _projectName();
    final issues = TokenBank.randInt(12, 30);

    return [
      TerminalLine(text: '> scanning $project for tech debt...', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> analyzing ${TokenBank.randInt(50, 200)} files...', type: LineType.system, delayMs: 400),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Found $issues issues:', type: LineType.comment, delayMs: 200),
      TerminalLine(text: '  [P0] Deprecated ${TokenBank.pick(TokenBank.libraries)} — security risk', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  [P0] Hardcoded secrets in config.py', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  [P1] No database migrations for 3 schema changes', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  [P1] Test coverage below 60% in ${_moduleName()}', type: LineType.error, delayMs: 150),
      TerminalLine(text: '  [P2] ${TokenBank.randInt(8, 20)} TODO comments older than 6 months', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '  [P2] Unused dependencies: ${TokenBank.randInt(3, 8)} packages', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '> creating Jira tickets...', type: LineType.system, delayMs: 300),
      TerminalLine(text: '\u2713 TECH-${TokenBank.randInt(100, 999)}: upgrade deprecated packages', type: LineType.success, delayMs: 150),
      TerminalLine(text: '\u2713 TECH-${TokenBank.randInt(100, 999)}: migrate secrets to Vault', type: LineType.success, delayMs: 150),
      TerminalLine(text: '\u2713 TECH-${TokenBank.randInt(100, 999)}: add missing migrations', type: LineType.success, delayMs: 150),
      TerminalLine(text: '\u2713 $issues tickets created, prioritised by impact', type: LineType.success, delayMs: 200),
    ];
  }

  static List<TerminalLine> sprintPlanning() {
    final velocity = TokenBank.randInt(30, 60);
    final stories = TokenBank.randInt(8, 15);
    final teamMembers = ['Alice', 'Bob', 'Carol', 'Dave', 'Eve'];

    final lines = <TerminalLine>[
      TerminalLine(text: '> sprint planning: Sprint ${TokenBank.randInt(20, 50)}', type: LineType.system, delayMs: 200),
      TerminalLine(text: '> team velocity: $velocity pts/sprint', type: LineType.system, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Backlog review ($stories stories):', type: LineType.comment, delayMs: 200),
    ];

    int totalPoints = 0;
    for (int i = 0; i < stories && totalPoints < velocity; i++) {
      final points = TokenBank.pick(const [1, 2, 3, 5, 8]);
      totalPoints += points;
      final assignee = TokenBank.pick(teamMembers);
      final module = _moduleName();
      lines.add(TerminalLine(
        text: '  [$points pts] $module — assigned to $assignee',
        type: LineType.code,
        delayMs: TokenBank.randInt(100, 200),
      ));
    }

    lines.addAll([
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '# Sprint capacity:', type: LineType.comment, delayMs: 150),
      TerminalLine(text: '  committed: $totalPoints / $velocity pts', type: LineType.code, delayMs: 150),
      TerminalLine(text: '  buffer: ${velocity - totalPoints} pts for bugs/support', type: LineType.code, delayMs: 150),
      TerminalLine(text: '', type: LineType.blank, delayMs: 100),
      TerminalLine(text: '\u2713 sprint planned and published to Jira', type: LineType.success, delayMs: 200),
    ]);

    return lines;
  }

  // ── Git Log Scene ──

  static List<TerminalLine> gitLogScene() {
    final hash1 = _hexId();
    final hash2 = _hexId();
    final hash3 = _hexId();
    final project = _projectName();
    return [
      TerminalLine(text: '', type: LineType.blank, delayMs: 400),
      TerminalLine(text: '> git log --oneline -5', type: LineType.system, delayMs: 600),
      TerminalLine(text: '$hash1 feat: add transformer encoder layer', type: LineType.code, delayMs: 200),
      TerminalLine(text: '$hash2 fix: resolve attention mask broadcasting', type: LineType.code, delayMs: 120),
      TerminalLine(text: '$hash3 refactor: extract positional encoding', type: LineType.code, delayMs: 120),
      TerminalLine(text: '', type: LineType.blank, delayMs: 300),
      TerminalLine(text: '> git diff --stat HEAD~1', type: LineType.system, delayMs: 400),
      TerminalLine(text: ' src/models/encoder.py  | 47 +++++++++++++----', type: LineType.success, delayMs: 200),
      TerminalLine(text: ' tests/test_encoder.py  | 23 +++++++++', type: LineType.success, delayMs: 120),
      TerminalLine(text: ' 2 files changed, 70 insertions(+), 4 deletions(-)', type: LineType.agent, delayMs: 200),
      TerminalLine(text: '', type: LineType.blank, delayMs: 300),
      TerminalLine(text: '> git push origin main', type: LineType.system, delayMs: 500),
      TerminalLine(text: 'Enumerating objects: 5, done.', type: LineType.code, delayMs: 300),
      TerminalLine(text: 'Writing objects: 100% (3/3), 2.41 KiB | 2.41 MiB/s, done.', type: LineType.code, delayMs: 400),
      TerminalLine(text: 'To github.com:agent/$project.git', type: LineType.code, delayMs: 200),
      TerminalLine(text: '   $hash2..$hash1  main -> main', type: LineType.success, delayMs: 200),
      const TerminalLine(text: '', type: LineType.blank),
    ];
  }

  // ── Helpers ──

  static String _pascalCase(String snake) {
    return snake.split('_').map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}').join();
  }

  static String _hexId() {
    const chars = '0123456789abcdef';
    return List.generate(7, (_) => chars[TokenBank.rng.nextInt(chars.length)]).join();
  }
}
