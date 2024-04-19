{{- /*
Template for Configmap.

Arguments to be passed are 
- $ (index 0)
- . (index 1)
- suffix (index 2)
- dictionary (index 3) for annotations used for defining helm hooks.

See https://blog.flant.com/advanced-helm-templating/
*/}}
{{- define "epi.configmap-bdns" -}}
{{- $ := index . 0 }}
{{- $suffix := index . 2 }}
{{- $annotations := index . 3 }}
  {{- with index . 1 }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ include "epi.fullname" . }}-bdns{{ $suffix | default "" }}
  namespace: {{ template "epi.namespace" . }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  labels:
    {{- include "epi.labels" . | nindent 4 }}
data:
  # See https://github.com/pharmaledgerassoc/epi-workspace/blob/v1.3.0/apihub-root/external-volume/config/bdns.hosts
  bdns.hosts: |-
    {
      "{{ .Values.config.domain }}": {
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      },
      "{{ .Values.config.subDomain }}": {
          "brickStorages": [
              "$ORIGIN"
          ],
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      },
      "{{ .Values.config.vaultDomain }}": {
          "replicas": [],
          "brickStorages": [
              "$ORIGIN"
          ],
          "anchoringServices": [
              "$ORIGIN"
          ],
          "notifications": [
              "$ORIGIN"
          ]
      }
    }

{{- end }}
{{- end }}
