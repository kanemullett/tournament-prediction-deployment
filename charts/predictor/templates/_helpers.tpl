{{- define "predictor.name" -}}
predictor
{{- end -}}

{{- define "predictor.fullname" -}}
{{ include "predictor.name" . }}
{{- end -}}

{{- define "predictor.scheme" -}}
{{ ternary "https" "http" .Values.ingress.tls.enabled }}
{{- end -}}

{{- define "predictor.uiUrl" -}}
{{ include "predictor.scheme" . }}://{{ .Values.ingress.hosts.ui }}
{{- end -}}

{{- define "predictor.apiUrl" -}}
{{ include "predictor.scheme" . }}://{{ .Values.ingress.hosts.api }}
{{- end -}}

{{- define "predictor.keycloakUrl" -}}
{{ include "predictor.scheme" . }}://{{ .Values.ingress.hosts.auth }}
{{- end -}}
