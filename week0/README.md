# Week 0 — Установка и проверки

## Что делали
- Установка Docker/Compose, kubectl, Helm, Kustomize, Terraform, Ansible, Trivy, stern.
- Подняли (или проверили) локальный кластер kind.

## Артефакты
- `week0/tools_versions.txt` — версии инструментов.
- `week0/kind_nodes.txt` — состояние кластера (если найден kind-devstack).

## Снэпшоты
### kubectl get nodes -o wide
```text
[INFO] Using kind context: kind-devstack
NAME                     STATUS   ROLES           AGE   VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                         KERNEL-VERSION      CONTAINER-RUNTIME
devstack-control-plane   Ready    control-plane   23h   v1.34.0   172.18.0.2    <none>        Debian GNU/Linux 12 (bookworm)   6.14.0-33-generic   containerd://2.1.3
```

### Инструменты (начало)
```text
# Tools versions (2025-10-28T16:41:09+02:00)

## kubectl
error: unknown flag: --short
See 'kubectl version --help' for usage.

## helm
v3.19.0+g3d8990f

## kustomize
v5.7.1

## terraform
Terraform v1.9.8
on linux_amd64

Your version of Terraform is out of date! The latest version
is 1.13.4. You can update by downloading from https://www.terraform.io/downloads.html

## ansible
ansible [core 2.16.3]
  config file = None
  configured module search path = ['/home/ivanm/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /home/ivanm/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.12.3 (main, Aug 14 2025, 17:47:21) [GCC 13.3.0] (/usr/bin/python3)
  jinja version = 3.1.2
  libyaml = True

## trivy
Version: 0.52.2

## stern
version: 1.33.0
commit: f79098037d951aad53e13aff1f86854b291baf01
built at: 2025-09-07T06:18:52Z
...\n(см. полный файл в tools_versions.txt)
```
