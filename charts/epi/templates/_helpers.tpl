{{/*
Expand the name of the chart.
*/}}
{{- define "epi.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "epi.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "epi.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "epi.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}


{{/*
Common labels
*/}}
{{- define "epi.labels" -}}
helm.sh/chart: {{ include "epi.chart" . }}
{{ include "epi.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels for runner
*/}}
{{- define "epi.selectorLabels" -}}
app.kubernetes.io/name: {{ include "epi.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for leaflet reader
*/}}
{{- define "epi.leafletReaderSelectorLabels" -}}
app.kubernetes.io/name: {{ include "epi.name" . }}LeafletReader
app.kubernetes.io/instance: {{ .Release.Name }}LeafletReader
{{- end }}

{{/*
Selector labels for runner used by kubectl --selector=key1=value1,key2=value2
*/}}
{{- define "epi.selectorLabelsKubectl" -}}
app.kubernetes.io/name={{ include "epi.name" . }},app.kubernetes.io/instance={{ .Release.Name }}
{{- end }}

{{/*
Selector labels for builder
*/}}
{{- define "epi.builderSelectorLabels" -}}
app.kubernetes.io/name: {{ include "epi.name" . }}-builder
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Selector labels for builder used by kubectl --selector=key1=value1,key2=value2
*/}}
{{- define "epi.builderSelectorLabelsKubectl" -}}
app.kubernetes.io/name={{ include "epi.name" . }}-builder,app.kubernetes.io/instance={{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "epi.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "epi.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
    The full image repository:tag[@sha256:sha] for the runner
*/}}
{{- define "epi.runner.image" -}}
{{- if .Values.runner.image.sha -}}
{{ .Values.runner.image.repository }}:{{ .Values.runner.image.tag | default .Chart.AppVersion }}@sha256:{{ .Values.runner.image.sha }}
{{- else -}}
{{ .Values.runner.image.repository }}:{{ .Values.runner.image.tag | default .Chart.AppVersion }}
{{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha] for the builder
*/}}
{{- define "epi.builder.image" -}}
{{- if .Values.builder.image.sha -}}
{{ .Values.builder.image.repository }}:{{ .Values.builder.image.tag }}@sha256:{{ .Values.builder.image.sha }}
{{- else -}}
{{ .Values.builder.image.repository }}:{{ .Values.builder.image.tag }}
{{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha] for kubectl
*/}}
{{- define "epi.kubectl.image" -}}
{{- if .Values.kubectl.image.sha -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}@sha256:{{ .Values.kubectl.image.sha }}
{{- else -}}
{{ .Values.kubectl.image.repository }}:{{ .Values.kubectl.image.tag }}
{{- end -}}
{{- end -}}

{{- define "epi.pvc" -}}
{{- if .Values.persistence.existingClaim }}
{{- .Values.persistence.existingClaim }}
{{- else }}
{{- include "epi.fullname" . }}
{{- end }}
{{- end }}

{{/*
Configuration env.json
*/}}
{{- define "epi.envJson" -}}
{
  "PSK_TMP_WORKING_DIR": "tmp",
  "PSK_CONFIG_LOCATION": "../apihub-root/external-volume/config",
  "DEV": {{ required "config.dev must be set" .Values.config.dev | quote}},
  "VAULT_DOMAIN": {{ required "config.vaultDomain must be set" .Values.config.vaultDomain | quote}},
  "BUILD_SECRET_KEY": {{ required "config.buildSecretKey must be set" .Values.config.buildSecretKey | quote}},
  "SSO_SECRETS_ENCRYPTION_KEY": {{ required "config.ssoSecretsEncryptionKey must be set" .Values.config.ssoSecretsEncryptionKey | quote}},
  "BDNS_ROOT_HOSTS": "http://127.0.0.1:8080",
  "OPENDSU_ENABLE_DEBUG": false,
  "EPI_DOMAIN": {{ required "config.domain must be set" .Values.config.domain | quote}},
  "EPI_SUBDOMAIN": {{ required "config.subDomain must be set" .Values.config.subDomain | quote}},
  "EPI_VERSION": {{ required "config.epiVersion must be set" .Values.config.epiVersion | quote}},
  "MIGRATION_FOLDER_PATH": "../../../../apihub-root/migrations"
}
{{- end }}

{{/*
Configuration apihub.json.
Taken from https://github.com/pharmaledgerassoc/epi-workspace/blob/v1.3.1/apihub-root/external-volume/config/apihub.json
*/}}
{{- define "epi.apihubJson" -}}
{
  "storage": "../apihub-root",
  "port": 8080,
  "preventRateLimit": true,
  "activeComponents": [
    "bdns",
    "bricking",
    "anchoring",
    "get-fixed-url",
    "epi-mapping-engine",
    "epi-mapping-engine-results",
    "get-gtin-owner",
    "leaflet-web-api",
    "metadata",
    "integration-api",
    "health-check-api",
    "versionlessDSU",
    "mq",
    "secrets",
    "lightDBEnclave",
    "staticServer"
  ],
"componentsConfig": {
    "epi-mapping-engine": {
      "module": "./../../gtin-resolver",
      "function": "getEPIMappingEngineForAPIHUB"
    },
    "epi-mapping-engine-results": {
      "module": "./../../gtin-resolver",
      "function": "getEPIMappingEngineMessageResults"
    },
    "leaflet-web-api": {
      "module": "./../../gtin-resolver",
      "function": "getWebLeaflet"
    },
    "metadata": {
          "module": "./../../gtin-resolver",
          "function": "getMetadata"
    },
    "get-gtin-owner": {
      "module": "./../../gtin-resolver",
      "function": "getGTINOwner"
    },
    "integration-api": {
      "module": "./../../gtin-resolver",
      "function": "getIntegrationAPIs",
      "requestLimiterConfig": {
        "metadataCapacity": 5,
        "epiCapacity": 5
      }
    },
    "health-check-api": {
          "module": "./../../gtin-resolver",
          "function": "getHealthCheckAPIs"
    },
    "versionlessDSU": {
      "module": "./components/versionlessDSU"
    },
    "staticServer": {
      "excludedFiles": [
        ".*.secret"
      ]
    },
    "bricking": {},
    "anchoring": {}
  },
  "responseHeaders": {
    "X-Frame-Options": "SAMEORIGIN",
    "X-XSS-Protection": "1; mode=block"
  },
  "enableRequestLogger": true,
  "enableJWTAuthorisation": false,
  "enableOAuth": false,
  "oauthJWKSEndpoint": "https://login.microsoftonline.com/<TODO_TENANT_ID>/discovery/v2.0/keys",
  "enableLocalhostAuthorization": false,
  "skipOAuth": [
    "/assets",
    "/bdns",
    "/bundles",
    "/gtinOwner/",
    "/leaflets/",
    "/metadata/"
  ],
  "oauthConfig": {
    "whitelist": [],
    "issuer": {
      "issuer": "https://login.microsoftonline.com/<TODO_TENANT_ID>/oauth2/v2.0/",
      "authorizationEndpoint": "https://login.microsoftonline.com/<TODO_TENANT_ID>/oauth2/v2.0/authorize",
      "tokenEndpoint": "https://login.microsoftonline.com/<TODO_TENANT_ID>/oauth2/v2.0/token"
    },
    "client": {
      "clientId": "<TODO_CLIENT_ID>",
      "scope": "email offline_access openid api://<TODO_CLIENT_ID>/access_as_user",
      "redirectPath": "https://<TODO_DNS_NAME>/?root=true",
      "clientSecret": "<TODO_CLIENT_SECRET>",
      "logoutUrl": "https://login.microsoftonline.com/<TODO_TENANT_ID>/oauth2/logout",
      "postLogoutRedirectUrl": "https://<TODO_DNS_NAME>/?logout=true"
    },
    "sessionTimeout": 1800000,
    "keyTTL": 3600000,
    "debugLogEnabled": false
  },
  "serverAuthentication": false
  "db": {
    "uri": "<TODO_COUCHDB_URI>",
    "user": "admin",
    "secret": "<TODO_COUCHDB_SECRET>",
    "debug": "<TODO_COUCHDB_DEBUG>"
  }  
}
{{- end }}

{{/*
Configuration apihub.json for read only mode
*/}}
{{- define "epi.readOnlyApihubJson" -}}
{
  "storage": "../apihub-root",
  "port": 8080,
  "preventRateLimit": true,
  "activeComponents": [
    "bdns",
    "bricking",
    "anchoring",
    "get-fixed-url",
    "leaflet-web-api",
    "metadata",
    "get-gtin-owner",
    "debugLogger",
    "staticServer"
  ],
  "componentsConfig": {
    "leaflet-web-api": {
        "module": "./../../gtin-resolver",
        "function": "getWebLeaflet"
    },
    "get-gtin-owner": {
        "module": "./../../gtin-resolver",
        "function": "getGTINOwner"
    },
    "metadata": {
        "module": "./../../gtin-resolver",
        "function": "getMetadata"
    },
    "staticServer": {
        "excludedFiles": [
          ".*.secret"
        ]
    },
    "bricking": {},
    "anchoring": {}
  },
  "responseHeaders": {
    "X-Frame-Options": "SAMEORIGIN",
    "X-XSS-Protection": "1; mode=block"
  },
  "enableRequestLogger": true,
  "enableJWTAuthorisation": false,
  "enableOAuth": false,
  "enableLocalhostAuthorization": false,
  "db": {
    "uri": "<TODO_COUCHDB_URI>",
    "user": "reader",
    "secret": "<TODO_COUCHDB_SECRET>",
    "debug": "<TODO_COUCHDB_DEBUG>"
  }
}
{{- end }}

{{/*
The Name of the ConfigMap for the Build Info Data
*/}}
{{- define "epi.configMapBuildInfoName" -}}
{{- printf "%s-%s" (include "epi.fullname" .) "build-info" }}
{{- end }}

{{/*
The builder image that was built at last. Return an empty string if not yet exists.
*/}}
{{- define "epi.lastBuilderImage" -}}
{{- $configMap := lookup "v1" "ConfigMap" .Release.Namespace (include "epi.configMapBuildInfoName" .) -}}
{{- if $configMap -}}
{{ $configMap.data.lastBuilderImage | default "" }}
{{- end -}}
{{- end -}}

