{{- define "predictor.name" -}}
predictor
{{- end -}}

{{- define "predictor.fullname" -}}
{{ include "predictor.name" . }}
{{- end -}}