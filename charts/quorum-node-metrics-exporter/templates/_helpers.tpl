{{/*
Expand the name of the chart.
*/}}
{{- define "quorum-node-metrics-exporter.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "quorum-node-metrics-exporter.fullname" -}}
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
{{- define "quorum-node-metrics-exporter.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Allow the release namespace to be overridden for multi-namespace deployments in combined charts
*/}}
{{- define "quorum-node-metrics-exporter.namespace" -}}
  {{- if .Values.namespaceOverride -}}
    {{- .Values.namespaceOverride -}}
  {{- else -}}
    {{- .Release.Namespace -}}
  {{- end -}}
{{- end -}}

{{/*
    The full image repository:tag[@sha256:sha] for the runner
*/}}
{{- define "quorum-node-metrics-exporter.image" -}}
{{- if .Values.image.sha -}}
{{ required "image.repository must be set" .Values.image.repository }}:{{ required "image.tag must be set" .Values.image.tag }}@sha256:{{ .Values.image.sha }}
{{- else -}}
{{ required "image.repository must be set" .Values.image.repository }}:{{ required "image.tag must be set" .Values.image.tag }}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "quorum-node-metrics-exporter.labels" -}}
helm.sh/chart: {{ include "quorum-node-metrics-exporter.chart" . }}
{{ include "quorum-node-metrics-exporter.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "quorum-node-metrics-exporter.selectorLabels" -}}
app.kubernetes.io/name: {{ include "quorum-node-metrics-exporter.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "quorum-node-metrics-exporter.serviceAccountName" -}}
{{- default (include "quorum-node-metrics-exporter.fullname" .) .Values.serviceAccount.name }}
{{- end }}
