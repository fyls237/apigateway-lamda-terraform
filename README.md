# apigateway-lamda-terraform

> **Déploiement IaC d'une REST API Serverless avec AWS API Gateway et AWS Lambda via Terraform**

---

## 📋 Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Architecture](#architecture)
3. [Prérequis](#prérequis)
4. [Structure du projet](#structure-du-projet)
5. [Missions Terraform](#missions-terraform)
   - [1. API Gateway](#1-api-gateway)
   - [2. Fonctions Lambda](#2-fonctions-lambda)
   - [3. Mise en cache API Gateway](#3-mise-en-cache-api-gateway)
   - [4. Déploiement multi-étapes](#4-déploiement-multi-étapes)
   - [5. Pipeline CI/CD](#5-pipeline-cicd)
6. [Variables de configuration](#variables-de-configuration)
7. [Sorties Terraform](#sorties-terraform)
8. [Déploiement](#déploiement)
9. [Nettoyage](#nettoyage)

---

## Vue d'ensemble

Ce projet déploie une infrastructure **serverless** complète sur AWS à l'aide de **Terraform**. Il comprend :

| Composant | Description |
|-----------|-------------|
| **API Gateway** | Point d'entrée REST qui intercepte les requêtes et les route vers les Lambdas |
| **AWS Lambda** | Fonctions de traitement backend (données, images, utilisateurs) |
| **IAM** | Rôles et politiques d'accès sécurisés |
| **Cache API Gateway** | Réduction de la latence sur les endpoints fréquemment appelés |
| **Stages (dev/test/prod)** | Gestion multi-environnements via des stages API Gateway |
| **GitHub Actions CI/CD** | Pipeline automatisé de déploiement et de gestion des versions |

---

## Architecture

```
Internet
    │
    ▼
┌─────────────────────────────────────────────────┐
│              Amazon API Gateway                 │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  │
│  │  /users  │  │  /data   │  │    /images   │  │
│  └────┬─────┘  └────┬─────┘  └──────┬───────┘  │
│       │             │               │           │
│  Stage: dev / test / prod  (cache activé)       │
└───────┼─────────────┼───────────────┼───────────┘
        │             │               │
        ▼             ▼               ▼
┌───────────┐  ┌────────────┐  ┌─────────────────┐
│  Lambda   │  │   Lambda   │  │     Lambda      │
│  Users    │  │    Data    │  │     Images      │
│Management │  │Processing  │  │   Processing    │
└───────────┘  └────────────┘  └─────────────────┘
```

---

## Prérequis

- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.5.0
- [AWS CLI](https://aws.amazon.com/cli/) configuré (`aws configure`)
- Compte AWS avec droits suffisants (IAM, Lambda, API Gateway, S3)
- Node.js >= 18 (pour les fonctions Lambda)
- Git

---

## Structure du projet

```
apigateway-lamda-terraform/
├── main.tf                        # Provider AWS + backend S3 Terraform
├── variables.tf                   # Déclaration des variables
├── outputs.tf                     # Valeurs de sortie (URLs, ARNs)
├── api_gateway.tf                 # Ressources API Gateway + stages + cache
├── lambda.tf                      # Fonctions Lambda
├── iam.tf                         # Rôles et politiques IAM
├── lambda/
│   ├── user_management/
│   │   └── index.js               # Handler : gestion des utilisateurs
│   ├── data_processing/
│   │   └── index.js               # Handler : traitement de données
│   └── image_processing/
│       └── index.js               # Handler : traitement d'images
├── .github/
│   └── workflows/
│       └── deploy.yml             # Pipeline CI/CD GitHub Actions
├── .gitignore
└── README.md
```

---

## Missions Terraform

### 1. API Gateway

**Fichier :** [`api_gateway.tf`](api_gateway.tf)

L'**API Gateway REST** intercepte toutes les requêtes entrantes et les route vers les fonctions Lambda correspondantes.

#### Ressources créées

| Ressource Terraform | Description |
|---------------------|-------------|
| `aws_api_gateway_rest_api` | API REST principale |
| `aws_api_gateway_resource` | Chemins `/users`, `/data`, `/images` |
| `aws_api_gateway_method` | Méthodes HTTP (GET, POST) par ressource |
| `aws_api_gateway_integration` | Intégration Lambda (proxy) |
| `aws_lambda_permission` | Autorisation API Gateway → Lambda |

#### Exemple de flux de requête

```
POST /users  →  API Gateway  →  Lambda user_management  →  Réponse JSON
GET  /data   →  API Gateway  →  Lambda data_processing  →  Données traitées
POST /images →  API Gateway  →  Lambda image_processing →  Image transformée
```

---

### 2. Fonctions Lambda

**Fichier :** [`lambda.tf`](lambda.tf)

Trois fonctions Lambda couvrent les actions métier principales :

| Fonction | Chemin | Rôle |
|----------|--------|------|
| `user_management` | `/users` | Création, lecture, mise à jour, suppression d'utilisateurs |
| `data_processing` | `/data` | Transformation et validation de données JSON |
| `image_processing` | `/images` | Redimensionnement et conversion d'images |

#### Ressources créées

| Ressource Terraform | Description |
|---------------------|-------------|
| `aws_lambda_function` | Définition de chaque fonction (runtime, handler, rôle IAM) |
| `aws_cloudwatch_log_group` | Groupe de logs CloudWatch par fonction |
| `data.archive_file` | Archive ZIP du code source local |

#### Exemple de handler (user_management)

```javascript
// lambda/user_management/index.js
exports.handler = async (event) => {
  const method = event.httpMethod;
  if (method === 'GET')  return listUsers();
  if (method === 'POST') return createUser(JSON.parse(event.body));
  return { statusCode: 405, body: 'Method Not Allowed' };
};
```

---

### 3. Mise en cache API Gateway

**Fichier :** [`api_gateway.tf`](api_gateway.tf) — section `aws_api_gateway_stage`

La mise en cache est activée **par stage** pour réduire la latence des appels répétitifs.

#### Configuration du cache

```hcl
resource "aws_api_gateway_stage" "prod" {
  rest_api_id   = aws_api_gateway_rest_api.main.id
  deployment_id = aws_api_gateway_deployment.prod.id
  stage_name    = "prod"

  cache_cluster_enabled = true
  cache_cluster_size    = "0.5"   # 0.5 Go (niveau minimal)
}

resource "aws_api_gateway_method_settings" "cache_settings" {
  rest_api_id = aws_api_gateway_rest_api.main.id
  stage_name  = aws_api_gateway_stage.prod.stage_name
  method_path = "*/*"

  settings {
    caching_enabled      = true
    cache_ttl_in_seconds = 300   # 5 minutes
    cache_data_encrypted = true
  }
}
```

> **Note :** Le cache est activé uniquement en `prod` pour minimiser les coûts. En `dev` et `test`, il est désactivé.

---

### 4. Déploiement multi-étapes

**Fichier :** [`api_gateway.tf`](api_gateway.tf)

Trois stages permettent de gérer le cycle de vie de l'API :

| Stage | Objectif | Cache | URL |
|-------|----------|-------|-----|
| `dev` | Développement et tests unitaires | ❌ | `https://<id>.execute-api.<region>.amazonaws.com/dev` |
| `test` | Tests d'intégration et recette | ❌ | `https://<id>.execute-api.<region>.amazonaws.com/test` |
| `prod` | Production | ✅ | `https://<id>.execute-api.<region>.amazonaws.com/prod` |

#### Fonctionnement

```
Code → GitHub → CI/CD pipeline
                    │
          ┌─────────┼──────────┐
          ▼         ▼          ▼
        dev       test        prod
     (toujours) (sur merge  (sur tag
                 main)       v*.*.*)
```

Chaque stage dispose de son propre `aws_api_gateway_deployment` déclenché par un `triggers` basé sur le hash du contenu de l'API, garantissant un redéploiement automatique en cas de changement.

---

### 5. Pipeline CI/CD

**Fichier :** [`.github/workflows/deploy.yml`](.github/workflows/deploy.yml)

Le pipeline **GitHub Actions** automatise l'ensemble du cycle de déploiement.

#### Déclencheurs

| Événement | Action |
|-----------|--------|
| `push` sur n'importe quelle branche | Déploiement sur `dev` |
| `push` sur `main` | Déploiement sur `dev` + `test` |
| Publication d'un tag `v*.*.*` | Déploiement sur `dev` + `test` + `prod` |
| `pull_request` vers `main` | Plan Terraform uniquement (pas de déploiement) |

#### Étapes du pipeline

```
1. Checkout du code
2. Configuration des credentials AWS (via GitHub Secrets)
3. Setup Terraform
4. terraform init  (backend S3 + DynamoDB lock)
5. terraform fmt --check
6. terraform validate
7. terraform plan  (PR) / terraform apply -auto-approve  (push)
8. Notification de déploiement (URL des stages en sortie)
```

#### Secrets GitHub requis

| Secret | Description |
|--------|-------------|
| `AWS_ACCESS_KEY_ID` | Clé d'accès AWS |
| `AWS_SECRET_ACCESS_KEY` | Clé secrète AWS |
| `AWS_REGION` | Région AWS (ex: `eu-west-1`) |
| `TF_STATE_BUCKET` | Nom du bucket S3 pour le state Terraform |
| `TF_STATE_LOCK_TABLE` | Nom de la table DynamoDB pour le lock |

---

## Variables de configuration

**Fichier :** [`variables.tf`](variables.tf)

| Variable | Type | Défaut | Description |
|----------|------|--------|-------------|
| `aws_region` | `string` | `"eu-west-1"` | Région AWS de déploiement |
| `project_name` | `string` | `"apigateway-lambda"` | Préfixe pour toutes les ressources |
| `environment` | `string` | `"dev"` | Environnement actif |
| `lambda_runtime` | `string` | `"nodejs18.x"` | Runtime des fonctions Lambda |
| `lambda_timeout` | `number` | `30` | Timeout Lambda en secondes |
| `lambda_memory_size` | `number` | `128` | Mémoire Lambda en Mo |
| `api_cache_size` | `string` | `"0.5"` | Taille du cache API Gateway (Go) |
| `api_cache_ttl` | `number` | `300` | TTL du cache en secondes |
| `log_retention_days` | `number` | `14` | Rétention des logs CloudWatch |

---

## Sorties Terraform

**Fichier :** [`outputs.tf`](outputs.tf)

Après `terraform apply`, les valeurs suivantes sont disponibles :

| Output | Description |
|--------|-------------|
| `api_gateway_id` | ID de l'API REST |
| `api_url_dev` | URL du stage dev |
| `api_url_test` | URL du stage test |
| `api_url_prod` | URL du stage prod |
| `lambda_user_management_arn` | ARN de la Lambda user_management |
| `lambda_data_processing_arn` | ARN de la Lambda data_processing |
| `lambda_image_processing_arn` | ARN de la Lambda image_processing |

---

## Déploiement

### 1. Cloner le dépôt

```bash
git clone https://github.com/fyls237/apigateway-lamda-terraform.git
cd apigateway-lamda-terraform
```

### 2. Configurer les variables

```bash
cp terraform.tfvars.example terraform.tfvars   # (non versionné)
# Éditer terraform.tfvars avec vos valeurs
```

Exemple de `terraform.tfvars` :

```hcl
aws_region   = "eu-west-1"
project_name = "my-api"
environment  = "dev"
```

### 3. Initialiser Terraform

```bash
terraform init \
  -backend-config="bucket=mon-bucket-tfstate" \
  -backend-config="key=apigateway-lambda/terraform.tfstate" \
  -backend-config="region=eu-west-1" \
  -backend-config="dynamodb_table=mon-lock-table"
```

### 4. Vérifier le plan

```bash
terraform plan
```

### 5. Appliquer l'infrastructure

```bash
terraform apply
```

### 6. Tester les endpoints

```bash
# Récupérer l'URL du stage dev
DEV_URL=$(terraform output -raw api_url_dev)

# Test : liste des utilisateurs
curl -X GET "$DEV_URL/users"

# Test : traitement de données
curl -X POST "$DEV_URL/data" \
  -H "Content-Type: application/json" \
  -d '{"values": [1, 2, 3]}'

# Test : traitement d'image (base64)
curl -X POST "$DEV_URL/images" \
  -H "Content-Type: application/json" \
  -d '{"image": "<base64>", "operation": "resize", "width": 200, "height": 200}'
```

---

## Nettoyage

Pour supprimer toutes les ressources créées :

```bash
terraform destroy
```

> ⚠️ Cette commande supprime **toutes** les ressources AWS créées par ce projet. Assurez-vous d'avoir sauvegardé les données importantes avant de l'exécuter.

---

## Licence

Ce projet est distribué sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

