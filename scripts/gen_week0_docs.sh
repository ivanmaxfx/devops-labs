#!/usr/bin/env bash
set -euo pipefail

ROOT="${ROOT:-$HOME/devops-labs}"
mkdir -p "$ROOT/week0"

have() { command -v "$1" >/dev/null 2>&1; }
run_to_file() { # run_to_file "cmd" "outfile"
  local cmd="$1" out="$2"
  # 8 секунд на команду, чтобы ничего не висело
  timeout 8s bash -lc "$cmd" >"$out" 2>&1 || {
    echo "[WARN] Command timed out or failed: $cmd" >>"$out"
  }
}

echo "[INFO] Generating Week0 docs at $(date -Is)"

# 1) Версии инструментов (локально, без сетевых вызовов)
vers_file="$ROOT/week0/tools_versions.txt"
{
  echo "# Tools versions ($(date -Is))"
  # kubectl — только клиент
  if have kubectl; then echo -e "\n## kubectl"; kubectl version --client --short 2>&1 || true; else echo -e "\n## kubectl\nN/A"; fi
  if have helm; then echo -e "\n## helm"; helm version --short 2>&1 || helm version 2>&1 || true; else echo -e "\n## helm\nN/A"; fi
  if have kustomize; then echo -e "\n## kustomize"; kustomize version 2>&1 || true; else echo -e "\n## kustomize\nN/A"; fi
  if have terraform; then echo -e "\n## terraform"; terraform -version 2>&1 || true; else echo -e "\n## terraform\nN/A"; fi
  if have ansible; then echo -e "\n## ansible"; ansible --version 2>&1 || true; else echo -e "\n## ansible\nN/A"; fi
  if have trivy; then echo -e "\n## trivy"; trivy --version 2>&1 || true; else echo -e "\n## trivy\nN/A"; fi
  if have stern; then echo -e "\n## stern"; stern --version 2>&1 || true; else echo -e "\n## stern\nN/A"; fi
} > "$vers_file"

# 2) kubectl get nodes (только если есть кластер kind и сам kubectl)
nodes_file="$ROOT/week0/kind_nodes.txt"
: > "$nodes_file"
if have kubectl; then
  # Поищем кластер kind "devstack"; если нет — пропустим
  if have kind && timeout 5s kind get clusters | grep -qx "devstack"; then
    echo "[INFO] Using kind context: kind-devstack" >> "$nodes_file"
    timeout 8s kubectl --context kind-devstack --request-timeout=5s get nodes -o wide >> "$nodes_file" 2>&1 || \
      echo "[WARN] kubectl get nodes failed or timed out" >> "$nodes_file"
  else
    echo "[INFO] kind cluster 'devstack' not found; skipping kubectl get nodes" >> "$nodes_file"
  fi
else
  echo "[INFO] kubectl not installed; skipping" >> "$nodes_file"
fi

# 3) README
cat > "$ROOT/week0/README.md" <<MD
# Week 0 — Установка и проверки

## Что делали
- Установка Docker/Compose, kubectl, Helm, Kustomize, Terraform, Ansible, Trivy, stern.
- Подняли (или проверили) локальный кластер kind.

## Артефакты
- \`week0/tools_versions.txt\` — версии инструментов.
- \`week0/kind_nodes.txt\` — состояние кластера (если найден kind-devstack).

## Снэпшоты
### kubectl get nodes -o wide
\`\`\`text
$(sed -n '1,80p' "$nodes_file")
\`\`\`

### Инструменты (начало)
\`\`\`text
$(sed -n '1,60p' "$vers_file")
...\n(см. полный файл в tools_versions.txt)
\`\`\`
MD

# 4) Коммит (без остановки, если нечего коммитить)
if git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  git -C "$ROOT" add week0/README.md week0/tools_versions.txt week0/kind_nodes.txt
  git -C "$ROOT" commit -m "week0: regenerate README and artifacts (timeouts, safe kubectl)" || true
fi

echo "[OK] Week0 docs updated -> $ROOT/week0"
