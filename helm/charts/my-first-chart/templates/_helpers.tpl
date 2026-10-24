{{- define "my-first-chart.name" -}}
{{- default .Chart.Name .Values.appName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-first-chart.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "my-first-chart.name" .) | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "my-first-chart.labels" -}}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | quote }}
app.kubernetes.io/name: {{ include "my-first-chart.name" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service | quote }}
{{- with .Values.commonLabels }}
{{ toYaml . }}
{{- end }}
{{- end -}}
